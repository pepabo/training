# 第 15 章 JavaScript 入門

この章では以下のことを学習します。

- JavaScript / ECMAScript とは
- 実行環境
- トランスパイル
- パッケージマネージャーの利用

研修資料上のリンク先も参照しながら進めましょう。

## JavaScript

ブラウザ上でJavaScriptを動かしてみましょう。例えば以下のようなコードを適当な場所に保存し、ブラウザで開きます。

```html
<!DOCTYPE html>
<html>
  <body>
    <h1>JavaScript Test Page</h1>
    <script>
      function foo() {
        x = 'foo';
        alert(x);
      }
      
      foo();  // 先ほど宣言した function を実行
    </script>
  </body>
</html>
```

foo と書いたアラートが表示されるはずです。
ブラウザ上でJavaScriptを動かすには、`<script>` タグの内部にコードを記述すればいいことが分かりました。

続けて以下のように書き加えてみましょう。

```diff
  <!DOCTYPE html>
  <html>
    <body>
      <h1>JavaScript Test Page</h1>
      <script>
        function foo() {
          x = 'foo';
          alert(x);
        }
        
        foo();  // 先ほど宣言した function を実行
  
+       function bar() {
+         alert(x);
+       }
+       
+       bar();
      </script>
    </body>
  </html>
```

ページをリロードすると、 foo と書いたアラートが 2 回表示されるでしょう。
つまり、 `function foo` で設定した一時変数を `function bar` からも参照できるということです。
コード上のどこからでも参照できてしまうということは、予想しないタイミングで書き換えてしまうようなコードも書けてしまいます。
これを避けるためには `x` の前に `var` をつけ `var x = 'foo';` と書く必要がありますが、うっかり `var` をつけ忘れても動いてしまいます。

このように、ブラウザで動いている JavaScript には歴史的経緯により罠が存在し、それを回避するために [Strict Mode](https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Strict_mode) があります。

このような状況を打破するために、より安全なコードを書けるような言語仕様を[ECMAScript](https://tc39.es/ecma262/)として策定し、徐々にブラウザ側もその言語仕様を処理できるようにしていくという試みが取られるようになりました。
ECMAScript 2015 以降は毎年1回その時点での ECMAScript 仕様書のスナップショットが ECMAScript 20xx としてリリースされています。

とはいえ、ブラウザが常に最新のECMAScriptをサポートしているとは限りません。
新しいECMAScriptの機能をより安全に使用するためのアプローチとして、以下の手法が一般的です

1. **トランスパイラの使用**: ECMAScript の最新機能を古いブラウザでも動作するコードに変換するツール
2. **Polyfill**: 新しいAPIを古いブラウザでも利用可能にする実装

[Can I Use](https://caniuse.com/)などで機能のサポート状況を確認し、ターゲットとするブラウザ上で動作することを確認し、必要であれば上記のような手法を取ります。

最近では、主要なブラウザの対応状況を一目で分かるようにする仕組みとして[Baseline](https://web.dev/baseline?hl=ja)も利用できます。
たとえば、MDNにおいて[Iterator](https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Global_Objects/Iterator)を確認すると主要ブラウザで広く対応していることを確認できますが、最近ES2025で導入された[Iterator.prototype.toArray()](https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Global_Objects/Iterator/toArray)では古いブラウザやデバイスでは動作しないことがある可能性があることがわかります。

MDNの [JavaScript ガイド](https://developer.mozilla.org/ja/docs/Web/JavaScript/Guide) や [JavaScript リファレンス](https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference) を参考に、研修を進めながら文法を習得するとよいでしょう。

また、フロントエンドプロジェクトやこの研修でのコーディング規約を [付録 1](../appendix01/) にまとめていますので、これからコードを書くときは適宜参照してください。

## JavaScriptの実行環境

上記ではブラウザを実行環境としましたが、CLIアプリケーションやサーバサイドアプリケーションを作成するのに適した実行環境もあります。

代表的な実行環境であるNode.jsを利用してみましょう。

### Node.js 環境のセットアップ

Homebrew で直接インストールもできますが、プロジェクトによって依存する Node.js を切り替えるためのツールがあると便利です。

* [nodenv/nodenv: Manage multiple NodeJS versions.](https://github.com/nodenv/nodenv) + [nodenv/node-build: Install NodeJS versions](https://github.com/nodenv/node-build) Homebrew にあります。
* [nvm-sh/nvm: Node Version Manager - Simple bash script to manage multiple active node.js versions](https://github.com/nvm-sh/nvm) Homebrew にあります。

[Node.js Releases](https://nodejs.org/en/about/previous-releases) でLTS(長期サポート)のバージョンを確認できます。
最新のLTSバージョンのNode.jsをインストールしましょう。

### Node.js で実行してみる

ためしに先ほどのコード `foo.js` として保存し、Node.jsで動作させてみます。

```js
function foo() {
  x = 'foo';
  alert(x);
}

foo();
```

```sh
node foo.js
```

すると以下のようなエラーが表示されます。

```sh
>>> % node foo.js
/path/to/foo.js:3
  alert(x);
  ^

ReferenceError: alert is not defined
```

`alert()` 関数は[DOM (Document Object Model)[https://developer.mozilla.org/ja/docs/Web/API/Document_Object_Model] APIとしてブラウザ上では利用できますが、Node.js上では未定義です。
このように、実行環境によって利用できるAPIに差異があります。

たとえば、フロントエンドアプリケーションのパフォーマンス向上のためにサーバサイド上でHTMLを生成する[Server Side Rendering](https://web.dev/articles/rendering-on-the-web?hl=ja#server-side)のような技術を活用するときは、そのコードが動作する実行環境(たとえばブラウザなのか、Node.jsなのか)を意識することが重要です。

実行環境は他にも [Deno](https://deno.com/) や [Bun](https://bun.sh/) などがあり、それぞれに利用できる機能やセキュリティに関する機構、周辺ツールの違いがあります。

## 異なるバージョンのECMAScriptに変換する

トランスパイラを導入するために、Node.jsに標準で付属しているパッケージマネージャー npm を利用します。

ほかにもpnpm, yarn といった同様のツールが存在し、それぞれに特徴(実行速度や依存関係のインストールの取扱、付加されている機能の違い)があります。

`npm` コマンドを使って Babel をインストールしてみましょう。
まずは、適当な場所にディレクトリを作成して移動し、以下のコマンドを入力します。

```sh
$ npm init
```

つづいて、以下のコマンドでパッケージをインストールします。

```sh
$ npm install -D @babel/core @babel/cli @babel/preset-env
```

インストールしたパッケージは、コマンドを実行したディレクトリ直下の `node_modules` ディレクトリに存在しています。
ソースコードをgit管理する場合は、`node_modules` ディレクトリの中身がそのままコミットされることを避けるために、 `.gitignore` に `node_modules` という行を追加してください。

インストールが完了すると、`package.json` と `package-lock.json` が作成されていることを確認できます。
`package.json` にインストールしたパッケージとそのバージョンが記述され、`package-lock.json` に依存ツリー全体のパッケージのバージョンが記録されます。

Babel を実行する準備が整ったので、以下のスクリプトを `try-transpile.js` として保存します。
このスクリプトには、ES2022から導入された[Class Static Block](https://github.com/tc39/proposal-class-static-block)が含まれています。

```js
class Foo {
  static staticProperty = "Called";
  static staticFunction = function() {
    return Foo.staticProperty;
  };
}

let foo = new Foo();

console.log(foo.staticFunction());
```

次に、`babel.config.js` を以下のように編集します。すでにファイルが存在する場合はすべてコメントアウトしてから、以下を追記してみましょう。

```js
module.exports = {
  plugins: ["@babel/plugin-transform-class-properties"],
  presets: [
    [
      '@babel/preset-env',
      {
        targets: 'defaults'
      }
    ]
  ]
};
```

次に、以下のようなコマンドを実行します。

```bash
$ npx babel try-transpile.js -o try-transpiled.js
```

実行に生成される `try-transpiled.js` を見ると、スクリプトがES2015形式に変換されて出力されている様子を確認できます。

今回の場合は、[@babel/preset-env](https://babeljs.io/docs/babel-preset-env) を用いて、指定した実行環境に合わせてスクリプトが変換されています。
targetsには、[Browserslist](https://browsersl.ist/)形式で実行環境を指定できます。

JavaScriptの言語仕様にバージョンが存在することや、実行環境に合わせてトランスパイルが必要になることがあることが理解できたでしょうか。

[Babel Repl](https://babeljs.io/repl) とドキュメントを使って ECMAScript 20xx にはどのような言語仕様があるか、それがどのようにブラウザで実行可能なコードに変換されるかを見てみましょう。

## 練習問題

### 基本

1. ECMAScript の仕様に新しい機能が追加されるためにはどのようなプロセスが必要かを調べてみましょう。
1. `var` と `let` `const` とのそれぞれの違いを調べて説明してください。
1. `function` と arrow function それぞれにおける `this` の意味がどのように異なるかを調べて説明してください。
1. JavaScriptの実行環境を列挙し、違いを比較してみましょう。
1. Babel を使って `increment()` メソッドで数字を増やすことができ、 `decrement()` で数字を減らすことができる、 `Counter` クラスを作り、その変換した結果をブラウザ上で確認できるようにしてみてください。
1. なぜ `package-lock.json` が必要なのかを調べてみましょう。
1. 先ほど実行した `npx` コマンドの意味を調べてみましょう。

### おかわり

1. Node.jsを実行環境とするコマンドラインインタフェースアプリケーションを何かつくってみましょう。
1.  [付録 1](../appendix01/)で取り上げたeslintをインストールし、ソースコードを検査してみましょう。
