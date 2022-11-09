# 4章 APIと連携したアプリの開発

## アプリからGraphQL APIにリクエストする

### 今回やること
- 公開GraphQL APIを叩きます
- レスポンスの情報から画像の表示を行います。

### ウィジェットを配置し画面の作成
はじめに新たな画面を作り、APIリクエスト行うボタンとレスポンスの情報をもとに画像を表示するUIを作ります。

```dart
//character_info_page.dart
class CharacterInfoPage extends StatefulWidget {
  const CharacterInfoPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CharacterInfoPageState();
}

class _CharacterInfoPageState extends State {
  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (characterImage != null) Image.network(characterImage),
        TextButton(
          onPressed: () async {

          },
          child: const Text("リクエスト")
        ),
      ],
    );
  }
}
```

### GraphQLリクエストを行う
#### GraphQLクライアントパッケージ追加
flutter標準ではGraphQLにリクエストが行えないため、パッケージを追加します。ここでは[pub.dev](https://pub.dev/packages?q=GraphQL&sort=like)から人気で更新頻度が高そうなdart用のgraphqlを利用します。

```bash
flutter pub add graphql
```

#### Characterモデルクラスを作る
今回は https://rickandmortyapi.com/graphql を使い、キャラクター情報を取得し画面に表示を行います。\
Docsを見てCharacterのモデルクラスとレスポンスのJsonからCharacterクラスを作るfactoryメソッドを作ります。

```dart
// character.dart
class Character {
  final int? id;
  final String? name;
  final String? image;
  Character._(this.id, this.name, this.image);

  factory Character.fromJson(Map<String, dynamic> json){
    final name = json['name'];
    final image = json['image'];
    return Character._(0, name, image);
  }
}
```

#### リクエストクラスを作る
graphqlを用い、character クエリを叩きます。

```dart
// rick_requests.dart
import 'package:graphql/client.dart';

class RickRequests{
  final Link _link = HttpLink("https://rickandmortyapi.com/graphql");
  late final GraphQLClient client;

  RickRequests(){
    client = GraphQLClient(
      cache: GraphQLCache(),
      link: _link,
    );
  }

  Future<Character> fetchCharacter({required int id}) async {
    final QueryOptions options = QueryOptions(
      document: gql(
        r'''
          query ReadCharacter($id: ID!) {
            character(id: $id) {
              name
              image
              status
              species
            }
          }
        ''',
      ),
      variables: {
        'id': '$id',
      },
    );

    final QueryResult response = await client.query(options);

    final result = response.data;
    final char = result?['character'];
    final character = Character.fromJson(char);

    return character;
  }
}
```

APIドキュメントに準拠したスキーマをQueryOptionsに記載します。characterクエリの引数はID!となっているため、`query ReadCharacter($id: ID!)` としいます。

```
//APIドキュメント
character(
  id: ID!
): 
```
クエリの引数を動的にするため、variablesオブジェクトの中にメソッドの引数を渡しています。\
また、 `query ReadCharacter($id: ID!)` は `query($id: ID!)`と記載できますが、複数のクエリを同時に叩くことも想定しクエリで行っていることを表すクエリ名称をつけています。


### リクエストの実行とレスポンスの情報を画面に表示する
#### StatefulWidgetでCharacterのStateを保持
#### ボタンを押した際にリクエストを行う
キャラクター情報が取得できたら、setStateメソッドを使いStateを更新します
#### 画像のURLが有る場合、Imageウィジェットを表示する
```dart
class _CharacterInfoPageState extends State {
  Character? character; //StatefulWidgetでCharacterのStateを保持

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final characterImage = character?.image;

    return Column(
      children: [
        if (characterImage != null) Image.network(characterImage), //画像のURLが取得がnullでなければ、Imageウィジェットで画像を表示する
        TextButton(
          onPressed: () async { //ボタンを押した際にリクエストを行う
            final character = await GraphQLRequest().fetchCharacter(id: 1);
            setState(() {
              this.character = character;
            });
          },
          child: const Text("リクエスト")
        ),
      ],
    );
  }
}
```

## アプリからREST APIにリクエストする (任意)

APIリクエストのREST API版のコードを雑に残しておきます。

```dart
//rest_requests.dart
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
```
