import 'dart:io';
import 'package:app/stores/access_token_provider.dart';
import 'package:app/stores/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _authorizationEndpoint =
    Uri.parse('https://github.com/login/oauth/authorize');
final _tokenEndpoint = Uri.parse('https://github.com/login/oauth/access_token');

class GithubLogin extends ConsumerStatefulWidget {
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
  ConsumerState<ConsumerStatefulWidget> createState() => _GithubLoginState();
}

typedef AuthenticatedBuilder = Widget Function(
    BuildContext context, oauth2.Client client);

class _GithubLoginState extends ConsumerState<GithubLogin> {
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
    final accessTokenProviderNotifier = ref.read(accessTokenProvider.notifier);
    accessTokenProviderNotifier.setToken(accessToken);
    await SecureStorage.saveAccessToken(accessToken);
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