import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:microposts_app/micropost.dart';

class PostFailedException implements Exception {
  final String message;
  PostFailedException(this.message);
}

class FeedStore extends ChangeNotifier {
  List<Micropost> _microposts = [];
  List<Micropost> get microposts => _microposts;

  Future<void> fetchFeeds(String token) async {
    final client = http.Client();
    final url = Uri.http("localhost:3000", "/api/v1/feeds.json");
    final response = await client.get(url,
        headers: {HttpHeaders.authorizationHeader: "Bearer ${token}"});
    if (response.statusCode < 400) {
      final decoded = json.decode(response.body);
      final microposts = (decoded as List)
          .map<Micropost>((obj) => Micropost.fromJSON(obj))
          .toList();
      this._microposts = microposts;
      notifyListeners();
    } else if (response.statusCode < 500) {
      throw Exception("フィードを取得できませんでした。");
    } else {
      throw Exception("フィードを取得できませんでした。サーバーに問題があるようです。");
    }
  }

  Future<void> clearFeeds() async {
    this._microposts = [];
    notifyListeners();
  }

  Future<void> post(String content, String token) async {
    final url = Uri.http("localhost:3000", "/api/v1/microposts.json");
    final client = http.Client();
    final body = {"content": content};
    final response = await client.post(url, body: json.encode(body), headers: {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer ${token}"
    });

    if (response.statusCode >= 500) {
      throw PostFailedException("投稿に失敗しました。サーバに問題があるようです。");
    } else if (response.statusCode >= 400) {
      throw PostFailedException("投稿に失敗しました。");
    }
  }
}
