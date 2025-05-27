# 付録5 RailsアプリケーションのCSRF対策をフロントエンドアプリケーションに適用する

Rails Tutorialで作成したアプリケーションに対して、POSTメソッドをはじめとした更新系リクエストを受付するAPIエンドポイントを追加し、フロントエンドアプリケーションからアクセスしてみましょう。

開発者コンソールを開いてエラーを見ると、レスポンスコード 422, Can't verify CSRF token authenticity というエラーが発生していることが確認できます。
これは、不正な POST 操作である CSRF を防ぐ機構が Rails では [デフォルトで搭載されている](https://railsguides.jp/security.html#csrf%E3%81%B8%E3%81%AE%E5%AF%BE%E5%BF%9C%E7%AD%96) ためです。

(CSRFについては IPAが提供している [安全なウェブサイトの作り方 - 1.6 CSRF](https://www.ipa.go.jp/security/vuln/websecurity/csrf.html) が分かりやすいです。
クッキーをはじめとした、認証情報がリクエストと共に送信される場合において、意図しないウェブページから攻撃対象のエンドポイントに対して遷移したときに、ユーザーが意図しない操作が実行できてしまうという脆弱性のことです。)

CSRFは、リクエストを実行したウェブページを検証できれば対策することができます。
攻撃者のウェブページから遷移していないことを検証したあとにリクエストを処理すればよいというわけです。
Railsでは、CSRF を回避するためのトークンを提供することで、この検証を実施しています。 (`csrf_meta_tags` ヘルパーによって生成されています。)

Rails が生成する HTMLには推測困難な文字列で構成されるパラメータを埋め込んでおき、POST を行うときにはこれを送信することで、リクエストの出自を検証できるのです。
攻撃者はCSRF Tokenを予め取得できないという前提の下に安全となります。
この仕組みはコントローラ内で `protect_from_forgery` メソッドが呼ばれていると有効になるのですが、`protect_from_forgery` はデフォルトで有効になっています。

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

## `protect_from_forgery` に対応する

さて、`protect_from_forgery` が無効になっているとログイン済みの状態で不正なサイトから POST 処理ができてしまいます。
これを正規の方法を用いて POST できるようにします。
もっともシンプルな実装をするのであれば、 HTTP リクエストをするときに `<meta>` タグからトークンを取得すれば良いのです。
XMLHttpRequest あるいは Fetch API でリクエストを送信する際に `X-CSRF-Token` ヘッダを付与すれば正常処理されるようになります。

（こぼれ話：ちなみに、HTML の `<form>` タグが送信できる HTTP メソッドは実は GET, POST しかなく、 PATCH, PUT, DELETE などの HTTP メソッドは XMLHttpRequest からしか送れません。これを Rails では擬似的に POST で扱えるように、特殊なパラメータをフォームに追加しているのです。）

```tsx
// app/javascript/components/static-pages/FeedItem.tsx

  // 略
  if (confirm("You sure?")) {
    const token = document.querySelector<HTMLMetaElement>(
      'meta[name="csrf-token"]'
    )?.content;

    const response = await fetch(`/microposts/${props.feed.id}.json`, {
      method: "DELETE",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": token,
      },
    });

    if (response.ok) {
      props.onDelete(props.feed.id);
    } else {
      console.error("Failed to delete the feed item.");
    }
  }
  // ...
```

さて、これでリクエストが通るはずです。実際に操作してみましょう。

### Synchronizer Token Pattern

もしかしたら、手元の環境で一度は削除処理ができたものの、複数回はできないままになっていることがあるかもしれません。
これはリクエストごとにトークンが変化し、新しいものに置き換えをしないと不正なリクエストであると判断されてしまうためです。

これを避けるためには、リクエストごとに新しいトークンに置き換える仕組みが必要です。
HTTP レスポンスに新しいトークンを付与する [Synchronizer Token Pattern](https://github.com/OWASP/CheatSheetSeries/blob/master/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.md#synchronizer-token-pattern) を採用します。
まずは、 Rails サーバ側からリクエスト完了時に新しいトークンをヘッダに付与して送信するようにします。

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

## 練習問題

1. CSRFはリクエストの出自を確認できれば防ぐことができると説明しましたが、CSRFトークンを用いずにこれを実現する方法を探して説明してください
