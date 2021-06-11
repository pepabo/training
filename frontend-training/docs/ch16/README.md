# 第 16 章　JavaScript のモジュールシステム

プロジェクトが大きくなるにつれて、JavaScript コードが複雑化して巨大化していきます。そしてコードを別々のファイルに分割したくなってきます。では、各ファイルの間で変数などデータのやりとりが必要になったときは、どのようにすればいいのでしょうか？

そのためには、 js ファイル内部でその変数を（内容は隠蔽しつつ）別ファイルから読み出せるように宣言して、別ファイルからはその変数を読み込むことを宣言する形にすれば良いでしょう。また、同じ仕組みを用いて、関数やクラスを定義したファイルとは別のファイルから読み込み、複数箇所から再利用することもできるでしょう。

（オフトピック：一つの方法としては `var` なしのグローバル変数にしてどこからでも見られるようにするという方法もありますが、Strict モードでは動かないですし、セキュアではないコードの書き方なので論外とします。

また昔のフロントエンド開発で、変数を複数の JavaScript ファイルからアクセスしたいという要求があった場合、 `window` というブラウザに必ず存在するグローバルオブジェクトに、変数を保持できる領域を設ける `window.MyApp = {};` のようなコードが書かれていました。今でも Server Side Rendering というテーマでこれに近いコードが生成されることがありますが、 SSR は比較的高度なテーマのため一旦ここでは置きます。そういうのがあるんだな程度に思っておいてください。）

上記のような仕組みをモジュールと呼びますが（ Python に慣れている人は `from X import Y` を思い出してもらえると良いです）、モジュール機構はすべてのブラウザの JavaScript エンジンに実装されいるわけではありません（ Google Chrome など主要なブラウザの新し目のバージョンにはすでに実装されています。[こちらの MDN のガイド](https://developer.mozilla.org/ja/docs/Web/JavaScript/Guide/Modules#browser_support) をご覧ください）。ですが、 ES Modules として言語仕様としては存在しています。

他にも、 Node.js にはモジュールシステムとして CommonJS という仕組みが以前から存在しており、この仕組みを使うことで別ファイルや外部ライブラリのコードを使うことができます。 ES Modules と CommonJS は似た仕組みを提供しようとしていますが異なっている部分もあり、注意が必要です。本題となる ES Modules に入る前に、 CommonJS がどのようなものかを見ていきましょう。

## CommonJS
CommonJS がどのようなものか動かしてみるコードを書く前に、まず Node.js を実行してみましょう。

Node.js とは C10K 問題（大規模サービスに大量ユーザのアクセスが発生して詰まってしまう問題）を解決するために考案された、非同期 I/O が特色のなどという説明があったりもしますが、一旦ここでその辺の話は置いておいて、雑に JavaScript がコマンドラインから動くもの＋その周辺環境という認識で良いです（実際最近のフロントエンド開発ではそういった側面が強く出ている）。なので、みなさんが書いている js ファイルもブラウザ固有の機能となっている部分を除けば、例えば四則演算だけで構成された js ファイルなどは Node.js で実行できます。

### Node.js 環境のセットアップ
（この節は macOS でのセットアップについてのみ書いています、他の OS でのセットアップについては Pull Request Welcome です）

Homebrew で直接インストールもできますが、 Node.js は頻繁にリリースがあるので Node.js の各バージョンをインストールしたり切り替えたりできるツールがある方がよいと思います。以下のどちらかを使うと良いでしょう。

* [nodenv/nodenv: Manage multiple NodeJS versions.](https://github.com/nodenv/nodenv) + [nodenv/node-build: Install NodeJS versions](https://github.com/nodenv/node-build) Homebrew にあります。
* [nvm-sh/nvm: Node Version Manager - Simple bash script to manage multiple active node.js versions](https://github.com/nvm-sh/nvm) Homebrew にあります。

（私見です： nodenv + node-build の方が rbenv + ruby-build と同じようなコマンドになっているので使いやすいと思います）

2021年6月現在では Node.js 14 を指定すると良いでしょう。nodenv であれば `sample_app` ディレクトリ直下で `nodenv local 14.17.0` のようなコマンドを実行しましょう。

```js:hello_nodejs.js
const foo = 1;
const bar = 2;
const baz = foo + bar;

console.log(baz);
```

（ tips: Node.js は `let` `const` や arrow function をネイティブでサポートしているので、それらを優先的に使いましょう。）

```
$ node hello_nodejs.js
```

`node` コマンドに引数として js ファイルを渡すと実行され、計算結果が出力されることが確認できたでしょうか。それでは、 CommonJS による別ファイルの読み込みを試してみましょう。

```js:required.js
module.exports = () => {
  console.log('require OK!');
}
```

```js:requiring.js
const requiredFunction = require('./required');

requiredFunction();
```

注意すべき点は `required.js` と `requiring.js` を同じディレクトリに置いておくことです。 `node requiring.js` を実行すると require OK! が出力されますでしょうか。この `module.exports =` と `require()` が CommonJS の仕組みです。この仕組みを使うと、公開されているライブラリをインストールして使うことができます。 [Day.js](https://day.js.org) という日付時間を便利に扱えるライブラリが公開されているので、これをインストールして使ってみましょう。

```
$ yarn add dayjs
```

```js:hello_dayjs.js
const dayjs = require('dayjs');

console.log(dayjs().format());
```

実行すると現在時刻が人間にも読めるように表示されると思います。

### 練習問題

1. [`Array` で使えるメソッド](https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Global_Objects/Array) をヒントにしながら、下の `employees` 配列を性別でグループ分けして表示してください。
2. [Node.js の各種 API](https://nodejs.org/dist/latest-v14.x/docs/api/) も CommonJS として使うことができるようになっています。練習問題 1 のグループ分けの結果を JSON としてファイルに出力するコードを書いてください。

```js
const employees = [
  { name: 'Taro', gender: 'male' },
  { name: 'Hanako', gender: 'female' },
  { name: 'Jiro', gender: 'male' }
];
```

## ES Modules
ES Modules も基本的な仕組みはファイルの `require` と同じ仕組みになっていて、 `module.exports =` で公開していたものが `export` という予約語になります。ただし、 CommonJS と違う点は default export というものが存在し、少し入り組んだ公開ができるようになっているということです。

```js:exporting.js
// default export
export default function foo() {
  console.log('foo');
}

// named export
export function bar() {
  console.log('bar');
}
```

```js:importing.js
import foo, { bar } from './exporting';

foo();
bar();
```

このコードは IE を除けば一定のバージョン以上のブラウザからは実行できますが、それ以外のブラウザからは実行できません。つまり、ブラウザでこれを実行するためには何らかの実行可能な形に変換しなければなりません。これを実行可能な形に変換するには、ざっくりというと以下の工程が必要になります。

1. 各ファイルを一つのファイルに結合する。
2. `export` したいファイルの中身を function としてラップし、 `export` するもの以外は外部からアクセスできないようにする。
3. `export` した内容を一時的に保管し、 `import` されたらアクセスできるようにする領域を設ける。
4. `export` `import` コードを置き換え、それぞれ指定したものにアクセスできるようにする。

これらを機械的に行ってブラウザで実行できる一つの巨大なファイルを生成する（トランスパイリング＋バンドリング）ことを行ってくれるのが、（名前は聞いたことあるかもしれません） [webpack](https://webpack.js.org/) です。そして webpack 自体は JavaScript 製のツールですが、これを Rails で扱えるようにしたのが `webpacker` gem です。これを使うと Rails でのフロントエンド開発に必要なものがワンアクションでインストールできますが、 webpack は上記の工程以外にも機能を持たせることができる、かつ設定が複雑、その上 `webpacker` gem でその複雑性が隠蔽されてしまうという問題があるので、ここでは `webpacker` gem を引き剥がして webpack を直接触るようにしつつ Rails と協調して開発していこうと思います。
