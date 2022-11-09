import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:microposts_app/feed_store.dart';
import 'package:microposts_app/login_state_store.dart';
import 'package:provider/provider.dart';

class PostPage extends StatelessWidget {
  const PostPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text("投稿"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(right: 16, top: 8, bottom: 8),
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
                onPressed: () async {
                  final content = _controller.text;
                  if (content.isEmpty) return;

                  final store = context.read<FeedStore>();
                  await store
                      .post(
                          content, context.read<LoginStateStore>().accessToken)
                      .catchError((e) {
                    final snackBar = SnackBar(
                      content: Text(e.message),
                      action: SnackBarAction(
                        label: "閉じる",
                        onPressed: () {},
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  });

                  Navigator.of(context).pop(true);
                },
                child: Text("投稿")),
          ),
          Container(
            padding: EdgeInsets.all(16),
            height: 200,
            child: TextField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: _controller,
            ),
          ),
        ],
      ),
    );
  }
}
