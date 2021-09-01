# 24章 Flutterと、宣言的UIプログラミング

## Flutterとは

Flutter™️ は Google が作った、単一のコードベースで iOS、 Android、Web のアプリケーションを作成できるツールキットのことです。 アプリケーションの大部分を Dart という言語で記述します。

## Flutterの特徴

### コードを宣言的に記述する

UIプログラミングには、大きく分けて二通りの手法があります。

- 手続き型 UI プログラミング
- 宣言型 UI プログラミング

手続き型 UI プログラミングとは、**A が B になったら、このように表示を変える** といったコードの書き方をします。

```js
// JavaScriptに似たなんらかの言語
button.onTap((event) {
  currentStatus = !currentStatus;
  if (currentStatus == true) {
    button.color = Colors.blue;
    button.attributes.disabled = false;
  } else {
    button.color = Colors.red;
    button.attributes.disabled = true;
  }
});
```

一方で宣言型 UI プログラミングは、**A に B という状態が与えられたら、このように表示する**といったコードの書き方をします。Flutterはこの宣言的 UI プログラミングを採用しています。

```dart
// Flutterのコード
Widget _button(BuildContext context, bool enabled, Color color) {
  return CustomButton(
    enabled: enabled,
    color: color,
  );
}
```

宣言的 UI プログラミングでは、状態の更新と UI の描画に関するコードが分離されます。そして UI の描画は、常に最新の値を使って行われます。
これにより、UI に関するコードは「前の状態」を意識する必要がなくなり、コードが書きやすくなります。 その代わりに、ボイラープレートコードが手続き型 UI プログラミングと比較して増加する傾向にあります。

Flutter ではこのようなボイラープレートコードを簡単に生成できるプラグインを Android Studio や VS Code で提供しているため、面倒なコードの記述を省きながら宣言的プログラミングの恩恵を得ることができます。

### 全てはウィジェット

Flutter では、ウィジェットと呼ばれるものを組み合わせてUIを構築します。React を使ったことがある方は、コンポーネントに似た存在と言えば理解しやすいかもしれません。

ウィジェットには様々な種類があり、モバイルアプリケーションを開発する上では欠かせない機能を簡単に利用できるようになっています。
一例として、以下のようなUIのパーツは全てウィジェットとして定義されています。

- Text
- Container
- Row
- Column
- Image
- Icon

## Flutterの開発環境構築

それでは、Flutter の実行環境を整備していきましょう。
この資料では macOS での実行環境整備について説明していきます。

Linux, Windows を使っている方は、以下のドキュメントに沿ってインストールを行ってください。

- [Windows Install](https://flutter.dev/docs/get-started/install/windows)
- [Linux Install](https://flutter.dev/docs/get-started/install/linux)

### 前提条件

macOS 10.14.5

### Flutter SDK のインストール

以下のページから、Flutter SDK をインストールします。

[Flutter Install](https://flutter.dev/docs/get-started/install/macos)

iOS / Android それぞれの環境でアプリをビルドできるようにするには、Xcode と Android Studio のインストールとセットアップが必要になります。このハンズオンの内容は特定のプラットフォームに依存してないので、どちらか好きな方を選ぶと良いでしょう。(このハンズオンは iOS をターゲットとして説明していきます）

`flutter doctor`コマンドで、実行したい環境に対して警告が出なくなれば OK です。

```bash
$ flutter doctor
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, v1.12.13+hotfix.9, on Mac OS X 10.14.5 18F203, locale ja-DE)

[✓] Android toolchain - develop for Android devices (Android SDK version 28.0.3)
[✓] Xcode - develop for iOS and macOS (Xcode 11.2.1)
[✓] Android Studio (version 3.5)
[✓] VS Code (version 1.44.2)
[✓] Connected device (1 available)

• No issues found!
```

VS Code と VS Code の Flutter Plugin のインストールは Flutter の開発に必須ではありませんが、開発に便利な機能が揃っているのでインストールすることをお勧めします。

#### 警告が消えない場合

`Connected device`の項目で警告が出ることがあるかもしれません。iOS/Android シミュレータを起動することで警告が出なくなります。

```bash
$ flutter doctor
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, v1.12.13+hotfix.9, on Mac OS X 10.14.5 18F203, locale ja-DE)

[✓] Android toolchain - develop for Android devices (Android SDK version 28.0.3)
[✓] Xcode - develop for iOS and macOS (Xcode 7076811.2.1)
[✓] Android Studio (version 3.5)
[✓] VS Code (version 1.44.2)
[!] Connected device
    ! No devices available

! Doctor found issues in 1 category.

# 以下のコマンドでiOSシミュレータを起動
$ open -a Simulator
```
