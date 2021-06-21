# 第 22 章　Vue でページ移動を作る

{% raw %}

20 章で Gravatar の画像を表示した際、 `<a href="/users/1">` のようなリンクを作成しました。このままでは、この画像をクリックした時には一旦ページを離れて、 Rails が出力した `/users/1` の HTML を取得し、その内容を表示してしまいます。しかし、共通部分を除いて JavaScript でページの内容だけを書き換えた方が、よりスムーズなレスポンスになるとは感じないでしょうか。このようなページ自体の遷移をなくして JavaScript によるページ書き換えと URL を対応させたのが、 Single Page Application (SPA) です。

## 練習問題 1

自分のユーザ情報を取得する `/me.json` `StaticPagesController#me` という API を作成して、ログイン後トップ画面左側のアカウント情報を表示している部分を Vue に置き換えてください。

## JavaScript での URL 処理

Rails が生成するオールドスタイルな web アプリケーションでは、基本的に一つの URL が一つのページに対応していました。例えば以下の通りです。

* `/` => トップページ
* `/users/:id` => ID に該当するユーザプロフィールページ

SPA でも、現時点で表示している内容に対応する URL をブラウザに認識させたいという要望があります。例えば、トップページからユーザプロフィールページに JavaScript で書き換えたとして、ブラウザバックでトップページに戻れないとなるととても不便です。[現在の JavaScript](https://developer.mozilla.org/ja/docs/Web/Guide/DOM/Manipulating_the_browser_history#履歴エントリの追加と修正) には `pushState` によるブラウザ URL の書き換えや、 `onpopstate` というフックにより URL の変化からの処理実行があります。

しかし、 `pushState` での URL 書き換えを画面の変更に合わせて書くのは非常に煩雑なので、 Vue での URL 制御は [Vue Router](https://router.vuejs.org/ja/) というライブラリを使うことで便利に取り回すことができます。

## Hello, Vue Router

それでは、 Vue Router を始めましょう。まずは移動先としてメッセージを表示するだけの SFC を作ります。そしてそれを Vue Router で接続します。

```vue:app/javascripts/packs/HelloVueRouter.vue
<template>
  <div>Hello, Vue Router!</div>
</template>

<script>
export default {
};
</script>
```

```erb:app/views/static_pages/home.html.erb
<% # 略 %>
<div id="app">
  <% # 以下を追記します %>
  <router-view></router-view>
</div>
```

```js:app/javascripts/packs/index.js
import 'core-js/stable';
import 'regenerator-runtime/runtime';
import Vue from 'vue/dist/vue';
import VueRouter from 'vue-router';
import Home from './Home.vue';
import HelloVueRouter from './HelloVueRouter.vue';

Vue.use(VueRouter);

const routes = [
  { path: '/hello', component: HelloVueRouter },
  { path: '/', component: Home }
];

const router = new VueRouter({
  routes  // routes: routes と同じ
})

document.addEventListener('DOMContentLoaded', () => {
  new Vue({ router }).$mount('#app');
});
```

画面を再読み込みすると、 `http://0.0.0.0:3000/#/` という URL になって、先ほどと変わらない画面が出力されます。この `#/` という部分は `pushState` に対応していない古いブラウザ対策として使われており、後ほどこれを普通の URL へと置き換えるコードを書きます。ひとまずは HelloVueRouter コンポーネントが表示されるかを確認しましょう。 [http://0.0.0.0:3000/#/hello](http://0.0.0.0:3000/#/hello) にアクセスすると、 HelloVueRouter コンポーネントがレンダリングされていることが確認できます。

それでは Home コンポーネントから HelloVueRouter コンポーネントへのリンクを作成してみましょう。 Vue Router を有効化すると、 `<router-link>` というコンポーネントが使えるようになります。 Home コンポーネントのテンプレートに `<router-link to="/hello">Say Hello</router-link>` と記述して [http://0.0.0.0:3000/](http://0.0.0.0:3000/) を読み込むと、リンクが作成されていることがわかります。実際にリンクをクリックすると、表示が Hello, Vue Router! に切り替わって URL も `#/hello` になることが確認できますね。このままブラウザバックをすると、 Home コンポーネントに戻ることもできます。

## `pushState` に対応させる

このままでも SPA としては十分に機能しますが、 URL に `#` が入ってしまいあまりクールではないですね（これは個人の感想であり、効果・効能を示すものではありません）。このような特殊な URL ではなく通常の URL でこの Micropost SPA を操作できるようにしましょう。 Vue Router には `pushState` を使って URL を操作する　[HTML5 History モード](https://router.vuejs.org/ja/guide/essentials/history-mode.html) が存在しています。これは `VueRouter` の設定に `mode: 'history'` を設定するだけで動作します。確かめてみましょう（ブラウザを立ち上げ直さないと HTML5 History モードが有効にならないかも）。

しかし、これでは想定しない動作を Rails サーバ側が起こしてしまうようになります。これまで `#/` 形式の URL では `#` 以降は URL の path とは違う部分と認識されているので、 Rails 側では処理されない内容となっていました。 HTML5 History モードを有効化すると、これまで http://0.0.0.0:3000/#/hello として処理されていた URL は http://0.0.0.0:3000/hello として扱われるようになるので、ブラウザをリロードすると Rails 側でそのような route は存在しないというエラーが発生してしまいます。そこで、 Rails で処理できない URL へのリクエストも `StaticPagesController#home` へと到達させるようにします。

```ruby
# config/routes.rb

Rails.application.routes.draw do
  # 最終行に追加
  get '*any', to: 'static_pages#home'
end
```

これで [http://0.0.0.0:3000/hello](http://0.0.0.0:3000/hello) にブラウザで直接アクセスしても、 Rails 側でエラーが出ることなく HelloVueRouter コンポーネントが表示できるようになると思います。

実際の SPA 開発では、 Vue Router 側で、定義されていないルートにアクセスされた際に 404 Not Found であることを示すルートを定義します。以下のようなコードになりますが、今回は省略します。

```js
const router = new VueRouter({
  mode: 'history',
  routes: [
    { path: '*', component: NotFoundComponent }
  ]
});
```

## 動的ルートマッチング

[この説明で十分なのでここ見て](https://router.vuejs.org/ja/guide/essentials/dynamic-matching.html)

## 練習問題 2

ユーザの情報を表示する `UserProfile.vue` コンポーネントを作成し、これを `/user_profiles/:id` でルーティングできるようにして、 Gravatar の画像をクリックしたらこのコンポーネントを表示するようにしてください。

## 次回予告

いよいよ次が最後の章になりました。これまで開発してきた SPA on Rails を本番環境へとデプロイし、実際に動くことを確認します。

{% endraw %}
