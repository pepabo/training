# 第 20 章　React on Rails

{% raw %}

ここまで前提知識のインストールだけでかなりのボリュームになってしまいましたが、全て実際のモダンフロントエンド開発において使う技術なので、駆け足ですが説明してきました。ここからは、それらを使って実際に Rails の上に SPA を組み立てていきます。

## 要件

Rails Tutorial で作成した Micropost アプリケーションを SPA にします。ただし、以下については時間の都合上考えないことにします。

* ログイン機構（ JWT あたりで実装するのですが長くなりすぎる）
* Rails を BFF (Backend for Frontend) にして Next.js のフロントエンドサーバを立てる
* Redux （グローバルな状態管理）
* Server Side Rendering （ React が吐き出す HTML をサーバ側で生成して処理高速化＋ SEO 対策）

なので、基本方針としては「ログイン後のページを、リンク読み込み不要なリッチフロントエンドにする」という方向性にします。上記のおまけテーマは appendix にある（予定）なのでそちらをご覧ください。

## 前提

これから React のコードをある程度の量書いていくにあたり、人間の脳では全体の整合性を追いきれなくなってくるかと思います（React に限らず一定量以上のコードを書くと誰しもそうなると思いますが）。
そこで TypeScript の導入を強くおすすめします。導入といってもそんなに手順は複雑ではありません。 [付録 3](../appendix03/) に内容をまとめてありますので、先に進む前にまずこちらを読んでみてください。
これ以降は TypeScript でコードを書くことを前提として話を進めます。

## React on Rails をはじめる

前章までで React による UI を表示させることはできました。ではまず、ログイン後に React の UI が出るようにしたいので、`app/views/layouts/application.html.erb` に置いていた `<div>` 要素を削除して、`app/views/static_pages/home.html.erb` に以下のように配置します:

```diff
--- a/app/views/layouts/application.html.erb
+++ b/app/views/layouts/application.html.erb
@@ -15,7 +15,6 @@
       <% flash.each do |message_type, message| %>
         <div class="alert alert-<%= message_type %>"><%= message %></div>
       <% end %>
-      <div id="app"></div>
       <%= yield %>
       <%= render 'layouts/footer' %>
       <%= debug(params) if Rails.env.development? %>
```

```diff
--- a/app/views/static_pages/home.html.erb
+++ b/app/views/static_pages/home.html.erb
@@ -1,4 +1,5 @@
 <% if logged_in? %>
+  <div id="app"></div>
   <div class="row">
     <aside class="col-md-4">
       <section class="user_info">
```

`app/javascript/components/index.tsx` の中に書いていた `Showcase` コンポーネントはもう使わないので、削除するか適当なファイルにコピーして脇に置いておいてください。

`app/javascripts/components/static-pages/Home.tsx` を作って以下のような内容にします:

```tsx
const Home = () => {
  return <>Hello, world!</>;
};

export default Home;
```

（ Tips: これまで Ruby/Rails で開発してきたので、 `Home.tsx` とファイル名に大文字が入ることに違和感を感じるかもしれませんが、React や Vue でコンポーネントを作った時のファイル名はキャメルケースを使うことが多いです。）

この `Home` コンポーネントを `app/javascripts/components/static-pages/index.ts` から提供する形にしましょう:

```ts
import Home from "./Home";

export { Home };
```

`app/javascript/components/index.tsx` は以下のように変更してください:

```tsx
import { Home } from "./static-pages";

const App = () => {
  return <Home></Home>;
};

export default App;
```

`<div id="app">` 要素はログイン時のみ存在するようにしたので、 `app/javascript/packs/application.js` ではその要素がある場合に限って `ReactDOM.render()` するように修正しましょう:

```js
document.addEventListener("DOMContentLoaded", () => {
  const container = document.getElementById("app")
  if (container) {
    ReactDOM.render(<App />, container)
  }
})
```

ログイン後の画面に Hello, world! と表示されていることが確認できると思います。それでは、実際に Rails からデータを取得するようにしてみましょう。

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
    respond_to do |format|
      format.json do
        @feeds = current_user.feed.paginate(page: params[:page])
      end
    end
  end
end
```

まずはルーティングを追加してコントローラを用意します。ここまでは HTML を出力するコントローラと同じですね。しかし JSON を出力するには `.json.jbuilder` 形式のファイルが ERB の代わりに必要になります。ひとまずは `app/views/feeds/index.json.jbuilder` と `app/view/feeds/_feeds.json.jbuilder` を用意します。

```ruby:app/views/feeds/index.json.jbuilder
json.array! @feeds, partial: 'feeds/feed', as: :feed
```

```ruby:app/views/feeds/_feed.json.jbuilder
json.extract! feed, :id, :content
```

ただし jbuilder は [v2.10.1](https://github.com/rails/jbuilder/releases/tag/v2.10.1) 以上のバージョンに更新してください（これより前のバージョンだと Ruby 3.0 ではエラーになります）。

これで `rails server` コマンドを実行し、ログインしてから `http://localhost:3000/feeds.json` にアクセスすると、直近で投稿された Micropost の ID と文章のみが JSON 配列で出力されるはずです。他の属性（どのユーザが投稿したか）などは複雑になるので、まずはシンプルな出力にしました。 [jbuilder](https://github.com/rails/jbuilder) の記法はかなり癖があるので、しっかりと README を読み込んでおきましょう。

## React から JSON にアクセスする

データを提供するところまではできたので、実際に React コンポーネントからデータを取得しましょう。まずは `axios`（XMLHttpRequest をラップして Promise を返却する HTTP クライアントとして人気のあるライブラリです）をインストールしましょう:

```bash
npm i -E axios@0.21.1
```

基本的なお作法としては、そのコンポーネントがレンダー（描画）された後に axios を呼んで Rails サーバからデータを取得し、そのデータでコンポーネント内の状態を更新するようにします。React にはそのために [useEffect](https://ja.reactjs.org/docs/hooks-effect.html) という API がありますので、これを使って実装していきます。

`app/javascript/components/static-pages/Home.tsx` を以下のように書き換えましょう:

```tsx
import axios from "axios";
import { useEffect, useState } from "react";

interface Feed {
  id: number;
  content: string;
}

const Home = () => {
  const [feeds, setFeeds] = useState<Feed[]>([]);

  useEffect(() => {
    const fetchFeeds = async () => {
      const res = await axios.get<Feed[]>("/feeds.json");
      setFeeds(res.data);
    };

    fetchFeeds();
  }, []);

  return (
    <div className="row">
      <div className="col-mod-8">
        <h3>Micropost Feed</h3>
        {feeds.length > 0 ? (
          <ol className="microposts">
            {feeds.map((feed) => (
              <li key={feed.id}>
                <span className="content">{feed.content}</span>
              </li>
            ))}
          </ol>
        ) : (
          <div>表示できるフィードはありません。</div>
        )}
      </div>
    </div>
  );
};

export default Home;
```

ブラウザをリロードすると、ページの上部にフィードが出力されるようになったと思います。

いくつか注意すべき点があります。React の場合、CSS のクラスを指定するには通常の `class` 属性ではなく [`className` 属性を使用してください](https://ja.reactjs.org/docs/dom-elements.html#classname) 。

それから `useEffect` はデフォルトではコンポーネントのレンダー後に **毎回** 呼ばれます。第 18 章で React は状態の変更の前後で UI のどの部分が書き換わるかを検知してその部分だけ更新すると書きましたが、その更新のたびに（初回レンダー時だけでなく）呼ばれるという意味です。しかし Rails サーバからのフィード情報の取得に関しては初回の画面読み込み時だけで十分なので、毎回呼ばれてほしくはないですよね。そこで `useEffect` には第二引数に、「この値が変わったときだけまた `useEffect` を呼んでほしい」というような値を配列に入れて渡せるようになっています。上記のコードをよく見ると `useEffect` の第二引数に空配列を渡していることに気づいたでしょうか。空配列ということはつまり「初回レンダー以降ではもう `useEffect` を呼んでほしくない」という意味になるわけです。

## 練習問題 1

1. （ノーヒントだと難しいかも）このままでは「表示できるフィードはありません。」という表示が API からデータを取得する前に一瞬表示されてしまいます。これを避けて「ローディング中」という表示を出す方法を考えてください。
2. 1 のレビューを先に受けて（もしくは解答を見て）から、実際にそれを実装してみてください。

## jbuilder

ひとまず Micropost の内容 (content) は表示することができるようになったので、作成日時や Gravatar の画像など、他の内容も表示できるようにしましょう。生成される JSON の要素は、 jbuilder ファイル内で `json.xxx` と定義することができます。

```ruby:app/views/feeds/_feed.json.jbuilder
# extract! は feed 変数の id, content アトリビュートがそれぞれの名前で設定される
json.extract! feed, :id, :content

# feed に画像があれば、 image_url という要素に URL を設定する
json.image_url feed.display_image if feed.image.attached?

# Helper に定義したメソッドも使うことができる
json.created_at_time_ago_in_words time_ago_in_words(feed.created_at)

# ネストした要素を定義したいときは do を使う
json.user do
  json.extract! feed.user, :id, :name
  json.is_current_user current_user?(feed.user)
end
```

次に Gravatar の画像を出力できるようにします。現在 UsersHelper に定義している `gravatar_for` メソッドでは、 `<img>` タグが全部出力されてしまいます。これを分割して、 Rails 側では Gravatar 用の URL を出力するようにし、 React 側で Gravatar の画像を表示するコンポーネントを作成します。

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
module UsersHelper

  # 引数で与えられたユーザーのGravatar画像を返す
  def gravatar_for(user, options = { size: 80 })
    size = options[:size]
    image_tag(user.gravatar_url(**{ size: size }), alt: user.name, class: "gravatar")
  end
end
```

```ruby:app/views/feeds/_feed.json.jbuilder
# 略
json.user do
  json.gravatar_url feed.user.gravatar_url(**{ size: 50 })
end
```

このようなコードの共通化作業は**リファクタリング**の一つです。 `http://localhost:3000/feeds.json` に改めてアクセスすると、 JSON の要素が揃っていることが確認できると思います。これで Micropost をこれまで表示していた部分が全て JSON として取得できるようになったので、 React に置き換えていきます。まずは Gravatar の画像を表示するコンポーネントを作りましょう。

```tsx:app/javascript/components/static-pages/GravatarImage.tsx
interface User {
  id: number;
  name: string;
  gravatar_url: string;
}

interface Props {
  user: User;
}

const GravatarImage = (props: Props) => {
  return (
    <a href={`/users/${props.user.id}`}>
      <img
        src={props.user.gravatar_url}
        alt={props.user.name}
        className="gravatar"
      />
    </a>
  );
};

export default GravatarImage;
```

このコンポーネントを `Home.tsx` から読み込んで配置すると、 Gravatar とユーザ詳細ページへのリンクが表示されるでしょう。

## 練習問題 2

React ファイルを編集して、フィードリストを React に置き換えてみてください。想定しているコンポーネントは以下の通りです。削除ボタンは今のところ動作しなくても大丈夫です。

* Home.tsx （ホーム画面用のコンポーネント）
* FeedList.tsx （フィードリストのコンポーネント）
* FeedItem.tsx （フィードリストの各要素のコンポーネント）
* GravatarImage.tsx （ Gravatar 画像表示用のコンポーネント）

## 次回予告

React でリッチなフォームを作り、 axios で登録する処理を実装します。

{% endraw %}
