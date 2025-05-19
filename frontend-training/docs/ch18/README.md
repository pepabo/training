# 第 18 章　React 開発ことはじめ

## React や Vue の何がかつてのフロントエンドライブラリと比べて優れていたか

練習問題 1-3 のような画面をかつて JavaScript で実装しようとした場合、フォームから取得した値をデータとして持つのではなく、単純に画面に表示する要素として追記していただけでした。しかし、これだと 1-2 のような絞込み機能を実装することがとても難しくなります。仮に `species` を表示要素のどこかに書き込んでおいて、繰り返しでその値をチェックして絞込みの対象でなければ消去するという処理を実装するにしても、「猫絞込み→犬絞込みへの切り替え」「猫絞込み→全件表示」のような 2 アクションの操作に対応しようと思うと、「消去したデータを保管する変数」のようなものを設けなければいけません。今回は単純なアプリケーションですが、これが複雑化して例えばゲームのような画面になった時には、数え切れないほどのパターンの状態と変更が発生するようになります。

このような複雑な UI を実装する手段として、データの状態をどこかに保持しておいて（React の `useState` で作られる変数や、それこそ Vue の `data` のように）、変更があったら UI の方も書き換えるというアプローチが取られるようになりました（ React / Vue の動きに似ていないですか？）。しかし、これを手で実装していた時はいつ UI を書き換えるかも手動で設定しなければならず、その結果として変更の反映がされてないというバグが発生することがありました。それならば、毎秒（ゲームなら毎フレーム）データから UI を生成できればよかったのですが、 JavaScript で UI を書き換えるという処理はとても遅く、毎秒全部書き換えでは非常にストレスフルなアプリケーションが出来上がってしまいます。

先ほど「全部書き換え」と書いたのが要点で、 React や Vue はそこを HTML の構造を模したオブジェクトを作成しデータ変更の前後でどこが書き換わるかを検知し、 UI のその部分のみを置き換えているのです。 JavaScript オブジェクトの比較は UI の直接変更より十分に短い時間でできるので、データが置き換わった時に毎回自動でチェックするようなフックを仕掛けられるようになります。この HTML の構造を模したオブジェクトを **Virtual DOM** と言います。

この思想が優れている点は「宣言的に UI を書ける」ということ、さらに『データから自動で UI を生成できる、そしてその UI は書き換えの回数が最小化される』という考え方が、 Web フロントエンドに限らず UI を備えたスマートフォンのアプリケーションやデスクトップアプリケーションにも応用できるということです。これが [ReactNative](https://reactnative.dev/) や [Flutter](https://flutter.dev) といったものです。

ここで、「宣言的に UI を書ける」という点をもう少し深掘りしてみましょう。宣言的UIプログラミングとは、「何をするか」ではなく「どうあるべきか」を記述するアプローチです。これは単なる実装テクニックではなく、UIを考える根本的な思考法の転換を意味します。

従来の命令型プログラミングでは、「ボタンやテキストを変数に束縛し、クリックイベントを登録し...」というように一連の手順を指示していました。例えば、フォームのバリデーションを命令的に実装すると

```js
// 命令的アプローチ
const emailInput = document.getElementById('email');
const submitButton = document.getElementById('submit');

emailInput.addEventListener('input', function() {
  const email = emailInput.value;
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  
  if (emailRegex.test(email)) {
    submitButton.disabled = false;
  } else {
    submitButton.disabled = true;
  }
});

// フォーム送信時の処理
const form = document.getElementById('contact-form');
form.addEventListener('submit', function(event) {
  event.preventDefault();
  
  // 送信中の状態に変更
  emailInput.disabled = true;
  submitButton.disabled = true;
  submitButton.textContent = '送信中...';
  submitButton.classList.add('loading');
  
  // 送信処理（仮想的な非同期処理）
  setTimeout(function() {
    // 成功時の処理
    form.innerHTML = '<div class="success">送信完了しました！</div>';
  }, 2000);
});
```

- DOM要素を直接操作する
- 状態変化のたびに影響を受ける要素を手動で更新する
- イベント処理が複雑になり、管理すべき状態が増え、バグが発生しやすくなる

対して宣言的アプローチでは、「この状態のときはこのように見える」という関係性を定義します。UIの状態とその表示方法を明確に分離することで、命令的アプローチにおける問題を解決します。

```js
// 宣言的アプローチ
function Form() {
  const [email, setEmail] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);
  const isValid = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  
  async function handleSubmit(e) {
    e.preventDefault();
    setIsSubmitting(true);
    
    // 送信処理（仮想的な非同期処理）
    await new Promise(resolve => setTimeout(resolve, 2000));
    setIsSuccess(true);
  }
  
  if (isSuccess) {
    return <div className="success">送信完了しました！</div>;
  }
  
  return (
    <form onSubmit={handleSubmit}>
      <input
        value={email}
        onChange={e => setEmail(e.target.value)}
        disabled={isSubmitting}
      />
      <button 
        type="submit"
        disabled={!isValid || isSubmitting}
        className={isSubmitting ? 'loading' : ''}
      >
        {isSubmitting ? '送信中...' : '送信'}
      </button>
    </form>
  );
}
```

- UIの各状態を明示的に定義する
- 状態に応じたUIの表示を宣言的に記述する
- 状態の変更が自動的にUIへと反映される
- DOMの直接操作を抽象化し、「何を表示するか」にフォーカスする

宣言的アプローチによって、DOM操作という手段を分離し、開発者は「何を表示するか」という本質的な問題に集中できるようになりました。この思想転換により、フロントエンド開発はコードの記述方法から考え方そのものが変わり、複雑なUIを扱う際の認知的負荷が大幅に軽減されました。

開発者は「このボタンをどう変更するか」ではなく「このデータ状態ではUIはどうあるべきか」という、より抽象度の高い設計に注力できるようになったのです。また、ユーザーのインタラクションに対しても、「何が起こるべきか」という宣言的なアプローチに移行できました。

この根本的な考え方の変化こそが、ReactやVueが今なおフロントエンド開発のデファクトスタンダードとして広く採用され続ける最大の理由です。

宣言的UIと命令的UIの比較については、Reactの公式ドキュメントにも詳しく記載されているので、こちらも併せて参照してください。[How declarative UI compares to imperative ](https://react.dev/learn/reacting-to-input-with-state#how-declarative-ui-compares-to-imperative)

この項以外にもReactの公式ドキュメントでは、基本的な思想からReactの使い方まで分かりやすく網羅的にカバーされています。一読しておくと、より理解を深めることができるでしょう。

また、ここまでで宣言的アプローチを実現する方法として、「React や Vue」というまとめ方をしてきましたが、以降の資料ではReactを使った研修内容になっています。

両者の比較については様々な観点からの考え方がありますが、ここでは詳細については触れず、単に社内における採用実績をベースとしてReactを選定しています。

## React Router をセットアップする

それでは、いよいよ React を使っての開発に入ります。

最近の React アプリの開発は、React を直接組み込むよりもフレームワークを使った開発が主流です。公式ドキュメントでは Next.js, React Router, Expo などのフレームワークが紹介されています。

https://ja.react.dev/learn/creating-a-react-app

今回は、前研修で作成した Ruby on Rails を活かしつつ React を組み込みます。具体的には、[SPA Mode の React Router](https://reactrouter.com/how-to/pre-rendering#pre-rendering-with-ssrfalse) を使います。

Ruby on Rails アプリケーションは、[yasslab/sample_app のサンプルアプリケーション (第7版 第14章)](https://github.com/yasslab/sample_apps/tree/main/7_0/ch14) を想定しています (ただし Ruby on Rails のバージョンは `7.1.5.1` に上がっている)

```diff:Gemfile
- gem "rails",                      "7.0.4.3"
+ gem "rails",                      "7.1.5.1"
```

### 前提

- 前研修で作成した Ruby on Rails アプリ内に、フロントエンド用のディレクトリ `./frontend` を作成します
  - 開発環境では、React Router (Vite dev server の proxy) 経由で Rails サーバーにアクセスします
  - 本番環境では、React Router (Vite build) で静的ファイルを生成し、Rails サーバーの静的ファイルとして配信 (`./public` に配置) します
- Ruby on Rails で作ったロジックはそのまま利用します
- Ruby on Rails の View は利用せず、React Router でリビルドします

ただし、以下については時間の都合上考えないことにします。

- ログイン機構（ JWT あたりで実装するのですが長くなりすぎる）
- Rails を BFF (Backend for Frontend) にして Next.js のフロントエンドサーバを立てる
- Server Side Rendering （ React が吐き出す HTML をサーバ側で生成して処理高速化＋ SEO 対策）
- Redux （グローバルな状態管理）

なので、基本方針としては「ログイン後のページをリッチフロントエンドにする」という方向性にします。

### 1. React Router プロジェクトの作成

前研修で作成した Ruby on Rails アプリケーションのプロジェクトルートで作業します。
基本は [Installation | React Router](https://reactrouter.com/start/framework/installation) に沿って React Router を導入します。
(`Initialize a new git repository?` には `No` を選択します。`Install dependencies with npm?` はお好みで)

```bash
$ npx create-react-router@latest frontend

         create-react-router v7.6.0
      ◼  Directory: Using frontend as project directory

      ◼  Using default template See https://github.com/remix-run/react-router-templates for more
      ✔  Template copied

   git   Initialize a new git repository?
         No

  deps   Install dependencies with npm?
         Yes

      ✔  Dependencies installed

  done   That's it!

         Enter your project directory using cd ./frontend
         Check out README.md for development and deploy instructions.

         Join the community at https://rmx.as/discord
```

### 2. フロントエンドプロジェクトの設定

[React Router の SPA Mode](https://reactrouter.com/how-to/spa) を設定

```diff:frontend/react-router.config.ts
-  ssr: true,
+  ssr: false,
} satisfies Config;
```

### 3. 開発環境の起動

フロントエンドとバックエンドを別々に起動します。

```bash
# React Router の起動確認
cd frontend
npm run dev
```

http://localhost:5173/ にアクセスして、デフォルトのページが表示されれば OK です。

![npm run dev の結果](first-react-router-app.png)

### 4. React Router のルーティング設定

React Router のルーティングを確認します。

公式ドキュメント: https://reactrouter.com/start/framework/routing

```tsx:frontend/app/routes.ts
import { type RouteConfig, index, route } from "@react-router/dev/routes";

export default [
  index("routes/home.tsx"),
] satisfies RouteConfig;
```

`frontend/app/routes/home.tsx` を確認し、変更してみましょう

```tsx:frontend/app/routes/home.tsx
import type { Route } from "./+types/home";

export function meta({}: Route.MetaArgs) {
  return [
    { title: "Sample App" },
    { name: "description", content: "Ruby on Rails Tutorial Sample App" },
  ];
}

export default function Home() {
  return (
    <div className="center jumbotron">
      <h1>Welcome to the Sample App</h1>
      <p>
        This is the home page for the{" "}
        <a href="https://railstutorial.jp/">Ruby on Rails Tutorial</a>
        {" "}sample application.
      </p>
      <a href="/signup" className="btn btn-lg btn-primary">Sign up now!</a>
    </div>
  );
}
```

## 練習問題 1

1. React の開発に自信がない人は、React の公式チュートリアル「[チュートリアル：三目並べ – React](https://ja.react.dev/learn/tutorial-tic-tac-toe)」をやってみてください。
  - その際、 [React の流儀 – React](https://ja.react.dev/learn/thinking-in-react) も併せて読み、React の思想について理解を深めてください。

## React Router と Ruby on Rails の連携

#### 5. API サーバーとしての Ruby on Rails

Ruby on Rails のコントローラーを API として利用するための設定を行います。
ログイン以外の API サーバーとして利用する `resources` を `namespace :api do ... end` で囲み、 `/api` という名前空間に指定します。

```ruby:config/routes.rb
Rails.application.routes.draw do
  get    "/help",    to: "static_pages#help"
  get    "/about",   to: "static_pages#about"
  get    "/contact", to: "static_pages#contact"
  get    "/signup",  to: "users#new"
  get    "/login",   to: "sessions#new"
  post   "/login",   to: "sessions#create"
  delete "/logout",  to: "sessions#destroy"
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]

  namespace :api do
    resources :users do
      member do
        get :following, :followers
      end
    end
    resources :microposts,          only: [:index, :create, :destroy]
    resources :relationships,       only: [:create, :destroy]
  end
end
```

この例では、エンドポイント `/microposts` について、 `get '/microposts', to: 'static_pages#home'` を削除し、 `microposts_controller.rb#index` へと変更しています。コントローラー側も変更しておきましょう。

`/api` の名前空間を指定したコントローラーを `app/controllers/` から `app/controllers/api/` に移動します

- `app/controllers/users_controller.rb` -> `app/controllers/api/users_controller.rb`
- `app/controllers/relationships_controller.rb` -> `app/controllers/api/relationships_controller.rb`
- `app/controllers/microposts_controller.rb` -> `app/controllers/api/microposts_controller.rb`

移動後、 class 名を `Api::*` に変更します。

```rb:app/controllers/api/users_controller.rb
class Api::UsersController < ApplicationController
  .
  . 中略
  .
end
```

つぎに、React Router への一部のアクセスを Rails サーバーにプロキシするように設定します。これは開発環境用の設定となります。

```ts:frontend/vite.config.ts
import { reactRouter } from "@react-router/dev/vite";
import tailwindcss from "@tailwindcss/vite";
import { defineConfig } from "vite";
import tsconfigPaths from "vite-tsconfig-paths";

export default defineConfig({
  plugins: [tailwindcss(), reactRouter(), tsconfigPaths()],
  server: {
    proxy: {
      "/api": "http://localhost:3000",
      "/help": "http://localhost:3000",
      "/about": "http://localhost:3000",
      "/contact": "http://localhost:3000",
      "/signup": "http://localhost:3000",
      "/login": "http://localhost:3000",
      "/logout": "http://localhost:3000",
      "/account_activations": "http://localhost:3000",
      "/password_resets": "http://localhost:3000",
    },
  },
});
```

試しに `/api/users` でユーザー一覧の JSON を返すようにします。

```rb:app/controllers/users_controller.rb
class UsersController < ApplicationController
  # 動作検証のために一時的に :index を対象外にする
  # before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :following, :followers]
  before_action :logged_in_user, only: [:edit, :update, :destroy, :following, :followers]
  .
  . 中略
  .
  def index
    @users = User.paginate(page: params[:page])
    render json: @users
  end
  .
  . 中略
  .
end
```

http://localhost:3000/api/users.json にアクセスしてみましょう。JSON が表示されていたら設定は完了しています。

上記の `render json: @users` の例は簡単のためにこのように記述しておりますが、Ruby on Rails で JSON 形式のレスポンスを生成する方法の一つとして Jbuilder があります。
https://railsguides.jp/action_view_overview.html#jbuilder

この研修では取り扱いませんが、Ruby on Rails を API 専用のサーバーとして動かしたい場合は以下のドキュメントなどをご参考ください。
https://railsguides.jp/api_app.html

### 開発サーバーを起動するための Procfile.dev を作成

このままでは、Ruby on Rails のサーバーと React Router のサーバーを別々に起動しないといけませんので、一度にどちらのサーバーも起動する `bin/dev` を作成しましょう。

```bash:./bin/dev
#!/usr/bin/env sh

if ! gem list foreman -i --silent; then
  echo "Installing foreman..."
  gem install foreman
fi

# Default to port 3000 if not specified
export PORT="${PORT:-3000}"

# Let the debug gem allow remote connections,
# but avoid loading until `debugger` is called
export RUBY_DEBUG_OPEN="true"
export RUBY_DEBUG_LAZY="true"

exec foreman start -f Procfile.dev "$@"
```

```./Procfile.dev
web: bin/rails server
frontend: cd frontend && pnpm run dev
```

```bash
# 初回のみ
chmod +x ./bin/dev
bin/dev

# 2回目以降
bin/dev
```

参考: https://zenn.dev/ykpythemind/articles/78586345df229b#procfile%E3%82%92%E4%BD%9C%E6%88%90(optional)

### 6. フロントエンドから API サーバーに GET リクエストを送る

先ほどの users_controller.rb#index を利用して、React から JSON を取得して表示するコンポーネントを作成します。

```diff
diff --git a/frontend/app/routes.ts b/frontend/app/routes.ts
index 102b402..b0e8551 100644
--- a/frontend/app/routes.ts
+++ b/frontend/app/routes.ts
@@ -1,3 +1,6 @@
-import { type RouteConfig, index } from "@react-router/dev/routes";
+import { type RouteConfig, index, route } from "@react-router/dev/routes";
 
-export default [index("routes/home.tsx")] satisfies RouteConfig;
+export default [
+  index("routes/home.tsx"),
+  route("users", "./routes/users.tsx"),
+] satisfies RouteConfig;
```

```tsx:frontend/app/routes/users.tsx
import type { Route } from "./+types/home";
import { Users } from "../users/users";

export function meta({}: Route.MetaArgs) {
  return [
    { title: "Users" },
    { name: "description", content: "Users list" },
  ];
}

export default function UsersRoute() {
  return <Users />;
}
```

```tsx:frontend/app/users/users.tsx
import React, { useEffect, useState } from "react";
import { Link } from "react-router";

type User = {
  id: number;
  name: string;
  email: string;
  gravatar_id?: string;
  admin?: boolean;
  activated?: boolean;
};

export function Users() {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchUsers = async () => {
      try {
        setLoading(true);
        const response = await fetch("/api/users", {
          headers: {
            "Content-Type": "application/json",
          },
        });
        
        if (!response.ok) {
          throw new Error(`APIリクエストエラー: ${response.status}`);
        }
        
        const data = await response.json();
        setUsers(data);
        setError(null);
      } catch (err) {
        setError(err instanceof Error ? err.message : "ユーザー情報の取得中にエラーが発生しました");
        console.error("ユーザー情報の取得エラー:", err);
      } finally {
        setLoading(false);
      }
    };

    fetchUsers();
  }, []);

  if (loading) {
    return <div className="text-center my-4">読み込み中...</div>;
  }

  if (error) {
    return <div className="text-center my-4 text-red-600">{error}</div>;
  }

  return (
    <div className="container mx-auto px-4 py-6">
      <h1 className="text-2xl font-bold mb-6">ユーザー一覧</h1>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {users.length > 0 ? (
          users.map((user) => (
            <div key={user.id} className="border rounded-lg p-4 shadow-sm">
              <div className="flex items-center gap-4">
                {user.gravatar_id && (
                  <img
                    src={`https://secure.gravatar.com/avatar/${user.gravatar_id}?s=80`}
                    alt={`${user.name}のアバター`}
                    className="w-16 h-16 rounded-full"
                  />
                )}
                <div>
                  <h2 className="text-lg font-semibold">
                    <Link to={`/users/${user.id}`} className="text-blue-600 hover:underline">
                      {user.name}
                    </Link>
                  </h2>
                  <p className="text-gray-500">{user.email}</p>
                  {user.admin && <span className="bg-blue-100 text-blue-800 text-xs px-2 py-1 rounded">管理者</span>}
                </div>
              </div>
            </div>
          ))
        ) : (
          <p className="col-span-full text-center text-gray-500">ユーザーが見つかりませんでした</p>
        )}
      </div>
    </div>
  );
}
```

http://localhost:5173/users にアクセスしてみましょう。ユーザー一覧が表示されていたら成功です。


## 練習問題 2

1. `/api` 配下に移動した他のリソースも `users.tsx` のように React Router からアクセスできるようにしてみましょう。
2. 先ほどの `frontend/app/users/users.tsx` の例は、fetch する際に useEffect を使用しており、古典的なモデルとなっています。 [React API の `use`](https://ja.react.dev/reference/react/use) を使って書き換えてみましょ

## React Router から Ruby on Rails へPOSTする

WIP

API リクエスト (JSON) に対して CSRF トークン検証をスキップするための設定を行います。
この設定はセキュリティリスクを伴います。本番環境ではリスク評価を行った上で対策を講じてください。

```ruby:app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include SessionsHelper
  
  # API リクエストに対して CSRF トークン検証をスキップ
  skip_before_action :verify_authenticity_token, if: :json_request?
  
  private
  
  def json_request?
    request.format.json?
  end
  
  # ...
end
```

## 次回予告

ついに React を使ってフロントエンドを開発できるようになりました。次回は Ruby とは違う JavaScript 非同期コールバックモデルとその問題点、その問題点を解消した Promise や async/await について学びます。

{% endraw %}
