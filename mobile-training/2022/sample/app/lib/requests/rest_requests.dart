import 'dart:convert';
import 'package:app/models/character.dart';
import 'package:http/http.dart' as http;

class RestRequests {
  late final String _host;
  late final http.Client _client;
  late final Map<String, String>? _headers;

  RestRequests({String? accessToken}){
    _client = http.Client();
    _headers = {
      'Authorization': 'token $accessToken',
      'Accept': 'application/vnd.github+json'
    };
    _host = "rickandmortyapi.com";
  }

  Future<Character> fetchCharacter(int id) async {
    String path = "/api/character/$id";

    final params = {
      "sample": 0,
    };

    final uri = Uri.https(
      _host,
      path,
      params,
    );

    final response = await _client.get(uri);

    final decoded = json.decode(response.body);
    final character = Character.fromJson(decoded);

    return character;
  }

  Future<void> postGist() async {
    String path = "/gists";

    final params = {
      "description": "Test",
      "public": "true",
      "files": {
        "README.md": {
          "content": "Hello World"
        }
      }
    };

    final uri = Uri.https(
      "api.github.com",
      path,
    );

    final response = await _client.post(uri, headers: _headers, body: json.encode(params));
  }
}