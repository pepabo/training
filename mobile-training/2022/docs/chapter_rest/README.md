# おまけ

## アプリからREST APIにリクエストする

REST APIの方が色々なAPIを叩けると思うので、REST APIでのリクエスト方法を雑に残しておきます。

```dart
//rest_requests.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class RestRequests {
  late final http.Client _client;
  late final Map<String, String>? _headers;

  RestRequests({String? accessToken}) {
    _client = http.Client();
    _headers = {
      'Authorization': 'token $accessToken',
      'Accept': 'application/vnd.github+json'
    };
  }

  Future<void> postGist() async {
    String path = "/gists";

    final params = {
      "description": "Test",
      "public": "true",
      "files": {
        "README.md": {"content": "Hello World"}
      }
    };

    final uri = Uri.https(
      "api.github.com",
      path,
    );

    final response =
        await _client.post(uri, headers: _headers, body: json.encode(params));
  }
}

```
