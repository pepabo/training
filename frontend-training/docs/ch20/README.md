# 第 20 章　Vue on Rails

{% raw %}

ここまで前提知識のインストールだけでかなりのボリュームになってしまいましたが、全て実際のモダンフロントエンド開発において使う技術なので、駆け足ですが説明してきました。ここからは、それらを使って実際に Rails の上に SPA を組み立てていきます。

## 要件

Rails Tutorial で作成した Micropost アプリケーションを SPA にします。ただし、以下については時間の都合上考えないことにします。

* ログイン機構（ JWT あたりで実装するのですが長くなりすぎる）
* Rails を BFF (Backend for Frontend) にして Nuxt.js のフロントエンドサーバを立てる
* Vuex （グローバルな状態管理）
* Server Side Rendering （ Vue が吐き出す HTML をサーバ側で生成して処理高速化＋ SEO 対策）

なので、基本方針としては「ログイン後のページを、リンク読み込み不要なリッチフロントエンドにする」という方向性にします。上記のおまけテーマは appendix にある（予定）なのでそちらをご覧ください。

## Vue on Rails をはじめる

ではまず、 Rails Tutorial で作成したプロジェクトルートで以下を実行します。

```
$ npm install parcel-bundler parcel-plugin-bundle-manifest vue vue-router axios core-js regenerator-runtime --save
```

`node_modules` と `public/packs` を `.gitignore` に追記して `package.json` と `package-lock.json` のみコミットします。この 2 つのファイルはデプロイする時に必要になるので、忘れずにコミットしておいてください。その後前章までの指示に従って Rails で `parcel-manifest.json` を読み込む設定と `npm run watch` が実行できる設定をします。

ログイン後に Vue の UI が出るようにするので、 `app/javascripts/packs/Home.vue` と `app/javascripts/packs/index.js` を作って `app/views/static_pages/home.html.erb` を以下のように変更します。

```vue:app/javascripts/packs/Home.vue
<template>
  <p>Hello, world!</p>
</template>

<script>
export default {};
</script>
```

```js:app/javascripts/packs/index.js
import 'core-js/stable';
import 'regenerator-runtime/runtime';
import Vue from 'vue/dist/vue';
import Home from './Home.vue';

document.addEventListener('DOMContentLoaded', () => {
  new Vue({
    el: '#app',
    render: (createElement) => {
      return createElement(Home)
    }
  });
});
```

```erb:app/views/static_pages/home.html.erb
<% if logged_in? %>
  <% # 中略 %>
  <div id="app"></div>
  <%= javascript_pack_tag 'index' %>
<% else %>
  <% # 後略 %>
```

（ tips: これまで Ruby/Rails で開発してきたので、 `Home.vue` とファイル名に大文字が入ることに違和感を感じるかもしれませんが、 Vue や React でコンポーネントを作った時のファイル名はキャメルケースを使うことが多いです。）

ログイン後の画面の下部に Hello, world! と表示されていることが確認できると思います。それでは、実際に Rails からデータを取得するようにしてみましょう。

## JSON を吐き出す機械としての Rails

Rails で `generate scaffold` コマンドを実行すると、実は JSON を返却するような設定になっています。しかし、 Rails Tutorial ではその設定を省いてコードを書いてしまっているので、まずはその設定を復活させましょう。まずはログイン後のトップに表示されている最新の Micropost 一覧を取得するようにしてみましょう。既存の機能を壊してしまわないように、 `/feeds.json` という URL で Micropost 一覧を返却するようにします。

```ruby:config/routes.rb
Rails.application.routes.draw do
  # 略
  resources :feeds, only: [:index]  # 追記する
end
```

```ruby:app/controllers/feeds_controller.rb
class FeedsController < ApplicationController
  before_action :logged_in_user

  def index
    @feeds = current_user.feed.paginate(page: params[:page])
  end
end
```

まずはコントローラを用意します。ここまでは HTML を出力するコントローラと同じですね。しかし JSON を出力するには `.json.jbuilder` 形式のファイルが ERB の代わりに必要になります。ひとまずは `app/views/feeds/index.json.jbuilder` と `app/view/feeds/_feeds.json.jbuilder` を用意します。

```ruby:app/views/feeds/index.json.jbuilder
json.array! @feeds, partial: 'feeds/feed', as: :feed
```

```ruby:app/views/feeds/_feed.json.jbuilder
json.extract! feed, :id, :content
```

これで `rails server` コマンドを実行し、ログインしてから `http://0.0.0.0:3000/feeds.json` にアクセスすると、直近で投稿された Micropost の ID と文章のみが JSON 配列で出力されるはずです。他の属性（どのユーザが投稿したか）などは複雑になるので、まずはシンプルな出力にしました。 [jbuilder](https://github.com/rails/jbuilder) の記法はかなり癖があるので、しっかりと README を読み込んでおきましょう。

## Vue から JSON にアクセスする

データを提供するところまではできたので、実際に Vue のコンポーネントからデータを取得しましょう。基本的なお作法としては、そのコンポーネントが表示される前の段階になったら XMLHttpRequest （をラップした axios で）データ取得を開始し、取得後にデータを反映するようにします。 [Vue にはインスタンスライフサイクルフック](https://jp.vuejs.org/v2/guide/instance.html#インスタンスライフサイクルフック) という、コンポーネント生成・消滅のタイミングでコードを実行させる機能がありますので、ここに実装していきます。

```vue:app/javascripts/packs/Home.vue
<template>
  <div>
    <div v-if="feeds.length > 0">
      <p v-for="feed in feeds" v-bind:key="feed.id">
        {{ feed.content }}
      </p>
    </div>
    <div v-else>
      表示できるフィードはありません。
    </div>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  data() {
    return {
      feeds: []  // API から取得前の初期データを用意する必要あり
    };
  },
  async mounted() {
    const res = await axios.get('/feeds.json');
    this.feeds = res.data;
  }
};
</script>
```

ブラウザをリロードすると、ページの下部にフィードが出力されるようになったと思います。

## 練習問題 1

1. （ノーヒントだと難しいかも）このままでは「表示できるフィードはありません。」という表示が API からデータを取得する前に一瞬表示されてしまいます。これを避けて「ローディング中」という表示を出す方法を考えてください（ヒント：犬だけ表示ボタン・猫だけ表示ボタンを実装した時を思い出してみましょう）。
2. 1 のレビューを先に受けて（もしくは解答を見て）から、実際にそれを実装してみてください。

## jbuilder

ひとまず Micropost の内容 (content) は表示することができるようになったので、作成日時や Gravatar の画像など、他の内容も表示できるようにしましょう。生成される JSON の要素は、 jbuilder ファイル内で `json.xxx` と定義することができます。

```ruby:app/views/feeds/_feed.json.jbuilder
# extract! は feed 変数の id, content アトリビュートがそれぞれの名前で設定される
json.extract! feed, :id, :content

# feed に画像があれば、 picture_url という要素に URL を設定する
json.picture_url feed.picture.url if feed.picture?

# Helper に定義したメソッドも使うことができる
json.created_at_time_ago_in_words time_ago_in_words(feed.created_at)

# ネストした要素を定義したいときは do を使う
json.user do
  json.extract! feed.user, :id, :name
  json.is_current_user current_user?(feed.user)
end
```

次に Gravatar の画像を出力できるようにします。現在 UsersHelper に定義している `gravatar_for` メソッドでは、 `<img>` タグが全部出力されてしまいます。これを分割して、 Rails 側では Gravatar 用の URL を出力するようにし、 Vue 側で Gravatar の画像を表示するコンポーネントを作成します。

```ruby:app/models/user.rb
class User < ApplicationRecord
  # 略
  def gravatar_url(size: 80)
    gravatar_id = Digest::MD5::hexdigest(email.downcase)
    "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
  end
end
```

```ruby:app/helpers/users_helper.rb
class UsersHelper
  # 引数で与えられたユーザーのGravatar画像を返す
  def gravatar_for(user, size: 80)
    image_tag(user.gravatar_url(size: size), alt: user.name, class: "gravatar")
  end
end
```

```ruby:app/views/feeds/_feed.json.jbuilder
# 略
json.user do
  json.extract! feed.user, :id, :name, :gravatar_url
end
```

このようなコードの共通化作業は**リファクタリング**の一つです。 `http://0.0.0.0:3000/feeds.json` に改めてアクセスすると、 JSON の要素が揃っていることが確認できると思います。これで Micropost をこれまで表示していた部分が全て JSON として取得できるようになったので、 Vue に置き換えていきます。まずは Gravatar の画像を表示するコンポーネントを作りましょう。

```vue:app/javascripts/packs/GravatarImage.vue
<template>
  <a v-bind:href="'/users/' + user.id">
    <img v-bind:src="user.gravatar_url" v-bind:alt="user.name" class="gravatar" />
  </a>
</template>

<script>
export default {
  props: {
    user: Object
  }
};
</script>
```

このコンポーネントを Home.vue から読み込んで配置すると、 Gravatar とユーザ詳細ページへのリンクが表示されるでしょう。

## 練習問題 2

Vue ファイルを編集して、フィードリストを Vue に置き換えてみてください。想定しているコンポーネントは以下の通りです。削除ボタンは今のところ動作しなくても大丈夫です。

* Home.vue （ホーム画面用のコンポーネント）
* FeedList.vue （フィードリストのコンポーネント）
* FeedItem.vue （フィードリストの各要素のコンポーネント）
* GravatarImage.vue （ Gravatar 画像表示用のコンポーネント）

## 次回予告

Vue でリッチなフォームを作り、 axios で登録する処理を実装します。

{% endraw %}
