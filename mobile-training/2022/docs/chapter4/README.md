# 4章 APIと連携したアプリの開発

## アプリからGraphQL APIにリクエストする

### 今回やること
- 公開GraphQL APIを叩きます
- レスポンスの情報から画像の表示を行います。

### ウィジェットを配置し画面の作成
はじめに新たな画面を作り、APIリクエスト行うボタンとレスポンスの情報をもとに画像を表示するUIを作ります。

```dart
//ship_info_page.dart
class ShipInfoPage extends StatefulWidget {
  const ShipInfoPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ShipInfoPageState();
}

class _ShipInfoPageState extends State {
  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.network(""),
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

#### Shipモデルクラスを作る
今回は https://api.spacex.land/graphql/ を使い、キャラクター情報を取得し画面に表示を行います。\
Docsを見てShipのモデルクラスとレスポンスのJsonからShipクラスを作るfactoryメソッドを作ります。

```dart
// ship.dart
class Ship {
  final String? name;
  final String? image;
  Ship._(this.name, this.image);

  factory Ship.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final image = json['image'];
    return Ship._(name, image);
  }
}
```

#### リクエストクラスを作る
graphqlを用い、ship クエリを叩きます。

```dart
// space_x_requests.dart
class SpaceXRequests {
  final Link _link = HttpLink("https://api.spacex.land/graphql/");
  late final GraphQLClient client;

  SpaceXRequests() {
    client = GraphQLClient(
      cache: GraphQLCache(),
      link: _link,
    );
  }

  Future<Ship> fetchShip({required String id}) async {
    final QueryOptions options = QueryOptions(
      document: gql(
        r'''
          query Ship($id: ID!){
            ship(id:$id){
              id
              image
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
    final shipResult = result?['ship'];
    final ship = Ship.fromJson(shipResult);

    return ship;
  }
}
```

APIドキュメントに準拠したスキーマをQueryOptionsに記載します。shipクエリの引数はID!となっているため、`query Ship($id: ID!)` としいます。

```
//APIドキュメント
ship(
  id: ID!
): 
```
クエリの引数を動的にするため、variablesオブジェクトの中にメソッドの引数を渡しています。\
また、 `query Ship($id: ID!)` は `query($id: ID!)`と記載できますが、複数のクエリを同時に叩くことも想定しクエリで行っていることを表すクエリ名称をつけています。


### リクエストの実行とレスポンスの情報を画面に表示する
#### StatefulWidgetでShipのStateを保持
#### ボタンを押した際にリクエストを行う
キャラクター情報が取得できたら、setStateメソッドを使いStateを更新します
#### 画像のURLが有る場合、Imageウィジェットを表示する
```dart
class _ShipInfoPageState extends State {
  Ship? ship; //StatefulWidgetでShipのStateを保持

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final image = ship?.image;

    return Column(
      children: [
        if (image != null) Image.network(image), //画像のURLが取得がnullでなければ、Imageウィジェットで画像を表示する
        TextButton(
          onPressed: () async { //ボタンを押した際にリクエストを行う
            final ship = await SpaceXRequests().fetchShip(id: "GOMSTREE");
            setState(() {
              this.ship = ship;
            });
          },
          child: const Text("リクエスト")
        ),
      ],
    );
  }
}
```

