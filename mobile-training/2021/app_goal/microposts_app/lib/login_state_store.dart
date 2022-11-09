import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:microposts_app/user.dart';

class LoginStateStore extends ChangeNotifier {
  String _accessToken = "";
  String get accessToken => _accessToken;
  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;
  User? _currentUser = null;
  User? get currentUser => _currentUser;

  Future<void> login(String accessToken) async {
    assert(accessToken.isNotEmpty, "Access Token must be present.");
    final uri = Uri.http("localhost:3000", "/api/v1/users/self.json");
    final client = http.Client();
    final headers = {HttpHeaders.authorizationHeader: "Bearer ${accessToken}"};
    final response = await client.get(uri, headers: headers);

    if (response.statusCode < 400) {
      final decoded = json.decode(response.body);
      final user = User.fromJSON(decoded);
      _currentUser = user;
    } else {
      throw Exception("ログインユーザーの情報が取得できませんでした。");
    }

    _accessToken = accessToken;
    _loggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    _accessToken = "";
    _loggedIn = false;
    notifyListeners();
  }
}
