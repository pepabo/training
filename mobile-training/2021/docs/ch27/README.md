# 27章 Webアプリケーション(Rails)のAPIと組み合わせたモバイルアプリケーション開発

それでは、これまで学習してきた内容を活用し、マイクロブログを閲覧・編集できるモバイルアプリケーションを作ってみましょう。

## Rails側の準備

基本的にはRails Tutorialで開発してきた成果物をほぼそのまま使うことができますが、1点だけ大きく異なる点があります。
それは、モバイルアプリケーションからは基本的にWebブラウザの機能を使うことはできないということです。
WebブラウザにはCookieにセッションIDを記録し、それを元にログイン状態の保持を行います。しかしモバイルアプリでは、この機能を使えないため、ログイン状態を別の手段で保持する必要があります。

このような、セッションベースではないユーザーの認証・認可には、OAuth2.0を用いることが多いです。
OAuth2.0とは、[RFC6749](https://openid-foundation-japan.github.io/rfc6749.ja.html)で定義される認可フレームワークです。

今回は、Ruby on RailsでOAuth2.0の認可に関する機能を提供してくれるDoorkeeperというGemを使います。

### Doorkeeperのインストールと初期化

まずは、GemfileにDoorkeeperを追加します。

```ruby
  gem 'doorkeeper'
```

`bundle install`でインストールしたら、Doorkeeperの初期化を実行します。

```bash
$ bin/rails generate doorkeeper:install
```

コマンドを実行すると、Doorkeeperに関するいくつかの変更と新規ファイルが生成されます。
生成された`config/initializers/doorkeeper.rb`を開いてみましょう。

```ruby
# frozen_string_literal: true

Doorkeeper.configure do
  # Change the ORM that doorkeeper will use (requires ORM extensions installed).
  # Check the list of supported ORMs here: https://github.com/doorkeeper-gem/doorkeeper#orms
  orm :active_record

  # This block will be called to check whether the resource owner is authenticated or not.
  resource_owner_authenticator do
    raise "Please configure doorkeeper resource_owner_authenticator block located in #{__FILE__}"
    # Put your resource owner authentication logic here.
    # Example implementation:
    #   User.find_by(id: session[:user_id]) || redirect_to(new_user_session_url)
  end
```

このファイルには、Doorkeeperに関する設定を記述します。
まずは`resource_owner_authenticator`のブロックに設定を追加しましょう。

ここには、Doorkeeper Applicationの設定画面 `https://localhost:3000/oauth/applications`にアクセスする際の`current_resource_owner`に関する認証について記述します。
ほぼそのまま使えますが、`redirect_to(new_user_session_url)`というURLヘルパーは存在しないため、ここだけ変えておきます。

```ruby
  resource_owner_authenticator do
    User.find_by(id: session[:user_id]) || redirect_to(login_url)
  end
```

設定が完了したら、Doorkeeperに関するマイグレーションファイルを生成します。

```
$ bin/rails generate doorkeeper:migration
    create  db/migrate/2021**********_create_doorkeeper_tables.rb
```

このマイグレーションファイルには、`OAuthApplications`, `OAuthAccessTokens`, `OAuthAccessGrants`という、Doorkeeperに関する情報を格納する3つのテーブルを作成する処理が記述されています。

ファイルの下部に、外部キー制約に関する設定がコメントアウトされています。
`OAuthAccessTokens`, `OAuthAccessGrants`には`Users`に対する外部キー制約を追加しておきましょう。

```ruby
    # Uncomment below to ensure a valid reference to the resource owner's table
    add_foreign_key :oauth_access_grants, :users, column: :resource_owner_id
    add_foreign_key :oauth_access_tokens, :users, column: :resource_owner_id
```

編集が完了したら、マイグレーションを実行します。

```
$ bin/rails db:migrate
```

これで前準備は完了です。

### Doorkeeper Applicationの作成と、Resource Owner Password Credentials方式によるトークンの生成

今回は、アクセストークンの取得にResource Owner Password Credentials方式を用います。

この方式は、クライアントアプリケーションが直接ユーザーのパスワードを知ることになります。
そのため、この方式を採用する場合はクライアントがWebサービスの公式モバイルアプリケーションがほとんどであると考えて差し支えありません。

DoorkeeperにはResource Owner Password Credentials方式以外にも、Authorization Code Flow方式などの認可フローに対応しています。気になる方はDoorkeeper Gemのドキュメントを読んでみると良いでしょう。

それでは、実際にDoorkeeperを使ってアプリケーションを作ってみましょう。

まず、DoorkeeperでResource Owner Password Credentialsを有効にするため、`config/initializers/doorkeeper.rb`の`Doorkeeper.configre`ブロックに追記します。

```ruby
Doorkeeper.configure do
  grant_flows %w(password)
  # 省略
end
```

次に、resource Owner Password Credentialsでユーザを認証する際のロジックを`resource_owner_from_credentials`にブロックで渡します。

```ruby
Doorkeeper.configure do
  resource_owner_from_credentials do |routes|
    User.find_by(email: params[:username]).authenticate(params[:password])
  end
  # 省略
end
```

さらに、Resource Owner Password Credentials方式で認可を行うため、どんなユーザーでもDoorkeeperアプリケーションを作れる状態を避けます。

`admin_authenticator`は`/oauth/applications`にアクセスできるユーザの制限に使えます。
`current_resource_owner`が`admin`ではない場合は、403を返してアクセスできないようにしましょう。

最終的な`config/initializers/doorkeeper.rb`を以下に示します。

```ruby
Doorkeeper.configure do
  orm :active_record
  grant_flows %w(password)

  resource_owner_authenticator do
    User.find_by(id: session[:user_id]) || redirect_to(login_url)
  end

  resource_owner_from_credentials do |routes|
    User.find_by(email: params[:username]).authenticate(params[:password])
  end

  admin_authenticator do
    if current_resource_owner
      head :forbidden unless current_resource_owner.try(:admin)
    else
      redirect_to login_url
    end
  end

  # 省略
end
```
`admin`の権限を持ったユーザーでログインし、`http://localhost:3000/oauth/applications`にアクセスすると、OAuthアプリケーションの登録画面が表示されます。権限は予めRails Consoleなどで変更しておきましょう。

`New Application`をクリックし、新しいアプリケーションを登録します。

Nameを`Microposts App`, Redirect URIを`http://localhost:3000/`, Confidentialのチェックを外し、Scopeは`read write`と入力し、Submitをクリックすると、アプリケーションの登録が完了します。

アクセストークンの取得には、UIDとSecretを使います。
本来であればモバイルアプリケーションからHTTPリクエストで取得するものですが、実際に使えることを試すために、curlを使ってアクセストークンを取得してみましょう。

```bash
$ curl --location --request POST 'http://localhost:3000/oauth/token?grant_type=password&username=<USERNAME>&password=<PASSWORD>&client_id=<UID>&client_secret=<SECRET>&scope=read%20write'
```

設定が正しくできていれば、以下のようなレスポンスが返るはずです。

```json
{"access_token":"***","token_type":"Bearer","expires_in":7200,"scope":"read write","created_at":***}
```

### アクセストークンで認証を行うAPIの作成

アクセストークンの生成ができたので、次はアクセストークンを用いたAPIを作成するための実装を行います。

まずは、`User`モデルに以下の変更を行います。

```ruby
class User < ApplicationRecord
  # 省略
  has_many :access_grants,
    class_name: "Doorkeeper::AccessGrant",
    foreign_key: :resouce_owner_id,
    dependent: :delete_all
  has_many :access_token,
    class_name: "Doorkeeper::AccessToken",
    foreign_key: :resource_owner_id,
    dependent: :delete_all
  # 省略
end
```

`routes.rb`にAPI用のルーティングを記述します。

```ruby
Rails.application.routes.draw do
  # doorkeeperのインストール時に自動で追加される
  use_doorkeeper

  # 省略
  namespace :api do
    namespace :v1 do
      resources :users, only: [:index, :show] do
        get 'self', on: :collection
      end
      resources :microposts, only: [:create, :destroy]
      resources :feeds, only: [:index]
    end
  end
end
```

ルーティングの設定が完了したら、`app/controllers/api/v1`というディレクトリを作成し、その中に`application_controller.rb`を作成します。

```ruby
class Api::V1::ApplicationController < ActionController::Base
  private
    def current_user
      @current_user = User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
    end
end
```

次に、フィードを取得するコントローラを作成します。`feeds_controller.rb`を作成します。

```ruby
class Api::V1::FeedsController < Api::V1::ApplicationController
  before_action -> { doorkeeper_authorize! :read }

  def index
    @feeds = current_user.feed.paginate(page: params[:page])
  end
end
```

jbuilderはアクション毎にテンプレートを必要とするので、`app/views/api/v1/feeds/index.json.jbuilder`を作成し、以下のように実装します。

```ruby
json.array! @feeds, partial: 'feeds/feed', as: :feed
```

`before_action -> { doorkeeper_authorize! :read }`は、`read`権限を持つDoorkeeperアクセストークンを必要とすることを示します。

ここまで来れば、アクセストークンを使用してフィードを取得できるようになっているはずです。curlで試してみましょう。
アクセストークンは、リクエストヘッダの`Authorization`に格納します。トークンの前に`Bearer `という文字列を入れる必要があります。

```bash
$ curl --location --request GET 'http://localhost:3000/api/v1/feeds' --header 'Authorization: Bearer ***'
```

フィードがJSONで取得できていることがわかります。

```json
[
    {
        "id": 6,
        "content": "content of post",
        "picture_url": "/uploads/micropost/picture/***.jpg",
        "created_at_time_ago_in_words": "about 2 hours",
        "user": {
            "id": 1,
            "name": "someone1",
            "gravatar_url": "https://secure.gravatar.com/avatar/***",
            "is_current_user": true
        }
    },
```

同じように、MicropostsControllerも実装します。`create`, `destroy`アクションを実装するので、`write`権限を持ったアクセストークンのみ許可するように`before_action`を追加します。

```ruby
class Api::V1::MicropostsController < Api::V1::ApplicationController
  before_action -> { doorkeeper_authorize! :read }
  before_action -> { doorkeeper_authorize! :write }

  def create
    micropost = current_user.microposts.build(content: params[:content])
    if micropost.save
      head :created
    else
      render json: micropost.errors, status: :unprocessable_entity
    end
  end

  def destroy
    micropost = current_user.microposts.find_by(id: params[:id])
    return head :not_found unless micropost

    micropost.destroy
    head :no_content
  end
end
```

課題： ユーザー情報を取得するUsersControllerと、それに紐づくjbuilderのViewを実装しましょう。`index`, `show`, `self`の3つのアクションを実装する必要があります。`self`は、トークンの所有者の情報を返すアクションです。

具体的には、以下のようなJSONが取得できるようになればOKです。(この例は`index`アクションの結果を示しています)

```json
[
    {
        "id": 1,
        "name": "someone1",
        "gravatar_url": "https://secure.gravatar.com/avatar/***",
        "microposts_count": 2,
        "following_count": 1,
        "followers_count": 0,
        "is_current_user": false,
	// micropostsは取れても取れなくてもOKです
        "microposts": [
            {
                "id": 14,
                "content": "this is test",
                "created_at_time_ago_in_words": "8 days"
            },
            {
                "id": 12,
                "content": "posted",
                "created_at_time_ago_in_words": "about 1 month"
            },
        ]
    },
    {
        "id": 3,
        "name": "someone2",
        "gravatar_url": "https://secure.gravatar.com/avatar/***",
        "microposts_count": 1,
        "following_count": 0,
        "followers_count": 1,
        "is_current_user": false,
        "microposts": [
            {
                "id": 4,
                "content": "テスト",
                "created_at_time_ago_in_words": "about 2 months"
            }
        ]
    },
]
```

ヒント:

<details>

`app/views/users/_user.json.jbuilder`を編集することを検討すると良いかもしれません。

</details>

これで、APIの実装ができました。次からは、FlutterでAPIにリクエストをするアプリケーションを作っていきましょう。
