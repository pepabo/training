import 'package:app/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:app/pages/ship_info_page.dart';

import 'github_info_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("home")),
      body: Column(
        children: [
          TextButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ShipInfoPage(),
                  ));
            },
            child: const Text("キャラクター画面へ"),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const LoginPage()));
            },
            child: const Text("Github ログイン画面"),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GithubInfoPage(),
                  ));
            },
            child: const Text("Githubの情報表示画面へ"),
          ),
        ],
      ),
    );
  }
}
