# 第 16 章 JavaScript のモジュールシステム

この章では以下のことを学習します。

- EcmaScript Module と CommonJS
- バンドリングの必要性とモジュールバンドラーの役割

研修資料上のリンク先も参照しながら進めましょう。

## モジュールシステム

プロジェクトが大きくなるにつれて、JavaScript コードが複雑化して巨大化していきます。
コードのスコープを適切に管理したり、リーダブルにするために別々のファイルに分割したくなってきます。
では、各ファイルのソースコード間で連携が必要になったときは、どのようにすればいいのでしょうか？

そのためには、 JavaScriptファイル内部でその変数を（内容は隠蔽しつつ）別ファイルから読み出せるように宣言して、別ファイルからはその変数を読み込むことを宣言する形にすれば良いでしょう。
また、同じ仕組みを用いて、関数やクラスを定義したファイルとは別のファイルから読み込み、複数箇所から再利用することもできるでしょう。

(`var` なしのグローバル変数にしてどこからでも見られるようにするという方法もありますが、Strict モードでは動かないですし、状態管理が煩雑になるので好ましくありません)

上記のような仕組みをモジュールと呼びます。
現在では主要なブラウザ（Chrome、Firefox、Safari、Edge）のすべてで[EcmaScript Module (以下ESM)](https://developer.mozilla.org/ja/docs/Web/JavaScript/Guide/Modules)がサポートされています。

このようなモジュールシステムはESMだけではなく、歴史的経緯から複数存在します。
Node.jsには当初からCommonJSというモジュールシステムが実装されていましたが、現在ではESMもサポートされています。

現在のJavaScriptエコシステムでは、ESMが標準として普及しつつありますが、多くの既存ライブラリやプロジェクトがCommonJSで書かれており、この「二重構造」が開発者にとって注意すべき点となっています。

例えば、ライブラリを利用する際には「そのライブラリがCommonJSとESM、どちらの形式で(あるいはどちらの形式でも)提供されているか」を意識する必要があります。
当面はこれら両方のモジュールシステムを理解し、状況に応じて適切に使い分ける必要があります。
また、CommonJSとESMを混在させる場合は、相互運用のための特別な構成やツールが必要になることがあります。

まずCommonJSについて見ていきましょう。

## CommonJS

CommonJS による別ファイルの読み込みを試してみましょう。

```js
// required.js

module.exports = () => {
  console.log('require OK!');
}
```

```js
// requiring.js

const requiredFunction = require('./required');

requiredFunction();
```

注意すべき点は `required.js` と `requiring.js` を同じディレクトリに置いておくことです。

```
node requiring.js
```

を実行すると require OK! が出力されます。

この `module.exports =` と `require()` が CommonJS の仕組みです。
この仕組みを使うと、公開されているライブラリをインストールして使うことができます。

[Day.js](https://day.js.org) という日付時間を便利に扱えるライブラリが公開されているので、これをインストールして使ってみましょう。

```
$ npm install dayjs
```

```js
// hello_dayjs.js

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

## ES Module

ESM も基本的な仕組みは `require` と同じ仕組みで、 `module.exports =` で公開していたものが `export` という予約語になります。

```js
// exporting.js

// default export
export default function foo() {
  console.log('foo');
}

// named export
export function bar() {
  console.log('bar');
}
```

```js
// importing.js

import foo, { bar } from './exporting.js';

foo();
bar();
```

なお、このコードを`node importing.js`で実行すると、以下のようにWariningが発生します。

```
>>> % node importing.js
(node:16940) [MODULE_TYPELESS_PACKAGE_JSON] Warning: Module type of file:///path/to/importing.js is not specified and it doesn't parse as CommonJS.
Reparsing as ES module because module syntax was detected. This incurs a performance overhead.
To eliminate this warning, add "type": "module" to /path/to/package.json.
```

node.jsがはじめにjsファイルをCommonJSとして認識したあとに、ESMの構文を検知し、再評価したことを示しています。


これを回避するためには以下のいずれかの方法があります：
1. `package.json`に `"type": "module"` を追加してプロジェクト全体をESMとして認識させる：
```json
{
  "type": "module"
}
```
2. ファイル名を`.mjs`拡張子に変更して、ES Moduleのファイルであることを明示的に示す（`exporting.mjs`, `importing.mjs`にリネーム）。

その後、`node importing.mjs`を実行すれば、エラーが起こることなくコードが実行できます。

## モジュールバンドラー

ESMはブラウザでも実行できます。以下のようにコーディングしてみましょう。

```html
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <title>ES Modules Demo</title>
</head>
<body>
  <h1>ES Modules in Browser</h1>
  
  <script type="module">
    // インラインでモジュールをインポートする方法
    import foo, { bar } from './exporting.js';
    
    foo();
    bar();
  </script>
  
  <!-- 別ファイルのスクリプトとしてモジュールをインポートする方法 -->
  <script type="module" src="./importing.js"></script>
</body>
</html>
```

以下のコマンドで開発サーバを起動してアクセスすると、Node.jsで実行したときと同様に動作することを確認できます。

```
npx serve
```

(このコマンドは、[serve](https://www.npmjs.com/package/serve) というパッケージを取得した上で実行するものです。
npxコマンドは対象のパッケージがインストールされていなければパッケージレジストリから取得するので、信頼できるパッケージかどうかを確認してから実行しましょう。)

ブラウザの開発者ツール等で確認すると、ESMの `import` 文の数だけJavaScriptをリクエストしていることが分かると思います。
ウェブアプリケーションは多くのモジュールで構成されることが多いので、都度HTTPリクエストを実施するのはパフォーマンス面で懸念があります。
そこで、各ファイルをいくつかのファイルにまとめて配布することが広く行われています。

1. 各ファイルを一つのファイルに結合する。
2. `export` したいファイルの中身を function としてラップし、 `export` するもの以外は外部からアクセスできないようにする。
3. `export` した内容を一時的に保管し、 `import` されたらアクセスできるようにする領域を設ける。
4. `export` `import` コードを置き換え、それぞれ指定したものにアクセスできるようにする。

これらを機械的に行うツールとして、[Webpack](https://webpack.js.org) や [Rollup](https://rollupjs.org/) などのモジュールバンドラーが存在します。

モジュールバンドラーはプラグインシステムを有しているものもあり、変換の過程でファイルコンテンツに関与することができます。
たとえば以下のことも実施できます。

- トランスパイル(前章を参照)
- mangle (非公開の変数を短くすることでファイルサイズを小さくする)
- [tree-shaking](https://rollupjs.org/faqs/#what-is-tree-shaking) (依存していないモジュールを除外してバンドルすることでファイルサイズを小さくする)
- AltJS (後述) -> JavaScript への変換
- AltCSS (たとえばSassなど) -> CSS への変換
- JSX -> JavaScriptへの変換
- 画像などのJavaScriptではないアセットのモジュール解決とバンドリング
- などなど...

このように、単にファイルをひとまとめにするだけではなく、実行環境にあわせたソースコードの変換やパフォーマンス向上のための圧縮といった様々なビルド処理を有していることが多いです。

何らかのアプリケーションフレームワークを利用する場合、多くは開発環境セットアップツールによってこれらのツールが自動でインストールされます。
(たとえば、近年よく利用されている[Vite](https://ja.vite.dev/guide/)では、Rollupを用いて上記のような処理を実施しています)

## TypeScript

ペパボ社のプロダクトでは、[TypeScript](https://www.typescriptlang.org/) を活用しています。

TypeScriptはAlternative JavaScript(=AltJS)のひとつであり、JavaScriptに追加の構文を提供することで型を提供する言語です。

TypeScriptが提供する一部の機能を除き、基本的には型情報を取り除けばJavaScriptとして解釈できることが特徴です。
ブラウザをはじめとした一部の実行環境はTypeScriptを直接解釈できないため、`tsc` あるいはモジュールバンドラーを用いて型情報を取り除くことで対応しています。

以下は基本的なTypeScriptの例です。

```typescript
// 型付き変数
let name: string = "John";
let age: number = 30;

// 型付き関数
function greet(person: string): string {
  return `Hello, ${person}!`;
}

// インターフェース
interface User {
  id: number;
  name: string;
  email?: string; // オプショナルプロパティ
}

// インターフェースを使用
const user: User = {
  id: 1,
  name: "Alice"
};
```

以降のハンズオンでも活用する機会があります。
[TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html)を見ながら、[TypeScript Playground](https://www.typescriptlang.org/play/) で試行して習得するとよいです。

(TypeScriptの習熟度をチェックできる学習コンテンツとして https://github.com/type-challenges/type-challenges にチャレンジしてみるのもよいでしょう。)

## JSX / TSX

以降のハンズオンでは、[JSX](https://ja.react.dev/learn/writing-markup-with-jsx) (あるいはTypeScriptベースのJSXであるTSX) を活用します。

これも主にモジュールバンドルの過程でJavaScript(たとえば[ReactのcreateElement()](https://ja.react.dev/reference/react/createElement#creating-an-element-without-jsx)や[VueのRender Function](https://ja.vuejs.org/guide/extras/render-function#render-functions-jsx))に変換されます。
(ReactやVue.jsでは、[Virtual DOM](https://ja.vuejs.org/guide/extras/rendering-mechanism#virtual-dom) と呼ばれる技術によって要素をレンダリングしています。JSXはVirtual DOMをインスタンス化するための関数に変換されるのです)

多くのモジュールバンドラーでJSXを取扱できますが、モジュールバンドラーとしての機能も有している[swc](https://swc.rs/) が提供している[Playground](https://play.swc.rs) で、JSXをJavaScriptのReact APIの利用に変換する様子を確認できます。

## 練習問題

1. 型検査やトランスパイラの役割を持つTypeScript公式のツール `tsc` をインストールし、TypeScriptを記述したあと、JavaScriptに変換してNode.jsで実行してみましょう(なお、2025年現在、Node.jsでも[TypeScriptファイルを直接実行するための機能が実験的に導入](https://nodejs.org/ja/learn/typescript/run-natively)されています)
1. モジュールバンドラーの項で簡単に説明した、JavaScriptや画像などのアセットを効率良く配信するための技術について整理してみましょう。

### おかわり

1. 何らかのモジュールバンドラーを選択し、複数のJavaScriptあるいはTypeScriptをバンドルしてみましょう。また、バンドルしたファイルをブラウザで実行してみましょう。
