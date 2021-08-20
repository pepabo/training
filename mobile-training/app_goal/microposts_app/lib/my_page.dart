import 'package:flutter/material.dart';
import 'package:microposts_app/login_state_store.dart';
import 'package:microposts_app/user.dart';
import 'package:provider/provider.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<LoginStateStore>().currentUser;
    return currentUser == null
        ? Center(
            child: Text("マイページ"),
          )
        : _myPageContent(context, currentUser);
  }

  Widget _myPageContent(BuildContext context, User currentUser) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                currentUser.gravatarURL,
                scale: 0.1,
                height: MediaQuery.of(context).size.height / 8,
              ),
              Padding(
                padding: EdgeInsets.only(left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentUser.name,
                      style: TextStyle(fontSize: 32),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${currentUser.followingCount} Following"),
                        Text("  "),
                        Text("${currentUser.followersCount} Followers"),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
