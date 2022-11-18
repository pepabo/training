# 1章 Flutterと、宣言的UIプログラミング

## Flutterとは

Flutter™️ は Google が作った、単一のコードベースで iOS、 Android、Desktop、Web のアプリを作成できるツールキットのことです。 アプリの大部分を Dart という言語で記述します。

Googleが力をいれて?作っているので、開発スピードが早くバージョンはFlutter 1.0(2018.12.4) → Flutter 2.0(2021.3.3) → Flutter 3.0(2022.5.11)と盛んにアップデートされています。 [*2の主な変更点](https://itome.team/blog/2021/03/flutter-v2/) [*3の主な変更点](https://qiita.com/kazutxt/items/8b3c834b614d0edc5795)


## Flutterの特徴

### 宣言型UIプログラミング

UIプログラミングには、大きく分けて二通りの手法があります。

- 手続き型 UI プログラミング
- 宣言型 UI プログラミング

手続き型 UI プログラミングとは、**X が A になったら、このように表示を変える** といったコードの書き方をします。

```dart
// 仮想のDartぽい言語
Text text = Text()

Widget build() {
    text.value = "0";

    button.title = "ボタン";
    button.addAction(_setNumber());

    final column = Column();
    column.addChildren([button,textField]);
}

void _setNumber() {
    final _number = Random().nextInt(10);
    text.value = "$_number";
    if (_number / 2 = 0) {
        text.color = Color.black;
    } else {
        text.color = Color.red;
    }
}
```

一方で宣言型 UI プログラミングは、**X に A という状態が与えられたら、このように表示する**といったコードの書き方をします。Flutterはこの宣言的 UI プログラミングを採用しています。

```dart
// Flutterのコード
int _number = 0

Widget build(BuildContext context) {
    return Column(
        children: [
            Text(
                value: "$_number",
                color: _number / 2 = 0 ?  Color.black : Color.red,
            ),
            Button(
                title: "ボタン"
                onPressed: _setNumber()
            ),
        ]
    );
}

void _setNumber() {
  setState(() {
    _number = Random().nextInt(10);
  });
}
```

宣言型 UIプログラミングでは、UIの状態の更新と UI の描画に関するコードが分離されます。そして UI の描画は、常に最新の値を使って行われます。
これにより、UI に関するコードは「前の状態」を意識する必要がなくなり、コードが書きやすくなります。 

<!-- その代わりに、ボイラープレートコードが手続き型 UI プログラミングと比較して増加する傾向にあります。 -->
<!-- Flutter ではこのようなボイラープレートコードを簡単に生成できるプラグインを Android Studio や VS Code で提供しているため、面倒なコードの記述を省きながら宣言的プログラミングの恩恵を得ることができます。 -->

### クロスプラットフォーム開発
iOS、 Android、Desktop、Web を対象としたクロスプラットフォームのアプリケーション開発を行うことができます。
Androidに置き換わと言われているGoogleが開発中の新OS Fuchsia(フクシア) のアプリも作ることができます。

ただし、基本機能(カメラ、GPS、プッシュ通知などのスマートフォン)以外の、プラットフォームの固有機能、複雑な仕様や細かなカスタマイズを行う場合はそれぞれのプラットフォームごとに開発が必要となる場合もあります。

### ホットリロード
コードの変更内容を実行中のアプリにすぐに反映することができるため、開発効率がよいです。

### 全てはウィジェット
Flutter では、ウィジェットと呼ばれるものを組み合わせてUIを構築します。React を使ったことがある方は、コンポーネントに似た存在と言えば理解しやすいかもしれません。

ウィジェットには様々な種類があり、モバイルアプリを開発する上では欠かせない機能を簡単に利用できるようになっています。
一例として、以下のようなUIのパーツは全てウィジェットとして定義されています。

- Text
- Container
- Row
- Column
- Image
- Icon

---
