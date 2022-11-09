import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:microposts_app/feed_store.dart';
import 'package:microposts_app/login_state_store.dart';
import 'package:microposts_app/validator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = "";
  String password = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ログイン"),
      ),
      body: Container(
        margin: EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: "メールアドレス",
                hintText: "email@example.com",
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: Validator.emailValidator,
              onChanged: (value) {
                setState(() {
                  this.email = value;
                });
              },
            ),
            TextFormField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "パスワード",
                hintText: "****",
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: Validator.passwordValidator,
              onChanged: (value) {
                setState(() {
                  this.password = value;
                });
              },
            ),
            _loginButton(context),
          ],
        ),
      ),
    );
  }

  Widget _loginButton(BuildContext context) {
    if (Validator.isValidEmail(this.email) &&
        Validator.isValidPassword(this.password)) {
      return ElevatedButton(
        onPressed: () async {
          final client = http.Client();
          final params = {
            "grant_type": "password",
            "username": this.email,
            "password": this.password,
            "client_id": DotEnv.env["CLIENT_ID"],
            "client_secret": DotEnv.env["CLIENT_SECRET"],
            "scope": "read write"
          };
          final uri = Uri.http(
            "localhost:3000",
            "/oauth/token",
          );
          final response =
              await client.post(uri, body: params).catchError((error) {
            final snackBar = SnackBar(
              content: Text("ログイン中にエラーが発生しました。"),
              action: SnackBarAction(
                label: "閉じる",
                onPressed: () {},
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          });

          if (response.statusCode >= 400) {
            final snackBar = SnackBar(
              content: Text("ログインできませんでした。メールアドレスとパスワードが正しいか確認してください。"),
              action: SnackBarAction(
                label: "閉じる",
                onPressed: () {},
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          } else {
            final accessToken =
                json.decode(response.body)['access_token'].toString();
            final store = context.read<LoginStateStore>();
            await store.login(accessToken);
            final storage = FlutterSecureStorage();
            await storage.write(key: "accessToken", value: accessToken);
            final feedStore = context.read<FeedStore>();
            await feedStore.clearFeeds();
            feedStore.fetchFeeds(accessToken);
            Navigator.of(context).pop();
          }
        },
        child: Text("ログイン"),
      );
    }

    return ElevatedButton(
      onPressed: () {},
      child: Text("ログイン"),
      style: ElevatedButton.styleFrom(primary: Colors.transparent),
    );
  }
}
