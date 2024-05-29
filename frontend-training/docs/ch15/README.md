# 第 15 章　モダン JavaScript 入門

## ECMAScript

Rails Tutorial 第6版では JavaScript を扱うことはほとんどありませんでしたが、第8.2章で `app/javascript/packs/application.js` に以下のようなコードを書いたと思います:

```js
import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import "jquery"
import "bootstrap"

Rails.start()
Turbolinks.start()
ActiveStorage.start()
```

なんの変哲もないように見える、さらっと流されたコードでしたが、実はここで使われていた `import` 文が JavaScript の仕様としてリリースされたのは 2015 年 6 月のことです。JavaScript のプログラムをモジュールに分割して別のファイルから必要なときにインポートするという仕組みは意外と最近まで標準仕様に無かったのですね。

`import` / `export` 文などといった JavaScript の言語仕様を定めている仕様書は [ECMAScript](https://tc39.es/ecma262/) と呼ばれています。

これらのJavaScriptファイルは、本番（e.g. Heroku, マネクラ）環境では一つの `.js` ファイルにまとめられるようになっています(`rails assets:precompile` コマンドで、一つのファイルにする、かつ改行などを削除することでインターネットへのアクセス回数や通信容量を減らすという目的を果たしています)。
この処理を**バンドリング**などと呼んでいます。
バンドリングは JavaScript と同様に CSS にも存在し、Rails では `.scss` ファイルを一つの CSS ファイルにまとめて本番環境に置いています。

`app/assets/javascripts/application.js` に例えば以下のようなコードを書いてみましょう。

```js
// function xxx() は Ruby の def のようなものです
function foo() {
  x = 'foo';  // 一時変数を宣言
  alert(x);
}

foo();  // 先ほど宣言した function を実行
```

rails server を立ち上げてどこでもいいので開発環境のページを読み込むと、 foo と書いたアラートが表示されるはずです。Ruby に立ち返って考えてみると、 `x` として宣言した一時変数は `def` の外からは参照できなかったはずです。

続けてその下にこう書いてみましょう。

```js
function bar() {
  alert(x);
}

bar();
```

ページをリロードすると、 foo と書いたアラートが 2 回表示されるでしょう。つまり、 `function foo` で設定した一時変数を `function bar` からも参照できるということです。コード上のどこからでも参照できてしまうということは、予想しないタイミングで書き換えてしまうようなコードも書けるわけで、チーム開発をすると「知らないうちに変数が書き換えられていて、書き換わってないものと思ってコードを書いたらバグってしまった」という事態が発生してしまうわけです。恐ろしいですね。これを避けるためには `x` の前に `var` をつけ `var x = 'foo';` と書く必要がありますが、うっかり `var` をつけ忘れても動いてしまいます。
そもそも、各処理のコードの末尾には `;` をつけるという決まりになっているのですが、JavaScript の文法には [自動セミコロン挿入](https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Lexical_grammar#automatic_semicolon_insertion) (Automatic Semicolon Insertion, ASI) という規則があり、 `var x = 'foo'` の場合は `;` を省略しても動いてしまいます。が、構文によってはコードの意味がプログラマの意図しないものに変わってしまう場合もあります（例えば [return文](https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Statements/return#automatic_semicolon_insertion) ）。恐ろしいですね。

このように、ブラウザで動いている JavaScript には歴史的経緯により罠が大量に存在し、それを回避するために Strict （厳格：バグが混入しやすいコードを書いた場合エラーが発生する）モードなども存在していますが、これも宣言を忘れると罠のあるコードで動くという険しい状況にあります。

その状況を打破するために、より安全なコードを書けるような言語仕様を策定し、徐々にブラウザ側もその言語仕様を処理できるようにしていくという試みが取られるようになりました。これが ECMAScript 2015 (ECMAScript 6) ならびにその後継である ECMAScript 20xx です。
ECMAScript 2015 以降は毎年1回その時点での ECMAScript 仕様書のスナップショットが ECMAScript 20xx としてリリースされています。
現行のブラウザがサポートしている JavaScript というのは ECMAScript 5 相当です（Google Chrome などの最新ブラウザでは ECMAScript 2015 以降の一部仕様をすでにサポートしています）。

とはいえ、現状でブラウザがサポートしていない言語仕様をどうやって使うのか。そこにも altJS の力を使います。 ECMAScript 20xx で書いたコードを ECMAScript 5 で解釈できるコードへと変換するツール（これを一般的に**トランスパイラ**と呼びます）を使い、ブラウザで実行可能なコードへと変換するようにしたのです。将来的にブラウザが直接サポートするようになれば、そのツール自体は捨ててしまえます。現在この ECMAScript 20xx to ECMAScript 5 トランスパイラとして主流なのが [Babel](https://babeljs.io/) という Node.js 製のツールで、モダンフロントエンド開発は基本的にこのツールの上に構築されています。私たちも ECMAScript 20xx （執筆時は 2021 年 6 月なので ECMAScript 2021）に準拠して、安全なコードを書いていきましょう。

## Babel を使ってみてECMAScriptのバージョンを意識する

Rails Tutorial を終えた時点では皆さんの環境で `yarn` コマンドが利用できるようになっているはずです。 `yarn` コマンドを使って Babel をインストールしてみましょう:

```
$ yarn add -D @babel/core @babel/cli @babel/preset-env
```

色々ログが出ると思いますが、最終的には `added xxxx packages` のようなメッセージが出ると思います（出なかったらなぜ出なかったかちょっと考えてみて、わからなさそうだったら呼んでください）。

（オフトピック：ドキュメント類でたまに `yarn` というコマンドを使っている時がありますが、 Yarn が生まれた経緯としては NPM のインストールがかつて遅かったり lockfile が無かったりという話があり、 NPM の機能が Yarn とあまり変わらなくなった今 Yarn を採用しなければならない理由はあまりありません。Webpacker が Yarn に依存しているため、この章ではとりあえず Yarn を使っていますが、ほかのプロジェクトでは適宜 `npm` コマンドに置き換えて読んでください）

この方法でインストールした Babel はコマンドを実行したディレクトリに `node_modules` ディレクトリが掘られてそこに存在しています。もし Rails Tutorial をやっているディレクトリで実行した場合、このまま Git でコミットしてしまうと膨大な `node_modules` ディレクトリの中身がそのままコミットされてしまいます。それを避けるために、 `.gitignore` に（もしまだ無ければ） `node_modules` という行を追加してください。

Babel を実行する準備が整ったので、以下のスクリプトを `hello_es2015_class.js` として保存します。

```js
// hello_es2015_class.js

class Foo {

  // Ruby の initialize 相当
  constructor(bar) {
    this.bar = bar;
  }

  // class に def するのと同じ
  baz() {
    alert(this.bar);
  }
}

new Foo('qux').baz();
```

次に、`babel.config.js` を以下のように編集します。すでにファイルが存在する場合はすべてコメントアウトしてから、以下を追記してみましょう。

```js
module.exports = {
  "presets": [
    [
      "@babel/preset-env",
      {
        "targets": {"ie":"11"}
      }
    ]
  ]
}
```

次に、以下のようなコマンドを実行します。

```bash
$ yarn run babel hello_es2015_class.js -o transpiled_es2015_class_to_es5.js
```

実行に生成される `transpiled_es2015_class_to_es5.js` を見ると、スクリプトが変換されて出力されている様子を確認できます。

JavaScriptの言語仕様(=[ECMAScript](https://jsprimer.net/basic/ecmascript/))にはいくつかのバージョンがあります。都度バージョンアップが重ねられ、新しい言語仕様が増えていきますが、必ずしも実行環境(たとえばブラウザ)が対応できているわけではありません。
今回の場合は、[@babel/preset-env](https://babeljs.io/docs/babel-preset-env) を用いて指定した動作環境に合わせてスクリプトが変換されています。
Internet Explorer 11はES2015の構文を理解できないので、それより下のECMAScriptバージョンにあわせて変換されたのです。

Webpacker を利用している場合 `config/webpacker.yml` の設定が `compile: true` となっていれば、 `app/javascript` ディレクトリ以下に書かれたコードは自動でこのような Babel によるトランスパイルが行われるという寸法です。

こちらのコードも書いてみましょう。ECMAScript 2015 から導入された **アロー関数（arrow function）** と呼ばれるものを使っています:

```js
// hello_es2015_arrow_function.js

const add = (a, b) => {
  return a + b;
}
```

`hello_es2015_arrow_function.js` を書いたら次のコマンドを実行してみましょう。

```bash
$ yarn run babel hello_es2015_arrow_function.js -o transpiled_es2015_arrow_function_to_es5.js
```

`transpiled_es2015_arrow_function_to_es5.js` を見てみると以下のようなスクリプトが生成されているでしょうか。

```js
// transpiled_es2015_arrow_function_to_es5.js

"use strict";

var add = function add(a, b) {
  return a + b;
};
```

変換前のスクリプトの arrow function `() => {}` が ECMAScript 5 の `function` による構文に変換されていることがわかります。

最近の主要ブラウザであれば、ES2015の仕様に準拠したスクリプトを理解できるので、トランスパイルをしなくても良い場合があります。`babel.config.js` を以下のように編集します。

```diff
  module.exports = {
    "presets": [
      [
        "@babel/preset-env",
        {
-         "targets": {"ie":"11"}
          "targets": "> 0.25%, not dead"
        }
      ]
    ]
  }
```

再度以下のコマンドを実行します。

```bash
$ yarn run babel hello_es2015_class.js -o transpiled_es2015_class_to_es5.js
```

生成された `transpiled_es2015_class_to_es5.js` と、変換元である `hello_es2015_class.js` の差分はそれほど多くないことが確認できると思います。

```bash
>>> % diff hello_es2015_class.js transpiled_es2015_class_to_es5.js
1c1
< class Foo {
---
> "use strict";
2a3
> class Foo {
13d13
<
```

JavaScriptの言語仕様にバージョンが存在することや、実行環境に合わせてトランスパイルが必要になることがあることが理解できたでしょうか。
[Babel Repl](https://babeljs.io/repl) とドキュメントを使って ECMAScript 20xx にはどのような言語仕様があるか、それがどのようにブラウザで実行可能なコードに変換されるかを見てみましょう。

これから JavaScript のコードを書くときは Babel に準拠して、 `var` ではなく `let` `const` を、 `function` ではなく arrow function を使うよう心がけましょう（私見ですが `const` を使うケースが 95% ぐらいで `let` が 5%, `var` を使うことはまず無くなります）。

フロントエンドプロジェクトやこの研修でのコーディング規約を [付録 1](../appendix01/) にまとめていますので、これからコードを書くときは適宜参照してください。

## 練習問題

1. ECMAScript の仕様に新しい機能が追加されるためにはどのようなプロセスが必要かを説明してください。
1. `var` と `let` `const` とのそれぞれの違いを調べて説明してください。
1. `function` と arrow function それぞれにおける `this` の意味がどのように異なるかを調べて説明してください。
1. Babel を使って `increment()` メソッドで数字を増やすことができ、 `decrement()` で数字を減らすことができる、 `Counter` クラスを作り、その変換した結果をブラウザ上で確認できるようにしてみてください。

（注意：このチャプターで作成したファイルは次以降のチャプターでは使いませんので、間違えてコミットしないよう元に戻しておいてください。 `yarn add` したパッケージも `yarn remove` したり、削除した `babel.config.js` も `git restore` で元に戻しておいてください。）

## 次回予告

次のチャプターでは、ECMAScript 20xx で書いたコードを Rails で自動的に読み込めるようにするため、また本番環境でバンドリングできるようにするための前段階として JavaScript のモジュール機構について学びます。
