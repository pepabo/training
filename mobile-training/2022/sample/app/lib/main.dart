import 'package:app/constants.dart';
import 'package:app/pages/home_page.dart';
import 'package:app/stores/access_token_provider.dart';
import 'package:app/stores/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(
    const ProviderScope(
      child: App(),
    )
  );
}

class App extends ConsumerStatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final accessToken = await SecureStorage.getAccessToken();
      if (accessToken != null) {
        final accessTokeNotifier = ref.read(accessTokenProvider.notifier);
        accessTokeNotifier.setToken(accessToken);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.red,
      ),
      home: const HomePage(),//const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }

}