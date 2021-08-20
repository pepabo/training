import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:microposts_app/feed_store.dart';
import 'package:microposts_app/login_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;
import 'package:microposts_app/login_state_store.dart';
import 'package:microposts_app/micropost.dart';
import 'package:microposts_app/my_page.dart';
import 'package:microposts_app/post_page.dart';
import 'package:provider/provider.dart';

void main() async {
  await DotEnv.load();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LoginStateStore(),
        ),
        ChangeNotifierProvider(
          create: (context) => FeedStore(),
        ),
      ],
      child: MaterialApp(
        title: "MicropostsApp",
        home: Home(),
      ),
    );
  }
}

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    FlutterSecureStorage().read(key: "accessToken").then((accessToken) async {
      if (accessToken != null && accessToken.isNotEmpty) {
        context
            .read<LoginStateStore>()
            .login(accessToken)
            .then((_) => context.read<FeedStore>().fetchFeeds(accessToken))
            .catchError((e) async {
          await FlutterSecureStorage().delete(key: "accessToken");
          final snackBar = SnackBar(
            content: Text("トークンの期限が切れたため、ログアウトしました。"),
            action: SnackBarAction(
              label: "閉じる",
              onPressed: () {},
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<LoginStateStore>();
    if (!store.loggedIn) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Microposts App'),
        ),
        body: _loginButton(context),
      );
    }

    final _widgets = [_feeds(context), MyPage()];

    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Microposts App'),
        ),
        body: _widgets[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "ホーム"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "マイページ"),
          ],
          currentIndex: _selectedIndex,
          onTap: (int index) {
            setState(() {
              this._selectedIndex = index;
            });
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (BuildContext context) {
              return PostPage();
            })).then((posted) async {
              if (posted != null && posted) {
                final store = context.read<FeedStore>();
                await store.clearFeeds();
                store.fetchFeeds(context.read<LoginStateStore>().accessToken);
              }
            });
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _feeds(BuildContext context) {
    final microposts = context.watch<FeedStore>().microposts;
    return ListView.builder(
        itemCount: microposts.length,
        itemBuilder: (BuildContext context, int index) {
          return _timelineListItem(context, microposts[index]);
        });
  }

  Widget _timelineListItem(BuildContext context, Micropost micropost) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 8, bottom: 8),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Image.network(micropost.user.gravatarURL),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      micropost.user.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      micropost.content,
                      maxLines: null,
                    ),
                    Text(
                      "posted ${micropost.createdAtTimeAgoInWords} ago",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                )
              ],
            ),
          ),
          Divider(),
        ],
      ),
    );
  }

  Widget _loginButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        child: Text("ログイン"),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return LoginPage();
          }));
        },
      ),
    );
  }
}
