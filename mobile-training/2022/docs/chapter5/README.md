# 5章 OAuth2.0認証を行う

WebブラウザにはCookieにセッションIDを記録し、それを元にログイン状態の保持を行います。しかしモバイルアプリでは、この機能を使えないため、ログイン状態を別の手段で保持する必要があります。

このような、セッションベースではないユーザーの認証・認可には、OAuth2.0を用いることが多いです。
OAuth2.0とは、[RFC6749](https://openid-foundation-japan.github.io/rfc6749.ja.html)で定義される認可フレームワークです。

//TODO 文書考える
Android/iOS版開発では[flutter_webview](https://pub.dev/packages/webview_flutter)などのパッケージを用いてWebviewを用いて認証を行うことができますし、Web版開発でも多くの選択肢があります。しかしデスクトップ版開発の場合は、WebViewゼロから認証をを行う必要があります。

今回は、各プラットフォーム版共通でOAuthの認証が行えるようにしてみます。

## Github OAuthで認証をおこなう

[Github OAuth](https://docs.github.com/ja/developers/apps/building-oauth-apps/authorizing-oauth-apps)を使い、APIを叩くために必要なAccess Tokenを取得します。

codelabsの課題 [Flutter デスクトップ アプリケーションを作成する](https://codelabs.developers.google.com/codelabs/flutter-github-client#3) の 4項 のみを行います。行っていることは↓となります。

> デスクトップ OAuth2 フローが入ったウィジェットを作成します。このロジックは少々複雑です。まず一時的なウェブサーバーを立ち上げ、ユーザーをウェブブラウザで GitHub のエンドポイントにリダイレクトします。そして、このユーザーがブラウザで認証フローを完了するのを待ち、GitHub からのリダイレクト コールを処理しなければなりません。このリダイレクト コールに含まれるコードは、別途 GitHub の API サーバーを呼び出して OAuth2 トークンに変換する必要があります。

また、`github_login.dart`のコードを一部変更しているので差し替えてください。\

変更内容 
- リダイレクトコールを処理するウェブサーバーを立ち上げるてから認証フローを開始する\
  (codelabsではウェブサーバーを立ち上げる前に認証フローが開始されていた為)
- accessTokenをStateに保持

```dart
//github_login.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';

final _authorizationEndpoint =
    Uri.parse('https://github.com/login/oauth/authorize');
final _tokenEndpoint = Uri.parse('https://github.com/login/oauth/access_token');

class GithubLogin extends StatefulWidget {
  const GithubLogin({
    required this.builder,
    required this.githubClientId,
    required this.githubClientSecret,
    required this.githubScopes,
    Key? key,
  }) : super(key: key);
  final AuthenticatedBuilder builder;
  final String githubClientId;
  final String githubClientSecret;
  final List<String> githubScopes;

  @override
  State<StatefulWidget> createState() => _GithubLoginState();
}

typedef AuthenticatedBuilder = Widget Function(
    BuildContext context, oauth2.Client client);

class _GithubLoginState extends State<GithubLogin> {
  String? accessToken;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Github Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            _oauth();
          },
          child: const Text('Login to Github'),
        ),
      ),
    );
  }

  Future<void> _oauth() async {
    final grant = oauth2.AuthorizationCodeGrant(
      widget.githubClientId,
      _authorizationEndpoint,
      _tokenEndpoint,
      secret: widget.githubClientSecret,
      httpClient: _JsonAcceptingHttpClient(),
    );

    final redirectServer = await _listenRedirectServer();
    if (redirectServer != null){
      _listen(redirectServer, grant);
      _getOAuth2Client(grant, Uri.parse('http://localhost:${redirectServer.port}/auth'));
    }
  }

  Future<HttpServer?> _listenRedirectServer() async {
    // Bind to an ephemeral port on localhost
    final redirectServer = await HttpServer.bind('localhost', 0);
    return redirectServer;
  }

  Future<void> _listen(HttpServer redirectServer, oauth2.AuthorizationCodeGrant grant) async {
    var request = await redirectServer.first;
    var params = request.uri.queryParameters;
    request.response.statusCode = 200;
    request.response.headers.set('content-type', 'text/plain');
    request.response.writeln('Authenticated! You can close this tab.');
    await request.response.close();
    await redirectServer.close();

    var client = await grant.handleAuthorizationResponse(params);
    client.credentials.accessToken;

    final accessToken = client.credentials.accessToken;
  }

  Future<void> _getOAuth2Client(oauth2.AuthorizationCodeGrant grant, Uri redirectUrl) async {
    if (widget.githubClientId.isEmpty || widget.githubClientSecret.isEmpty) {
      throw const GithubLoginException(
          'githubClientId and githubClientSecret must be not empty. '
          'See `lib/github_oauth_credentials.dart` for more detail.');
    }

    var authorizationUrl = grant.getAuthorizationUrl(redirectUrl, scopes: widget.githubScopes);

    await _redirect(authorizationUrl);
  }

  Future<void> _redirect(Uri authorizationUrl) async {
    var url = authorizationUrl;
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw GithubLoginException('Could not launch $url');
    }
  }
}

class _JsonAcceptingHttpClient extends http.BaseClient {
  final _httpClient = http.Client();
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Accept'] = 'application/json';
    return _httpClient.send(request);
  }
}

class GithubLoginException implements Exception {
  const GithubLoginException(this.message);
  final String message;
  @override
  String toString() => message;
}
```

これでAccessTokenを取得できたので、認証が必要なAPIを叩くことができる様になりました。