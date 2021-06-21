# 第 18 章　React 開発ことはじめ

{% raw %}

それでは、いよいよ React を使っての開発に入ります。 NPM を使って `react` `react-dom` パッケージをインストールしてください。

また Babel で React のコードを扱えるように `@babel/preset-react` もインストールしてください:

```bash
npm i -D -E @babel/preset-react@7.14.5
```

同時に `babel.config.js` と `webpack.config.js` も React のコードを扱うように設定を更新します:

```diff
--- a/babel.config.js
+++ b/babel.config.js
@@ -34,6 +34,12 @@ module.exports = function(api) {
           modules: false,
           exclude: ['transform-typeof-symbol']
         }
+      ],
+      [
+        '@babel/preset-react',
+        {
+          'runtime': 'automatic'
+        }
       ]
     ].filter(Boolean),
     plugins: [
```

```diff
--- a/webpack.config.js
+++ b/webpack.config.js
@@ -14,7 +14,7 @@ module.exports = {
   module: {
     rules: [
       {
-        test: /\.m?js$/,
+        test: /(\.m?js|\.jsx)$/,
         exclude: /(node_modules|bower_components)/,
         use: {
           loader: 'babel-loader',
@@ -25,7 +25,7 @@ module.exports = {

   resolve: {
     modules: ['node_modules', path.resolve(__dirname, 'app/javascript')],
-    extensions: ['.js', '.json', '.wasm'],
+    extensions: ['.js', '.jsx', '.json', '.wasm'],
   },

   plugins: [
```

ここまでできたら `app/javascript/components` というディレクトリを作り、 `app/javascript/components/index.jsx` という名前のファイルを作成してください。その中に以下のようなコードを書いてみましょう:

```jsx
const App = () => {
  return <p>Hi, I'm Pepayama Botaro!</p>;
};

export default App;
```

このコードの真ん中あたりにある HTML のような構文は [JSX](https://ja.reactjs.org/docs/introducing-jsx.html) と呼ばれるものです。

この `App` を `app/javascript/packs/application.js` から使うようにしてみましょう:

```js
import Rails from "@rails/ujs"
import ReactDOM from "react-dom"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import "jquery"
import "bootstrap"
import App from "components"

Rails.start()
Turbolinks.start()
ActiveStorage.start()

document.addEventListener("DOMContentLoaded", () => {
  ReactDOM.render(<App />, document.getElementById("app"))
})
```

[`ReactDOM.render`](https://ja.reactjs.org/docs/react-dom.html#render) という API を使っていますね。これで `id="app"` な DOM 要素の中に `App` を描画するのだ、というぐらいに思ってください。

では `app/views/layouts/application.html.erb` の `yield` の前あたりにでもそんな要素を置いて、 React を組み込んでみましょう。

```erb
<% # 略 %>
<div id="app"></div>
<%= yield %>
```

それでは実際にページをロードして、画面に "Hi, I'm Pepayama Botaro!" が表示されることを確認してみましょう（`npm run watch` を実行しつつ、端末の別セッションで Rails サーバを起動してください（HMR についてはとりあえず考えないことにします））。

このように、 `APP` が返していた JSX （が生成する "React 要素"）が実際の要素となって画面に表示されるのです。
React 要素を返す関数は **React コンポーネント** （または単に「コンポーネント」、あるいは関数であることを特に強調したいときは「関数コンポーネント」）と呼ばれます。

コンポーネントは引数（慣習的に `props` という引数名がよく使われます）を取ってそれを JSX の中で利用することができます。試してみましょう:

```jsx
const Showcase = (props) => {
  const nameLengthThreshold = 8;

  return (
    <>
      {/* 中括弧の中で props の値が使えます: */}
      <p>Hi, I'm {props.name}!</p>

      {/* props の値だけでなく、中括弧の中ではあらゆる JavaScript の式が使えます: */}
      <p>
        The answer is {props.answer}, so the doubled answer is{" "}
        {props.answer * 2}.
      </p>

      {/* 論理積演算子 && を使って、条件によって要素の表示と非表示を切り替えたり: */}
      {props.isVisible && <p>This is Visible.</p>}

      {/* 三項演算子を使って、条件によって表示する要素を出し分けたりできます: */}
      {props.name.length >= nameLengthThreshold ? (
        <p>name.length is equal or longer than {nameLengthThreshold}.</p>
      ) : (
        <p>name.length is less than {nameLengthThreshold}.</p>
      )}

      {/* 配列に対して map を使えば複数の要素を描画できます: */}
      <ul>
        {props.items.map((item) => (
          <li key={item.id}>
            {item.name} is {item.price} Yen.
          </li>
        ))}
      </ul>
    </>
  );
};

const App = () => {
  const name = "Pepayama Botaro";
  const answer = 42;
  const isVisible = true;
  const items = [
    {
      id: 1,
      name: "T-shirt",
      price: 100,
    },
    {
      id: 2,
      name: "Hoodie",
      price: 300,
    },
  ];

  return (
    <Showcase
      name={name}
      answer={answer}
      isVisible={isVisible}
      items={items}
    ></Showcase>
  );
};

export default App;
```

`app/javascript/components/index.jsx` を上のように書き換えて、画面をリロードしてみてください。また値をいろいろ変えて、それに対応して表示が変わるか試してみてください。

React の使い方をこれから学ぶにあたり、どうすればやりたいことが実現できるかわからないという時も出てくるかと思いますが、[React のドキュメント](https://ja.reactjs.org/docs/)は大変よくできているので、なるべく一次情報としてこれを見るようにしましょう。

## イベントハンドリングと状態

まずは React を導入してコンポーネントに `props` を渡し、表示するところまで学びました。しかしこれだけでは静的なページとは何も変わらず、フロントエンド開発を行うメリットがありません。そこでユーザのアクションによってページが書き換わる、インタラクティブな要素を導入してみましょう。さきほど `props.isVisible` の値で表示を出し分けていた部分を、ボタンを押すことで表示・非表示が切り替わるようにしたいと思います。

さて、どうすればよいでしょうか。

まずは天下り的ですが `app/javascript/components/index.jsx` の1行目に

```js
import { useState } from "react";
```

と書き、 `useState` を import してください。

次に `Showcase` 内で `return` の前にこんなコードを追加してください:

```js
  const [isVisible, setIsVisible] = useState(true);

  const handleClickVisibilityToggleButton = () => {
    setIsVisible(!isVisible);
  };
```

`isVisible` は `props` として渡されたものを使うのではなく、何やら `useState` が返している変数を使うのです。
そしてボタンを追加します:

```diff
-      {props.isVisible && <p>This is Visible.</p>}
+      {isVisible && <p>This is Visible.</p>}
+      <button onClick={handleClickVisibilityToggleButton}>
+        Toggle visibility
+      </button>
```

これでボタンを押すことで `<p>This is Visible.</p>` の表示・非表示が切り替わる `Showcase` の完成です。 `isVisible` は `props` としては渡さなくなったので `App` 内から `isVisible` は削除してしまってください。

書き換えてページを表示するとボタンがあり、ボタンを押すことでメッセージの表示・非表示が切り替わるようになっているはずです。

一度にたくさんの新しい概念を導入したので詳しく説明していきます。

まずそもそも「ボタンを押すことでメッセージの表示・非表示が切り替わる」とはどういうことでしょうか？それは `Showcase` コンポーネントの内部で「メッセージの視認性」という **状態** が変化する、ということです。変化しうる **状態** と、その状態を更新する関数を作って返してくれるのが `useState` です。今回の例では `isVisible` が状態を保持する変数であり、その更新関数には `setIsVisible` という名前をつけました。そして `useState` に与える引数が状態の初期値となります。今回の例では `true` を渡していたので、画面の初回表示時はメッセージが見える状態から始まっていたということです。

（ちなみに `useState` は React 16.8 で追加された [フック (hook)](https://ja.reactjs.org/docs/hooks-intro.html)という新機能のうちのひとつです。）

これに対して `props` はその値を変更してはいけません。[Props は読み取り専用](https://ja.reactjs.org/docs/components-and-props.html#props-are-read-only) であり、渡された `props` は決して変更してはいけません。React コンポーネントは渡された `props` の値に対しては従順にその値を使って React 要素を作るべきです。React コンポーネントは同じ `props` に対しては（`props` から作られる要素の範囲内で）同じ React 要素を返すべきです。つまり React コンポーネントは `props` に対して純粋関数のように振る舞わなければいけません。React コンポーネントを作る上で、いったいどこまでが外部から入力される決定された値（`props`）でありどれがユーザからのインタラクション等によって変化しうる内部状態（`state`）であるのかを考えることは極めて重要なのでよく覚えておいてください。

そして、「ボタンをクリックする」というようななんらかのイベントに反応するためには `onXXX` 属性を使用します。今回はボタンクリックに反応するので、 `onClick` を使用しています（ちなみに React で利用可能なイベント一覧は [リファレンス](https://ja.reactjs.org/docs/events.html) をご覧ください）。 `onClick` に渡しているコールバック関数 `handleClickVisibilityToggleButton` （JavaScript においてイベントを受け取って処理するコールバック関数のことを特に「イベントハンドラ」と呼ぶことがあります）がクリック時に呼ばれて、 `setIsVisible` が `isVisible` の状態を更新するという寸法です。また、この状態（`isVisible`）の変化は特に表示側に伝えるようなコードがなくても、自動的に表示へと反映されるようになっています。

## 練習問題 1

1. webpack の環境を Rails Tutorial とは別に用意して、 React で以下の `defaultPets` を表形式で表示するコードを書いてください。環境を別に用意することが難しければ今の Rails Tutorial の環境を使い続けても構いません。
1. 表に犬のみを表示するボタン、表に猫のみを表示するボタン、全てのペットを表示するボタンを実装してください（ヒント： `Array` には [`filter()`](https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Global_Objects/Array/filter) というメソッドがあります）。
1. （高度）ドキュメントを調べつつ、犬か猫を選べる新しいペットを登録するフォームを作ってください。新しいペットを登録すると表に追加して表示されるようにしてください。フォームは [制御されたコンポーネント](https://ja.reactjs.org/docs/forms.html#controlled-components) として書いてください。

```js
// index.js

const defaultPets = [
  { name: "Pochi", species: "dog" },
  { name: "Tama", species: "cat" },
  { name: "Mike", species: "cat" },
  { name: "Hachi", species: "dog" },
];
```

## React や Vue の何がかつてのフロントエンドライブラリと比べて優れていたか

練習問題 1-3 のような画面をかつて JavaScript で実装しようとした場合、フォームから取得した値をデータとして持つのではなく、単純に画面に表示する要素として追記していただけでした。しかし、これだと 1-2 のような絞込み機能を実装することがとても難しくなります。仮に `species` を表示要素のどこかに書き込んでおいて、繰り返しでその値をチェックして絞込みの対象でなければ消去するという処理を実装するにしても、「猫絞込み→犬絞込みへの切り替え」「猫絞込み→全件表示」のような 2 アクションの操作に対応しようと思うと、「消去したデータを保管する変数」のようなものを設けなければいけません。今回は単純なアプリケーションですが、これが複雑化して例えばゲームのような画面になった時には、数え切れないほどのパターンの状態と変更が発生するようになります。

このような複雑な UI を実装する手段として、データの状態をどこかに保持しておいて（React の `useState` で作られる変数や、それこそ Vue の `data` のように）、変更があったら UI の方も書き換えるというアプローチが取られるようになりました（ React / Vue の動きに似ていないですか？）。しかし、これを手で実装していた時はいつ UI を書き換えるかも手動で設定しなければならず、その結果として変更の反映がされてないというバグが発生することがありました。それならば、毎秒（ゲームなら毎フレーム）データから UI を生成できればよかったのですが、 JavaScript で UI を書き換えるという処理はとても遅く、毎秒全部書き換えでは非常にストレスフルなアプリケーションが出来上がってしまいます。

先ほど「全部書き換え」と書いたのが要点で、 React や Vue はそこを HTML の構造を模したオブジェクトを作成しデータ変更の前後でどこが書き換わるかを検知し、 UI のその部分のみを置き換えているのです。 JavaScript オブジェクトの比較は UI の直接変更より十分に短い時間でできるので、データが置き換わった時に毎回自動でチェックするようなフックを仕掛けられるようになります。この HTML の構造を模したオブジェクトを **Virtual DOM** と言います。

この思想が優れている点は「宣言的に UI を書ける」ということ、さらに『データから自動で UI を生成できる、そしてその UI は書き換えの回数が最小化される』という考え方が、 Web フロントエンドに限らず UI を備えたスマートフォンのアプリケーションやデスクトップアプリケーションにも応用できるということです。これが [ReactNative](https://facebook.github.io/react-native/) や [Flutter](https://flutter.dev) といったものです。

## 練習問題 2

1. 先ほど作ったペットリストと登録フォームの全体を1つのコンポーネントに切り出してください（すでにそのように実装していればこの問題は飛ばしてください）。
1. これまで作ったペットリストをより小さなコンポーネントの集まりに分割する場合、どこで分割するのが良さそうか考えをまとめてください。

## 次回予告

ついに React を使ってフロントエンドを開発できるようになりました。しかし、そこに流し込みたいデータを Micropost アプリから読み取ることができません。次のチャプターでは Micropost アプリに Web API としての機能を追加し、 React 部分からデータを取得できるようにします。またその前段階として、 Ruby とは違う JavaScript 非同期コールバックモデルとその問題点、その問題点を解消した Promise や async/await について学びます。

{% endraw %}
