# 第 16 章　JavaScript のモジュールシステム

前のチャプターで `app/assets/javascripts` に置いたファイルは自動的に読み込まれると書きました。これは本番環境では結合され一つの巨大な js ファイルとして出力されます。他にも Rails Tutorial では `bootstrap-rails` gem をインストールしましたね。この gem に含まれている JavaScript ファイルも本番環境では結合されるようになっています。この結合というのは単純な結合であり、コード的に何らしかの変化が与えられることはありません。では、この JavaScript コードが複雑化して各ファイルの間で変数などデータのやりとりが必要になったときは、どのようにすればいいのでしょうか？

一つの方法としてはあるファイルの中で変数を宣言しておいて、他のファイルから参照するという方法です。また、 `var` なしのグローバル変数にしてどこからでも見られるようにするという方法もあります。後者の方は Strict モードでは動かないですし、セキュアではないコードの書き方なので論外として、前者の書き方も現状では `app/assets/javascripts` の中に置かれている js/coffee ファイルの結合順がコントロールできないので、ちゃんと変数にアクセスできるかがわかりません。また、ファイルの中で宣言した変数は、結合される他の全ての js/coffee ファイルから参照可能なので、チーム開発ではその変数に不用意にアクセスされてしまうという危険性があります。このような問題点を回避するためにはどうすれば良いでしょうか。

（オフトピック：昔のフロントエンド開発で、変数を複数の JavaScript ファイルからアクセスしたいという要求があった場合、 `window` というブラウザに必ず存在するグローバルオブジェクトに、変数を保持できる領域を設ける `window.MyApp = {};` のようなコードが書かれていました。今でも Server Side Rendering というテーマでこれに近いコードが生成されることがありますが、 SSR は比較的高度なテーマのため一旦ここでは置きます。そういうのがあるんだな程度に思っておいてください。）

この問題を解決するためには、 js ファイル内部で変数を隠蔽するようにして、別ファイルからはその変数を読み込むことを宣言する形にすれば良いでしょう。また、同じ仕組みを用いて、関数やクラスを定義したファイルとは別のファイルから読み込み、複数箇所から再利用することもできるでしょう。

上記のような仕組みをモジュールと呼びますが（ Python に慣れている人は `from X import Y` を思い出してもらえると良いです）、モジュール機構はブラウザの JavaScript にはまだ実装されてない（ Google Chrome の新し目のバージョンにはすでに実装されています）ですが、 ES6 import として言語仕様としては存在しています。

他にも、 Node.js にはモジュールシステムとして CommonJS という仕組みが以前から存在しており、この仕組みを使うことで別ファイルや外部ライブラリのコードを使うことができます。 ES6 import と CommonJS は似た仕組みを提供しようとしていますが異なっている部分もあり、注意が必要です。本題となる ES6 import に入る前に、 CommonJS がどのようなものかを見ていきましょう。

## CommonJS
CommonJS がどのようなものか動かしてみるコードを書く前に、まず Node.js を実行してみましょう。

Node.js とは C10K 問題（大規模サービスに大量ユーザのアクセスが発生して詰まってしまう問題）を解決するために考案された、非同期 I/O が特色のなどという説明があったりもしますが、一旦ここでその辺の話は置いておいて、雑に JavaScript がコマンドラインから動くもの＋その周辺環境という認識で良いです（実際最近のフロントエンド開発ではそういった側面が強く出ている）。なので、みなさんが書いている js ファイルもブラウザ固有の機能となっている部分を除けば、例えば四則演算だけで構成された js ファイルなどは Node.js で実行できます。

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

注意すべき点は `required.js` と `requiring.js` を同じディレクトリに置いておくことです。 `node requiring.js` を実行すると require OK! が出力されますでしょうか。この `module.exports =` と `require()` が CommonJS の仕組みです。この仕組みを使うと、公開されているライブラリをインストールして使うことができます。 [moment](https://momentjs.com) という日付時間を便利に扱えるライブラリが公開されているので、これをインストールして使ってみましょう。

```
$ npm install moment
```

```js:hello_moment.js
const moment = require('moment');

console.log(moment().format());
```

実行すると現在時刻が人間にも読めるように表示されると思います。

### 練習問題

1. [lodash](https://lodash.com) という配列やオブジェクトを便利に操作できるライブラリがあります。これを使って、下の `employees` 配列を性別でグループ分けして表示してください。
2. Node.js の各種 API も CommonJS として使うことができるようになっています。練習問題 1 のグループ分けの結果を JSON としてファイルに出力するコードを書いてください。

```js
const employees = [
  { name: 'Taro', gender: 'male' },
  { name: 'Hanako', gender: 'female' },
  { name: 'Jiro', gender: 'male' }
];
```

## ES6 import
ES6 import も基本的な仕組みはファイルの `require` と同じ仕組みになっていて、 `module.exports =` で公開していたものが `export` という予約語になります。ただし、 CommonJS と違う点は default export というものが存在し、少し入り組んだ公開ができるようになっているということです。以下のコードは多くのブラウザでは動かないので、一旦眺めるだけで大丈夫です（ Google Chrome では実行可能なので、ペライチの HTML ファイルを別で用意して Python `http.server` あたりを使って確認してみてもいいかもしれません）。

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

このコードは Google Chrome からは実行できますが、他の多くのブラウザからは実行できません。つまり、ブラウザでこれを実行するためには何らかの実行可能な形に変換しなければなりません。これを実行可能な形に変換するには、ざっくりというと以下の工程が必要になります。

1. 各ファイルを一つのファイルに結合する。
2. `export` したいファイルの中身を function としてラップし、 `export` するもの以外は外部からアクセスできないようにする。
3. `export` した内容を一時的に保管し、 `import` されたらアクセスできるようにする領域を設ける。
4. `export` `import` コードを置き換え、それぞれ指定したものにアクセスできるようにする。

これらを機械的に行ってブラウザで実行できる一つの巨大なファイルを生成する（トランスパイリング＋バンドリング）ことを行ってくれるのが、（名前は聞いたことあるかもしれません） [webpack](https://webpack.js.org/) です。そして webpack 自体は JavaScript 製のツールですが、これを Rails で扱えるようにしたのが `webpacker` gem です。これを使うと Rails でのフロントエンド開発に必要なものがワンアクションでインストールできますが、 webpack は上記の工程以外にも機能を持たせることができる、かつ設定が複雑、その上 `webpacker` gem でその複雑性が隠蔽されてしまうという問題があるので、ここでは一旦 webpack を使わず（ハマりが多い場合 webpack に変更するかもしれない） [Parcel](https://parceljs.org/) というこれもまた JavaScript 製のツールを使って、 Rails と協調して開発していこうと思います。

（註： Parcel をここで使っている理由は、 Webpack 単品だと設定をするのが細かすぎてそれだけで消耗してしまう、 webpacker gem だと過剰に隠蔽されてしまっているという問題があり、 Parcel を仕組みの学習のために採用しています。ここで学んだからといって実際の開発で Parcel をすぐ採用するのは一旦保留した方がいいです。 Parcel の開発速度は遅いし v2 のリリースがされないまま長期間が過ぎている。）
