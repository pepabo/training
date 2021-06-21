# 第 21 章　Vue から Rails にデータを送信する

{% raw %}

さて、それでは前の章で出題された練習問題ではスキップしていた、削除リンクの実装をしましょう。 scaffold から推察するに、おおよそこのようなコードになると考えられますね。

```ruby
# app/controllers/microposts_controller.rb

class MicropostsController < ApplicationController
  # 略
  def destroy
    @micropost.destroy
    respond_to do |format|
      format.html do
        flash[:success] = "Micropost deleted"
        redirect_to request.referrer || root_url
      end
      format.json { head :no_content }
    end
  end
end
```

```vue:app/javascripts/packs/FeedItem.vue
<template>
  <!-- 略 -->
    <a v-on:click="delete">delete</a>
  <!-- 略 -->
</template>

<script>
import axios from 'axios';

export default {
  // 略
  props: {
    // 略
    onDelete: Function
  },
  methods: {
    async delete() {
      const res = await axios.delete(`/microposts/${this.feed.id}.json`);
      this.onDelete(this.feed.id);  // 親コンポーネントから渡された関数を実行して要素を削除する
    }
  }
};
</script>
```

（ tips: 親コンポーネントから子コンポーネントに渡す `props` として、親コンポーネントの `methods` に定義した関数を渡すことができます。）

しかし、これを書いて削除リンクを押したところで、何も発生しません。 Google Chrome などで開発者コンソールを開いてエラーを見ると、レスポンスコード 422, Can't verify CSRF token authenticity というエラーが発生していることが確認できます。これは、セキュリティ講習で出てきた外部 web アプリケーションからの不正な POST 操作である CSRF を防ぐ機構が Rails ではデフォルトで搭載されているためです。

（ TODO: セキュリティ研修受けてない人向けに CSRF がどのようなものかまとめる）

現在開いている Micropost アプリケーションの HTML ソースを表示すると、このような部分があります。

```html
<meta name="csrf-param" content="authenticity_token" />
<meta name="csrf-token" content="OmfhveuM3UaRbeTV1CTvejMViyFzaqN1I9EIOzhkd5pb+shYAYMmpp6HDuxzqDFV/BVU5fe21V7h+PX7a0aBWQ==" />
```

これが CSRF を回避するためのトークンで、 Rails が生成する HTML から POST を行うときには、これをパラメータに付加して送信しているのです。この仕組みは `ApplicationController` にある `protect_from_forgery with: :exception` の部分で有効化されているので、ひとまずこの行をコメントアウトして、実際に削除のリクエストが実行できるか確かめてみましょう。

（オフトピック： BFF (Backend for Frontend) や API サーバのような構成を採用する場合、セッションを使ってログインするという作業は発生せず、リクエストにトークンを付加することでユーザを認証するので、 CSRF 対策はあまり考えなくてよくなります。）

## 練習問題 1

新規 Micropost 投稿フォームを Vue に置き換えてください（画像投稿が結構むずいかも）。投稿後に投稿データを FeedList に反映させるようにしてください。ただし、 `/feeds.json` を再取得する方法ではない方法で実装してください（ヒント： scaffold を作成した時 `create` メソッドは JSON のレスポンスを返すようになっています。それを使います）。

## `protect_from_forgery` に対応する

さて、このままだとログイン済みの状態で不正なサイトから POST 処理ができてしまいます。これを正規の方法を用いて POST できるようにします。もっともシンプルな実装をするのであれば、 HTTP リクエストをするときに `<meta>` タグからトークンを取得すれば良いのです。 XMLHttpRequest でリクエストを送信する際に `X-CSRF-Token` ヘッダを付与すれば正常処理されるようになります。

（注意！！： `protect_from_forgery: :exception` のコメントアウトを戻すようにしましょう）

Rails 5.2 以降でアプリケーションを作成している場合（ 2019 年現在、 Rails Tutorial の最新版は Rails 5.1 系です）、 `protect_from_forgery` がデフォルトで有効になっているので以下のように `config/application.rb` で無効化する必要があります。

```ruby
# config/application.rb

# 略

module FooApplication
  class Application < Rails::Application
    # 略
    action_controller.default_protect_from_forgery = false
  end
end
```

（こぼれ話：ちなみに、HTML の `<form>` タグが送信できる HTTP メソッドは実は GET, POST しかなく、 PATCH, PUT, DELETE などの HTTP メソッドは XMLHttpRequest からしか送れません。これを Rails では擬似的に POST で扱えるように、特殊なパラメータをフォームに追加しているのです。）

```vue:app/javascripts/packs/FeedItem.vue
<script>
import axios from 'axios';

export default {
  // 略
  methods: {
    async delete() {
      const token = document.querySelector('meta[name="csrf-token"]').content;
      const res = await axios.delete(`/microposts/${this.feed.id}.json`, {
        headers: {
          // JavaScript のオブジェクトのキーにハイフンが入るときは必ずクオートしないといけない
          'X-CSRF-Token': token
        }
      });
      this.onDelete(this.feed.id);  // 親コンポーネントから渡されたハンドラを実行して要素を削除する
    }
  }
};
</script>
```

さて、これで一見すればリクエストが通るように見えます。実際に操作してみましょう。しかし一度は削除処理ができたものの、複数回はできないままになっていると思います。これはリクエストごとにトークンが変化し、新しいものに置き換えをしないと不正なリクエストであると判断されてしまうためです。

これを避けるためには、リクエストごとに新しいトークンに置き換える仕組みが必要です。 HTTP レスポンスに新しいトークンを付与する [Synchronizer Token Pattern](https://github.com/OWASP/CheatSheetSeries/blob/master/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.md#synchronizer-token-pattern) を採用します。まずは、 Rails サーバ側からリクエスト完了時に新しいトークンをヘッダに付与して送信するようにします。

```ruby
# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  # 略

  after_action :set_csrf_token_header

  def set_csrf_token_header
    response.set_header("X-CSRF-Token", form_authenticity_token)
  end
end
```

そしてこのレスポンスに存在するヘッダを取得し、古いトークンを置き換えるよう実装します。

```vue:app/javascripts/packs/FeedItem.vue
<script>
import axios from 'axios';

export default {
  // 略
  methods: {
    async delete() {
      const meta = document.querySelector('meta[name="csrf-token"]');
      const res = await axios.delete(`/microposts/${feed.id}.json`, {
        headers: {
          'X-CSRF-Token': meta.content
        }
      });
      meta.content = res.headers['X-CSRF-Token'];
      this.onDelete();  // 親コンポーネントから渡されたハンドラを実行して要素を削除する
    }
  }
};
</script>
```

しかし、これでは他の POST/PUT/PATCH/DELETE リクエストの時にも同じ処理を書かなくてはいけなくなります。これを共通化できる仕組みとして axios には [interceptor](https://github.com/axios/axios#interceptors) という仕組みがあり、リクエスト・レスポンスごとにフックする関数を与えることができます。

```js:app/javascripts/packs/axiosClient.js
import axios from 'axios';

const client = axios.create();

client.interceptors.request.use((config) => {
  const token = document.querySelector('meta[name="csrf-token"]').content;
  config.headers['x-csrf-token'] = token;
  return config;
}, (error) => {
  return Promise.reject(error);
});

client.interceptors.response.use((response) => {
  const token = response.headers['x-csrf-token'];
  if (token) {
    document.querySelector('meta[name="csrf-token"]').content = token;
  }
  return response;
}, (error) => {
  return Promise.reject(error);
});

export default client;
```

```js:app/javascripts/packs/FeedItem.vue
// import axios from 'axios';
// 置き換え
import axios from './axiosClient';
// 後略
```

## 練習問題 2

1. 新規 Micropost 投稿フォームも `axiosClient.js` を使うようにしてください。
2. このままではトークンの置き換えが HTML に依存してしまいます。 [Window.localStorage](https://developer.mozilla.org/ja/docs/Web/API/Window/localStorage) にトークンを保存するようにしてください（ヒント：初回は HTML の `<meta>` タグから読み込みます）。

{% endraw %}
