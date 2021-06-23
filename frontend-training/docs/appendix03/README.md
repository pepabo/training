# 付録 3　TypeScript

18章の練習問題に取り組んだ際、配列の `map()` に渡すコールバック関数の引数にはどんな値が入ってくるんだっけとか、 `species` のような複雑なプロパティ名をtypoしてしまわないかとか、猫のみを表示するボタンのロジックを書くときに間違って `kitten` のみを表示するコードを書いてしまわないかとか、いろいろな不安を感じませんでしたか？
そして、そういった類のミスを犯してしまったとき、そのミスは実際にブラウザ上でJavaScriptのコードを **実行** して初めて発覚するものであったはずです。

JavaScriptで書かれたプログラム内のある種の不整合を、 **型システム** の力によって、プログラムが実際に実行される前に **静的に** 検査することを目的とした言語が [TypeScript](https://www.typescriptlang.org/) です。

TypeScriptはJavaScriptのスーパーセットを謳っています。つまり、validなJavaScriptコードはすべてTypeScriptのコードです。JavaScriptで書かれた既存のプロジェクトのうちの一部のファイルからTypeScriptに移行していくことも可能になっています。

TypeScriptは **静的型付き** 言語です。ところで「型」とはなんでしょうか？大雑把には、「値の分類」のことだと言えるかもしれません。TypeScriptにおいて例えば `"Hello World"` という文字列は `string` 型に分類されます。そして `string` 型の値に対しては例えば `split()` というメソッドを使えるという規則が型のレベルで存在します。TypeScriptの **コンパイラ** はTypeScriptのコードを解析して、規則に違反した操作が行われていないかを **コンパイル時に** （**静的に**）検査してくれるのです。

TypeScript自体への入門については公式ドキュメントの [TypeScript for the New Programmer](https://www.typescriptlang.org/docs/handbook/typescript-from-scratch.html) や [TypeScript for JavaScript Programmers](https://www.typescriptlang.org/docs/handbook/typescript-in-5-minutes.html) などにお任せすることにして、この付録ではこの入門記事で扱っているReact on RailsプロジェクトにTypeScriptを導入することを主眼として話を進めたいと思います。

そもそもフロントエンド研修という入門的なテキストの性格上TypeScriptの導入まで紹介すべきか否か（型が付かない素のJavaScriptのままでもとりあえず入門記事としては構わないのでは？）という議論ももしかしたらあるかもしれませんが、2021年現在の状況において、実務でJavaScriptを触るということは必然的にTypeScriptも触ることを意味すると言ってまず差し支えないでしょう（まだJavaScriptのままのコードが残っているプロジェクトももちろんたくさんあると思いますが、そういった環境でも少なくとも「TypeScriptにしていきたいよね〜」という気持ちが同じチームのエンジニア間では共通認識として持たれているのではないかと推察します）。もっと言えば2019年の時点で

>「TSを導入すべきか」で悩む時代は既に終わっている
> https://speakerdeck.com/itkrt2y/sabasaidoenziniamozhi-tuteokubekihurontoendofalsejin?slide=8

と言われて久しいのです。ですからこのテキストでTypeScriptの導入まで行うことは（歴史的な順序により付録の章に書いていますが）むしろ必須であると個人的には考えています。

といっても導入自体はそれほど難しくはありません。まずTypeScript本体は `npm` コマンドで簡単にインストールできます:

```bash
npm i -D typescript
```

それからReactの「型定義」というものもNPMで公開されています。これもインストールしてください:

```bash
npm i -D @types/react @types/react-dom
```

先ほどTypeScriptの「コンパイラ」と書きました。TypeScriptのコンパイラはTypeScriptコードの型検査を行ってくれますが、TypeScriptのコードをJavaScriptへとコンパイル（トランスパイル）もしてくれるのです。
ところでRails Tutorial第6版を終えた私たちの手元には既にBabelがあるのでした。実は2018/8/28に [`@babel/preset-typescript` (v7.0.0)](https://www.npmjs.com/package/@babel/preset-typescript/v/7.0.0) というBabelのpresetがリリースされていて、こちらを使うとBabelでもTypeScriptのコードをJavaScriptへとトランスパイルすることができます（ただしBabelには型検査機能は無いので単に構文を変換する処理だけが行われます）。

TypeScriptコンパイラによるトランスパイルとBabelによるトランスパイル、いったいどちらを使えば良いのでしょうか？その答えは、一般的には [場合による](https://www.typescriptlang.org/docs/handbook/babel-with-typescript.html) としか言えませんが、私たちの場合について言えばRails 6が吐いてくれたBabelの設定が既にあるので、このパイプラインをそのまま使い続けるということで良いでしょう。

```bash
npm i -D @babel/preset-typescript
```

`@babel/preset-typescript` をインストールしたら `babel.cofig.js` の `presets` の末尾に追加しましょう:

```diff
--- a/babel.config.js
+++ b/babel.config.js
@@ -40,7 +40,8 @@ module.exports = function(api) {
         {
           'runtime': 'automatic'
         }
-      ]
+      ],
+      ['@babel/preset-typescript']
     ].filter(Boolean),
     plugins: [
       'babel-plugin-macros',
```

さて、TypeScriptプロジェクトにも設定ファイルがあります。以下のコマンドを実行してみてください:

```bash
npx tsc --init
```

すると `tsconfig.json` というファイルが生成されると思います。これがその設定ファイルです。

基本的に `tsc --init` で生成されるデフォルトの設定のままで良いと思いますが、以下に示した箇所だけ変更してください:

```json
{
  "compilerOptions": {
    // ...

    /* Basic Options */
    "module": "esnext",
    "allowJs": true, /* もし余力があったら allowJs をコメントアウトするチャレンジもやってみてください */
    "jsx": "react-jsx",
    // ...

    /* Strict Type-Checking Options */
    "strict": true,
    // "noImplicitAny": true, /* 場合によっては false にしても良いかもしれない… */
    // ...

    /* Module Resolution Options */
    "moduleResolution": "node",
    "baseUrl": "./app/javascript/",
    // ...
  },
  "include": [
    "app/javascript/**/*"
  ]
}
```

各オプションの詳しい意味を知りたい方は [リファレンス](https://www.typescriptlang.org/tsconfig) を読んでみてください。

ここまでできたらいよいよ既存のJavaScriptのファイルをTypeScriptのファイルに変更していきましょう。
TypeScriptのファイルの拡張子は `.ts` です。 `.js` ファイルをTypeScriptのファイルに変更しようと思ったら基本的にまず `.js` を `.ts` に書き換えるのです。同様に `.jsx` ファイルは `.tsx` に拡張子を変更します。

`app/javascript/components/index.jsx` というファイルを作っているはずですから、それを `app/javascript/components/index.tsx` にリネームしてください。

そして一応この時点でwebpackでもバンドルできるようにしておきましょう。 `webpack.config.js` で `babel-loader` を使っている `module.rules.test` の箇所と `resolve.extensions` を以下のように変更してください:

```diff
--- a/webpack.config.js
+++ b/webpack.config.js
@@ -14,7 +14,7 @@ module.exports = {
   module: {
     rules: [
       {
-        test: /(\.m?js|\.jsx)$/,
+        test: /(\.m?js|\.tsx?)$/,
         exclude: /(node_modules|bower_components)/,
         use: {
           loader: 'babel-loader',
@@ -25,7 +25,7 @@ module.exports = {

   resolve: {
     modules: ['node_modules', path.resolve(__dirname, 'app/javascript')],
-    extensions: ['.js', '.jsx', '.json', '.wasm'],
+    extensions: ['.js', '.jsx', '.ts', '.tsx', '.json', '.wasm'],
   },

   plugins: [
```

`npm run watch` してエラーが出ずにバンドルできていればwebpackの設定はOKです。

（ちなみに今回はBabelをトランスパイラとして使うので `.ts` `.tsx` ファイルを `babel-loader` で処理するように設定しましたが、BabelでなくTypeScriptでトランスパイルを行う場合は [ts-loader](https://github.com/TypeStrong/ts-loader) というloaderを使います。覚えておくと役に立つときが来るかもしれません。）

`npm run watch` でエラーが出ていないとしても `app/javascript/components/index.tsx` をエディタで開くとエディタ上では何箇所か怒られている部分があるかもしれません。おそらく `Showcase` コンポーネントに渡している `props` の型が不明なので怒られているでしょう。

（注意：エディタに関して今まで触れてきませんでしたが、JavaScript / TypeScriptのコードを書くにあたっては、特別に強いこだわりがなければ [Visual Studio Code](https://code.visualstudio.com/) の利用をおすすめします。自分はTypeScript Language Serverを使ってやっていくんだという *強い気持ち* がないのであれば、普段別のエディタが手に馴染んでいるという方でもJavaScript / TypeScriptを書くときだけVisual Studio Codeを使うほうが無難であると思います。）

`props` はJavaScriptのオブジェクトなので、 [オブジェクトの構造を `interface` 宣言で記述](https://www.typescriptlang.org/docs/handbook/typescript-in-5-minutes.html#defining-types) してみましょう。 `props` のプロパティとしては `name`, `answer`, `items` がありますね。 `name` と `answer` は簡単そうなのでとりあえず `const Showcase = ...` の前の行にちょっと書いてみましょう:

```ts
interface Props {
  name: string;
  answer: number;
}
```

`items` をよく観察すると、これは `id`, `name`, `price` というプロパティを持つオブジェクトの配列になっています。そこで `Props` とは別に

```ts
interface Item {
  id: number;
  name: string;
  price: number;
}
```

を定義してやれば、 `Props` は

```ts
interface Item {
  id: number;
  name: string;
  price: number;
}

interface Props {
  name: string;
  answer: number;
  items: Item[];
}
```

と定義できるでしょう。これでもう完成したも同然です。関数の引数の型注釈は `(引数名: 型名)` という記法で書けるので、

```ts
const Showcase = (props: Props) => {
  // ...
}
```

これでTypeScriptコンパイラからの警告が消えるでしょう。

このように **型注釈** をプログラマーが手で書く必要が生まれる場面に出くわすことがあります。しかし大抵の場合においては、TypeScriptコンパイラに備わっている **型推論** 機能のおかげで、プログラマーが明示的に型注釈を書く必要はありません。たとえば

```js
const [isVisible, setIsVisible] = useState(true);
```

という行があると思いますが、ここでは `useState` に `true` を渡していることによって、何も書かなくても自動的に `isVisible` は `boolean` 型の変数であり、 `setIsVisible` は「 `boolean` 型の変数を引数に取る関数」であることが推論されるのです。なので例えば `setIsVisible(42)` などというコードを書くとTypeScriptに怒られることがわかるでしょう。

さて最後に、先ほどTypeScriptからのコンパイルエラーは出ていたのにも関わらず `npm run watch` は成功していたという事実を思い出してください。この理由はもちろん、BabelによるTypeScriptのトランスパイルでは型検査まではできないからです。しかしコンパイルエラーとなるコードは `main` （または `master`）ブランチにはマージしたくないですね。

そこでよく取られる分業法は、Babelにトランスパイルは任せつつ、CIの段階で型検査だけをTypeScriptコンパイラが行ってエラーを検知するという方法です。TypeScriptコンパイラである `tsc` コマンドには `--noEmit` というオプションがあり、これは「型検査は行うけどトランスパイル結果等の成果物は生成しない」というものです。手元で試してみてください:

```bash
npx tsc -p . --noEmit
```

特に何も表示されなければコンパイルエラーは無かったということです。何か良くないコードをわざと書いてから同じコマンドを実行するとどうなるか試してみてください。

## 練習問題

1. TypeScriptコンパイラによる型検査を行い、コンパイルエラーであったらfailするようなGitHub Actionsの設定を書いてください（もしかしたら [self-hosted runner を追加](https://docs.github.com/ja/actions/hosting-your-own-runners/adding-self-hosted-runners) する必要があるかもしれません。もし追加できなさそうであればこの課題は飛ばしてしまってください）。

1. （高度）第18章の練習問題で作ったコンポーネントファイルを `.tsx` に変更して、コンパイルエラーが出ないように修正してください。
