# 付録 2　フロントエンドのテスト

{% raw %}

フロントエンドのテスト、特に Vue のテストには Rails のテストに近い分類が存在します。フロントエンドには 3 種類のテストが存在し、一つは純粋なロジックの正しさを確かめるユニットテストです。それとは別に、 Vue コンポーネント単位のテストが存在し、これに対応する Rails のテストは存在しません。最後に Rails の system spec として書くエンドツーエンドのテストが存在しますが、 Rails 上で Vue をマウントしている場合、そんなに手厚い system spec を書くことはできません。

## ユニットテスト

フロントエンドのテストにも RSpec/MiniTest などのように選択肢が複数存在します。 AVA や Tap, Tape, Mocha などが例として挙げられますが、ここでは最近スタンダードとして使われている [Jest](https://jestjs.io/ja/) を使用します。まずはインストールしてみましょう。テストに使うライブラリは本番環境では使用しないので `--save-dev` オプションを `--save` オプションの代わりに使います。

```
$ npm install jest --save-dev
```

JavaScript のユニットテストも基本的にはファイル単位で行います。まずは最も簡単な例として単純に引数を足し算して返す関数を定義してテストしてみましょう。 [Jest の Getting Started](https://jestjs.io/docs/en/getting-started.html) に記述されている `sum.js` のテストを試しに書いてみてください。

現在は Micropost アプリケーションにこのような純粋なロジックのみのコードは存在しないので、これだけでユニットテストの入門は終了になります。しかし、大事なことなのでここではテストコードのディレクトリ構成について説明します。 JavaScript のテストのディレクトリ構成には様々な流派があり、例えば以下のようなものがあります。

* テストしたいファイルと同じディレクトリに置いて `.test.js` や `.spec.js` `_test.js` `_spec.js` にする
* テストしたいファイルと同じディレクトリに `__tests__` ディレクトリを作成してその下にファイルを置く
* テストしたいファイルはそもそも `src` `lib` などのディレクトリに置き、テストは `test` `spec` などのディレクトリに置く

Jest はデフォルトで前の二つは実行されるようになっています。 `test` ディレクトリなどに置いても `.test.js` などのファイル名にしておけば対象になります。かなり柔軟な仕様ではありますが、実際のプロジェクト開発ではディレクトリ規約に沿った配置をすることが重要です。

今回作っている Micropost アプリケーションでは、テストコードはテスト対象と同じディレクトリに配置して `.test.js` という名前にするようにしましょう。例えば、 `app/javascripts/packs/foo.js` をテストするファイルは `app/javascripts/packs/foo.test.js` とします。

## コンポーネントのテスト

コンポーネントのテストをするためには、まず二つの要素を用意する必要があります。一つは Jest の実行時に Vue SFC をトランスパイルして js ファイルとして読み込めるようにするツールです。そしてもう一つは、 Jest を実行しているのは Node.js ですから、ブラウザの動きをエミュレートして Vue SFC がどのような DOM を構築するかをデータ構造として返す API です。それぞれ前者が [vue-jest](https://github.com/vuejs/vue-jest) 後者が [@vue/test-utils](https://github.com/vuejs/vue-test-utils) というパッケージが担当します。それでは、これらをインストールしましょう。インストールが完了したら、 Jest が Vue を処理できるように `package.json` にエントリを追加します。

また、それとは別で `import` を `require` に Node.js 実行時に直すようにします。 `import` を `require` に直すのは Babel が対応しているので、これを Jest 実行時に呼び出す babel-jest と、変換定義である babel-preset-env も同時にインストールします。インストール後には `.babelrc` に定義を記載します。

```
$ npm install vue-jest @vue/test-utils babel-jest babel-preset-env --save-dev
```

```json:package.json
{
  // ...
  "jest": {
    "moduleFileExtensions": [
      "js",
      "json",
      // *.vue ファイルを処理するように Jest に指示する
      "vue"
    ],
    "transform": {
      // vue-jest で *.vue ファイルを処理する
      ".*\\.(vue)$": "vue-jest",
      // babel-jest で js を処理する
      "^.+\\.js$": "<rootDir>/node_modules/babel-jest"
    }
  }
}
```

```json:.babelrc
{
  "presets": [["env", { "modules": false }]],
  "env": {
    "test": {
      "presets": [["env", { "targets": { "node": "current" } }]]
    }
  }
}
```

まずはシンプルな文言を表示するだけのコンポーネントをテストしてみましょう。 22 章で作成した HelloVueRouter コンポーネントをテストします。 `app/javascripts/packs/HelloVueRouter.test.js` に以下のようなコードを作成します。

```js:app/javascripts/packs/HelloVueRouter.test.js
import { mount } from '@vue/test-utils';
import HelloVueRouter from './HelloVueRouter.vue';

describe('HelloVueRouter', () => {
  test('has greeting message', () => {
    const wrapper = mount(HelloVueRouter);
    expect(wrapper.text()).toEqual('Hello, Vue Router!');
  });
});
```

これで前節で定義した `npm run test` を実行するとログにこのテストが実行された結果が表示されるはずです。

そしてここで Vue SFC として分割することのメリットを考えてみてみましょう。多くの SPA では、ページ表示の際に Web API へとアクセスしデータを取得した上でそのデータに基づいて表示するという処理を行います。その中ではある条件の時のみ表示する要素が存在します（この教材では FeedItem の削除ボタンがそうですね）。これを一枚岩のコンポーネントとして作ってしまうと、実際の Web API が存在しないとテストできないという事態が発生しますね。そこでコンポーネントをデータ取得する部分と表示部分に切り分け、表示部分のみテストするということにメリットが存在するわけです。

## 練習問題

FeedItem が `props` の値によって削除ボタンの表示・非表示が切り替わることをテストするコードを書いてください。表示されるパターン、非表示になるパターンの２つのテストケースが存在します。 `props` は[マウンティングオプション](https://vue-test-utils.vuejs.org/ja/api/options.html#context)として定義できます。マウント後の要素アクセスは [`find`](https://vue-test-utils.vuejs.org/ja/api/wrapper/#find-selector) という API が定義されています。

## CI

これまで GitHub Enterprise 上にリポジトリを作成しているものと思いますので、ひとまずは Drone での CI のみ記載しています。 GitHub や Bitbucket 上に作成している場合には CircleCI での CI をします（そのうち書く）。

### Drone

[ci.pepalab.com](https://ci.pepalab.com) で自分のリポジトリを有効にした上で、以下のような `.drone.yml` を作成してプッシュしてください。

```yaml:.drone.yml
kind: pipeline
name: default
steps:
  - name: test
    image: node:12
    commands:
      - npm install
      - npm run test
```

### CircleCI

TBD

## 次回予告

堅牢なフロントエンドコードを書くための車輪の両輪のうちのもう一つ、 TypeScript の書き方と Vue SPA アプリケーションへの導入について学びます。

{% endraw %}
