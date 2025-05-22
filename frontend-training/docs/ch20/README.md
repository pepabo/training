# 第 20 章　React でページ移動を作る

{% raw %}

20 章で Gravatar の画像を表示した際、 `<a href="/users/1">` のようなリンクを作成しました。このままでは、この画像をクリックした時には一旦ページを離れて、 Rails が出力した `/users/1` の HTML を取得し、その内容を表示してしまいます。しかし、共通部分を除いて JavaScript でページの内容だけを書き換えた方が、よりスムーズなレスポンスになるとは感じないでしょうか。このようなページ自体の遷移をなくして JavaScript によるページ書き換えと URL を対応させたのが、 Single Page Application (SPA) です。

## JavaScript での URL 処理

Rails が生成するオールドスタイルな web アプリケーションでは、基本的に一つの URL が一つのページに対応していました。例えば以下の通りです。

* `/` => トップページ
* `/users/:id` => ID に該当するユーザプロフィールページ

SPA でも、現時点で表示している内容に対応する URL をブラウザに認識させたいという要望があります。例えば、トップページからユーザプロフィールページに JavaScript で書き換えたとして、ブラウザバックでトップページに戻れないとなるととても不便です。

[History API](https://developer.mozilla.org/ja/docs/Web/API/History_API) には `pushState` によるブラウザ URL の書き換えや、 `onpopstate` というフックにより URL の変化からの処理実行があります。

しかし、 `pushState` での URL 書き換えを画面の変更に合わせて書くのは非常に煩雑です。React での URL 制御を便利に取り回すライブラリとして今回は [React Router](https://reactrouter.com/web/guides/quick-start) を使ってみましょう。

## Hello, React Router

それでは、 React Router を始めましょう。 `react-router-dom` をインストールします。適宜、[React Routerの公式ページ](https://reactrouter.com/en/main)を確認して進めてみましょう。

```bash
npm i -E react-router-dom@6.23.1
```

まずは移動先としてメッセージを表示するだけのコンポーネントを作ります。そしてそれを React Router でルーティングします。

```tsx
// app/javascript/components/HelloRouter.tsx
import React from "react";

const HelloRouter = () => {
  return <>Hello, Router!</>;
};

export default HelloRouter;
```

```tsx
// app/javascript/components/index.tsx

import { BrowserRouter, Link, Routes, Route } from "react-router-dom";
import HelloRouter from "./HelloRouter";
import { Home } from "./static-pages";
import React from "react";

const App = () => {
  return (
    <BrowserRouter>
      <nav>
        <ul>
          <li>
            <Link to="/">Home</Link>
          </li>
          <li>
            <Link to="/hello">Say Hello Router</Link>
          </li>
        </ul>
      </nav>

      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/hello" element={<HelloRouter />} />
      </Routes>
    </BrowserRouter>
  );
};

export default App;
```

画面を再読み込みすると、画面上部に新たにリンクが2つ表示されています。 `<Link>` コンポーネントは画面遷移が React Router によって制御される `<a>` タグ（本物の `<a>` タグ）をレンダーします。
`<Route>` コンポーネントは `path` 属性に URL のパスを指定し、そのパスにおいて描画したいコンポーネントをelementで指定して書きます。

`<Route>` コンポーネントたちの親にさらに `<Routes>` コンポーネントがあると、パスに最初に合致したコンポーネントだけが描画されるようになります（ `<Routes>` が無いとパスが合致したコンポーネントすべてが描画されるのです。詳しくは [公式APIドキュメント](https://reactrouter.com/en/main/components/routes#routes) を読んでください）。

さて、画面に表示されたリンクを何回かいろいろクリックしてみて、画面が素早く遷移することを確認してください。
また開発者コンソールの Network タブを確認すると、 `/hello` へのリンクをクリックしても実際にサーバにリクエストは送られていないこともわかると思います。

しかしこのままでは想定しない動作を Rails サーバ側が起こしてしまうようになります。URL が http://localhost:3000/hello となった状態でブラウザをリロードすると、 Rails 側でそのような route は存在しないというエラーが発生してしまいます。そこで、 Rails で処理できない URL へのリクエストも `StaticPagesController#home` へと到達させるようにします。

```ruby
# config/routes.rb

Rails.application.routes.draw do
  # 最終行に追加
  # ただし /rails 以下は特別な意味を持つので :any としてはルーティングさせない
  scope ':any', as: :any, constraints: { any: /(?!rails\/).*/ } do
    root to: 'static_pages#home'
  end
end
```

これで [http://localhost:3000/hello](http://localhost:3000/hello) にブラウザで直接アクセスしても、 Rails 側でエラーが出ることなく HelloRouter コンポーネントが表示できるようになると思います。

さらに React Router 側でも、定義されていないルートにアクセスされた際にページが存在しないことをユーザに伝えるようなコンポーネントを用意しておきます。

```tsx
// app/javascript/components/PageNotFound.tsx
import React from "react";

const PageNotFound = () => {
  return <>Page Not Found.</>;
};

export default PageNotFound;
```

```tsx
// app/javascript/components/index.tsx

import { BrowserRouter, Link, Routes, Route } from "react-router-dom";
import HelloRouter from "./HelloRouter";
import { Home } from "./static-pages";
import React from "react";
import PageNotFound from "./PageNotFound";

const App = () => {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/hello" element={<HelloRouter />} />
        <Route path="*" element={<PageNotFound />} />
      </Routes>
    </BrowserRouter>
  );
};

export default App;
```

## useParams

`Route` の `path` にはパラメータを指定することもできます。

```diff
--- a/app/javascript/components/index.tsx
+++ b/app/javascript/components/index.tsx
@@ -1,6 +1,7 @@
 import { BrowserRouter, Link, Switch, Route } from "react-router-dom";
 import PageNotFound from "./PageNotFound";
 import { Home } from "./static-pages";
+import UserProfle from "./user-profiles/UserProfile";

 const App = () => {
   return (
@@ -9,6 +10,9 @@ const App = () => {
         <Route path="/" element={<Home />} />
+        <Route path="/user_profiles/:id" element={<UserProfile />} />
         <Route path="*" element={<PageNotFound />} />
```

パラメータの具体的な値は [useParams](https://reactrouter.com/web/api/Hooks/useparams) フックを使って取得できます:

```tsx
// app/javascript/components/user-profiles/UserProfile.tsx

import { useParams } from "react-router-dom";

type Params = {
  id: string;
}

const UserProfle = () => {
  const { id } = useParams<Params>();

  return <>User id: {id}</>;
};

export default UserProfle;
```

`GravatarImage` の ``<a href={`/users/${props.user.id}`}>`` タグを ``<Link to={`/user_profiles/${props.user.id}`}>`` に変えて、 Gravatar の画像をクリックしたら画面遷移ができること、かつパスの `:id` 部分の値に応じた表示になっていることを確かめてみてください。

## 練習問題

できる範囲で構わないので、 Rails が `/users/:id` で表示していたのと同等の画面を `UserProfile.tsx` で作ってください。

{% endraw %}
