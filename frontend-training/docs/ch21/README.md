# 第 21 章　Vue から Rails にデータを送信する

{% raw %}

さて、それでは前の章で出題された練習問題ではスキップしていた、削除リンクの実装をしましょう。おおよそこのようなコードになると考えられますね。

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

```tsx
// app/javascript/components/static-pages/FeedItem.tsx

import axios from "axios";
import * as React from "react";

// 略
interface Props {
  feed: Feed;
  onDelete: (id: number) => void;
}

const FeedItem = (props: Props) => {
  const handleClickDeleteButton = async (event: React.MouseEvent) => {
    event.preventDefault();

    if (confirm("You sure?")) {
      await axios.delete(`/microposts/${props.feed.id}.json`);
      // 親のfeedsを更新する
      props.onDelete(props.feed.id);
    }
  };

  return (
    <>
      {/* 略 */}
        {props.feed.user.is_current_user && (
          <a onClick={handleClickDeleteButton}>delete</a>
        )}
    </>
  );
};
```

しかし、これを書いて削除リンクを押したところで、何も発生しません。 Google Chrome などで開発者コンソールを開いてエラーを見ると、レスポンスコード 422, Can't verify CSRF token authenticity というエラーが発生していることが確認できます。これは、セキュリティ講習で出てきた外部 web アプリケーションからの不正な POST 操作である CSRF を防ぐ機構が Rails では [デフォルトで搭載されている](https://railsguides.jp/security.html#csrf%E3%81%B8%E3%81%AE%E5%AF%BE%E5%BF%9C%E7%AD%96) ためです。

（ TODO: セキュリティ研修受けてない人向けに CSRF がどのようなものかまとめる）

現在開いている Micropost アプリケーションの HTML ソースを表示すると、このような部分があります。

```html
<meta name="csrf-param" content="authenticity_token" />
<meta name="csrf-token" content="OmfhveuM3UaRbeTV1CTvejMViyFzaqN1I9EIOzhkd5pb+shYAYMmpp6HDuxzqDFV/BVU5fe21V7h+PX7a0aBWQ==" />
```

これが CSRF を回避するためのトークンで、 `csrf_meta_tags` ヘルパーによって生成されています。 Rails が生成する HTML から POST を行うときには、これをパラメータに付加して送信しているのです。この仕組みはコントローラ内で `protect_from_forgery` メソッドが呼ばれていると有効になるのですが、Rails 5.2 以降でアプリケーションを作成している場合（ 2021 年 6 月現在、 Rails の最新版は 6.1 です）、 `protect_from_forgery` はデフォルトで有効になっています（ちなみに Rails 5.1 まではプログラマが手で `ApplicationController` に `protect_from_forgery with: :exception` などのように書いていました）。

Rails 5.2 以降で `protect_from_forgery` を無効化するには `config/application.rb` で以下のように設定する必要があります:

```ruby
# config/application.rb

# 略

module FooApplication
  class Application < Rails::Application
    # 略
    config.action_controller.default_protect_from_forgery = false
  end
end
```

## 練習問題 1

1. 試しに上記のように設定を変更してから Rails サーバを再起動し、もう一度自分の Micropost が `delete` リンクから削除できるか試してみてください。削除できることを確認したら必ず設定を元に戻してください。

（オフトピック： BFF (Backend for Frontend) や API サーバのような構成を採用する場合、セッションを使ってログインするという作業は発生せず、リクエストにトークンを付加することでユーザを認証するので、 CSRF 対策はあまり考えなくてよくなります。）

## `protect_from_forgery` に対応する

さて、`protect_from_forgery` が無効になっているとログイン済みの状態で不正なサイトから POST 処理ができてしまいます。これを正規の方法を用いて POST できるようにします。もっともシンプルな実装をするのであれば、 HTTP リクエストをするときに `<meta>` タグからトークンを取得すれば良いのです。 XMLHttpRequest でリクエストを送信する際に `X-CSRF-Token` ヘッダを付与すれば正常処理されるようになります。

（こぼれ話：ちなみに、HTML の `<form>` タグが送信できる HTTP メソッドは実は GET, POST しかなく、 PATCH, PUT, DELETE などの HTTP メソッドは XMLHttpRequest からしか送れません。これを Rails では擬似的に POST で扱えるように、特殊なパラメータをフォームに追加しているのです。）

```tsx
// app/javascript/components/static-pages/FeedItem.tsx

  // 略
    if (confirm("You sure?")) {
      const token = document.querySelector<HTMLMetaElement>(
        'meta[name="csrf-token"]'
      )?.content;

      await axios.delete(`/microposts/${props.feed.id}.json`, {
        headers: {
          // JavaScript のオブジェクトのキーにハイフンが入るときは必ずクオートしないといけない
          "X-CSRF-Token": token,
        },
      });

      props.onDelete(props.feed.id);
    }
  // ...
```

さて、これでリクエストが通るはずです。実際に操作してみましょう。

しかし、これでは他の POST/PUT/PATCH/DELETE リクエストの時にも同じ処理を書かなくてはいけなくなります。これを共通化できる仕組みとして axios には [interceptor](https://github.com/axios/axios#interceptors) という仕組みがあり、リクエスト・レスポンスごとにフックする関数を与えることができます。新しく `axiosClient.ts` というファイルを作成して以下のように書いてください:

```ts
// app/javascript/axiosClient.ts

import axios from "axios";

const client = axios.create();

client.interceptors.request.use(
  (config) => {
    const token = document.querySelector<HTMLMetaElement>(
      'meta[name="csrf-token"]'
    )?.content;

    config.headers["X-CSRF-Token"] = token;
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

export default client;
```

この `axiosClient.ts` を使えば、リクエストを送る時に毎回 `X-CSRF-Token` ヘッダを設定する処理を書かずに済みます:

```diff
--- a/app/javascript/components/static-pages/FeedItem.tsx
+++ b/app/javascript/components/static-pages/FeedItem.tsx
@@ -1,4 +1,4 @@
-import axios from "axios";
+import axios from "axiosClient";
 import * as React from "react";
 import GravatarImage from "./GravatarImage";

@@ -27,16 +27,7 @@ const FeedItem = (props: Props) => {
     event.preventDefault();

     if (confirm("You sure?")) {
-      const token = document.querySelector<HTMLMetaElement>(
-        'meta[name="csrf-token"]'
-      )?.content;
-
-      await axios.delete(`/microposts/${props.feed.id}.json`, {
-        headers: {
-          // JavaScript のオブジェクトのキーにハイフンが入るときは必ずクオートしないといけない
-          "X-CSRF-Token": token,
-        },
-      });
+      await axios.delete(`/microposts/${props.feed.id}.json`);

       props.onDelete(props.feed.id);
     }
```

### Synchronizer Token Pattern

もしかしたら、手元の環境で一度は削除処理ができたものの、複数回はできないままになっていることがあるかもしれません。これはリクエストごとにトークンが変化し、新しいものに置き換えをしないと不正なリクエストであると判断されてしまうためです。

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

```tsx
// app/javascript/components/static-pages/FeedItem.tsx

  // 略
    if (confirm("You sure?")) {
      const meta = document.querySelector<HTMLMetaElement>(
        'meta[name="csrf-token"]'
      );;

      const res = await axios.delete(`/microposts/${props.feed.id}.json`, {
        headers: {
          // JavaScript のオブジェクトのキーにハイフンが入るときは必ずクオートしないといけない
          "X-CSRF-Token": meta?.content,
        },
      });

      if (meta) {
        meta.content = res.headers["X-CSRF-Token"];
      }

      props.onDelete(props.feed.id);
    }
  // ...
```

## 練習問題 2

1. `user_info`、 `stats`、`micropost_form` （新規 Micropost 投稿フォーム）も React に置き換えてください。ただし

  - `StaticPagesController#me` という API を作成して、 `/me.json` へのリクエストで自分のユーザ情報を取得するようにしてください。

  - 投稿後に投稿データを FeedList に反映させるようにしてください。ただし、 `/feeds.json` を再取得する方法ではない方法で実装してください（ヒント： `create` メソッドで JSON のレスポンスを返すようにします）。

  - 画像投稿が結構むずいかも。React 公式ドキュメントの [ファイル input タグ](https://ja.reactjs.org/docs/uncontrolled-components.html#the-file-input-tag) や [useRef](https://ja.reactjs.org/docs/hooks-reference.html#useref) 、[FormData](https://developer.mozilla.org/ja/docs/Web/API/FormData) などを参考にしてください。

  - 現状 `app/javascript/packs/application.js` に「ファイルサイズが 5MB 以上の場合はアラートを出す」ための jQuery のコードが置きっぱなしになっていると思いますが、そのコードを消して、新規 Micropost 投稿フォームのコンポーネント内で（jQuery を使わない形で）書き直してください。

  - すべてできたら `home.html.erb` の `<% if logged_in? %>` の分岐内部から `<div id="app"></div>` 以外のDOM要素を削除して、完全に React の描画だけで画面を作るようにしてください。

{% endraw %}
