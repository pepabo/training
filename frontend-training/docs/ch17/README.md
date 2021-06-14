# 第 17 章　Rails フロントエンド環境セットアップ

## Webpacker への依存を剥がす

前回 Webpacker を剥がして素の webpack を直接設定するという方針に決めました。そこでまずは Rails が生成した Webpacker 関連のファイルを削除していきましょう。

Gemfile から gem を削除するコマンドは `bundle remove` でしたね:

```bash
bundle remove webpacker
bundle install
```

`bin` ディレクトリや `config` ディレクトリの下にも Webpacker 関連の実行ファイルや設定ファイルがあるので、これも削除しましょう:

```bash
rm bin/webpack*
rm config/webpacker.yml
rm -rf config/webpack
```

ところでみなさんは Rails Tutorial 第8章で `yarn add jquery@3.4.1 bootstrap@3.4.1` というコマンドを打ったことを覚えていますか。その結果 `package.json` というファイルの `dependencies` に `jquery` と `bootstrap` が追加されたことがわかったと思います。

JavaScript, というよりは Node.js の世界では `package.json` というファイルが `Gemfile` に相当し、 `package-lock.json` （Yarn を使っている場合は `yarn.lock` ）が `Gemfile.lock` に相当します。今いるプロジェクトで利用しているライブラリ（Node.js の世界では「パッケージ」と呼ばれます）とその依存関係がこれらのファイルに記録されているのです。なので、何かライブラリをプロジェクトにインストールしたりアンインストールしたりした場合、これらのファイルをリポジトリにコミットする必要があります。

まず `@rails/webpacker` をアンインストールしてしまいましょう:

```bash
npm uninstall @rails/webpacker
```

`package-lock.json` はコマンド実行で自動生成されます。

（注意：Webpacker が Yarn に依存しており Rails Tutorial でも `yarn` コマンドが使われていたので無用な混乱を避けるためにここまでの章では `yarn` コマンドを使ってきましたが、現時点で Webpacker 自体は取り除けたので Yarn への直接的な依存も無くなったはずです。なのでこれ以降は `npm` コマンドを使って研修を進めていくことにします。このとき `yarn.lock` は不要になるので削除してしまってください。

自分は `yarn` のほうが好きだ！というかたは `yarn` を使いつづけていただいてももちろん構いません。）

`package.json` について、もう1つ知っておくべきことがあります。 `package.json` 内をよく見ると `dependencies` のほかに `devDependencies` という key があることに気づくと思います。 [devDependencies](https://docs.npmjs.com/cli/v6/configuring-npm/package-json#devdependencies) は npm ライブラリを開発して公開するという文脈においてはライブラリ開発時にのみ必要となる依存ライブラリをこちらに書き、 `dependencies` にはライブラリがユーザーとして利用される際に必要となる依存ライブラリのみを書く……といった目的があったりしますがここではいったん置いておいて、私たちが Web アプリケーションを作ってデプロイするという文脈では、アプリケーション実行時に必要な依存ライブラリを `dependencies` に、それ以外の依存ライブラリを `devDependencies` に書く、という区別で良いと思います。
典型的にはトランスパイルやバンドルに必要なライブラリやテストフレームワークなどが `devDependencies` に、 `@babel/runtime` や `core-js` などといったライブラリが `dependencies` によく置かれます。

アプリケーションの動作的にはすべてのライブラリを `dependencies` に書いてもおそらく変わらないのですが、Heroku にアプリケーションをデプロイする際はアプリケーションのビルド後に `devDependencies` に宣言されているライブラリが `node_modules` ディレクトリから [削除される](https://devcenter.heroku.com/articles/nodejs-support#package-installation) ので、そのぶん dyno サイズを小さくできるというメリットがあります。

さて、Rails Tutorial を終えた時点では `webpack` と `webpack-cli` が `dependencies` 内に宣言されていますが、webpack はモジュールバンドリングのためだけに必要なものでありアプリケーション実行時には必要ないので、本来 `devDependencies` にあるべきものです。そこで以下のコマンドを実行しましょう:

```bash
npm install --save-dev --save-exact webpack@5.38.1 webpack-cli@4.7.2
```

`--save-dev` は `Gemfile` の `group :development, :test` のようなもので、開発時とテストの時のみ使うもの（`devDependencies` に追加したいもの）につけるオプションです。

`--save-dev` オプションとは別で `--save-prod` というオプションもあります。このオプションをつけてインストールしたパッケージは `dependencies` に追加されます。がしかし、あえてこのオプションをつける必要に駆られる機会はほとんどないでしょう。というのも npm v5.0.0 からは `npm install` のデフォルトの動作が「`dependencies` に追加する」になったからです [（当時の公式ブログ記事）](https://blog.npmjs.org/post/161081169345/v500) 。古いドキュメントや記事にはさらに同じ意味の `--save` というオプションが記載されていることもあるのですが、これも今となっては無視して良いでしょう。

`--save-exact` オプションはインストールするパッケージのバージョンを [semver による範囲指定](https://docs.npmjs.com/cli/v6/using-npm/semver#ranges) ではなく正確なバージョンの値で指定するオプションです。Rails Tutorial で `jquery` や `bootstrap` のバージョンを正確に指定してインストールしていたことに倣っています。

（tips： `--save-dev` には `-D`、 `--save-exact` には `-E` という短縮形がそれぞれ存在します。さらに `install` コマンド自体も `i` という短縮エイリアスが存在します。
なので、上記のコマンドは `npm i -D -E webpack@5.38.1 webpack-cli@4.7.2` と書いても同じことです。）

さらに Babel を使うのに必要なパッケージもまとめてインストールします。入門記事という性格上、これらのパッケージについて詳しく解説することは避けます。いったんこういうものだと思ってください（詳しく知りたいかたは [Babel の公式ドキュメント](https://babeljs.io/docs/en/) や各パッケージの GitHub リポジトリの README などを読んでみるとよいでしょう）。

```bash
npm install --save-dev --save-exact @babel/core@7.14.6 @babel/preset-env@7.14.5 babel-plugin-macros@3.1.0 @babel/plugin-transform-runtime@7.14.5
npm install --save-exact @babel/runtime@7.14.6 core-js@3.14.0
```

これらは `@rails/webpacker` の依存関係のなかに隠されていたので今まで意識することはなかったのですが、先ほど `@rails/webpacker` はアンインストールしてしまったので必要なものをここで明示的にインストールし直しています。
（Rails や Webpacker と関係なく始めたプロジェクトであればおそらく `@babel/core` と `@babel/preset-env` だけあれば Babel を（ミニマルな設定において）使うことができると思います。それ以外にここでインストールしているパッケージたちは Rails 6 がデフォルトで作成する `babel.config.js` の設定に沿って必要になっているものです。）

### webpack.config.js

webpack を使うために必要な設定があと1つ残されています。それが `webpack.config.js` の設定です（みなさんも名前を聞いたことがあるかもしれませんね）。

`webpack.config.js` の設定は複雑で奥が深く、それだけで1つの大きなトピックになります。この入門記事で `webpack.config.js` の書き方について深入りすることもしないつもりです。

複雑とは言いましたが Rails Tutorial を終えた状態でのコードをバンドルするだけであれば以下のような設定を書けば十分かと思いますので、これを使ってください:

```js:webpack.config.js
const path = require('path');
const webpack = require('webpack');

module.exports = {
  entry: path.resolve(__dirname, 'app/javascript/packs/application.js'),

  output: {
    filename: '[name].[contenthash].js',
    path: path.resolve(__dirname, 'public/packs'),
    clean: true,
  },

  module: {
    rules: [
      {
        test: /\.m?js$/,
        exclude: /(node_modules|bower_components)/,
        use: {
          loader: 'babel-loader',
        },
      },
    ],
  },

  resolve: {
    modules: ['node_modules', path.resolve(__dirname, 'app/javascript')],
    extensions: ['.js', '.json', '.wasm'],
  },

  plugins: [
    new webpack.ProvidePlugin({
      $: 'jquery',
      jQuery: 'jquery',
    }),
  ],
};
```

また `babel-loader` という [loader](https://webpack.js.org/concepts/loaders/) も必要になるのでインストールしてください:

```bash
npm install --save-dev --save-exact babel-loader@8.2.2
```

Loader とは簡単に言うと「Webpack でコードをバンドルする前にコードに対して何らかの前処理を行ってくれるもの」です。例えば `babel-loader` は ES2015 以上の言語機能を使って書かれたコードを（webpack によるバンドル前に）ES5 にトランスパイルするために必要というわけです。

インストールが正常終了したことを確認したら、 webpack のコマンドが実際に使えることを確認します。 `npx webpack help` というコマンドを実行すると、ヘルプがターミナルに出力されますね。ところで、なぜ `webpack help` とだけ入力することでコマンド実行ができないのでしょうか。 `npm` コマンドを用いてインストールしたライブラリは `node_modules` ディレクトリの中に配置されるということを前述しました。 `webpack` コマンドも `node_modules/.bin` という特殊なディレクトリの中に配置されており、これを呼び出そうと思うと `./node_modules/.bin/webpack help` のような煩雑なコマンドを入力しなければなりません。これを簡略化できるのが `npx` コマンドなのです。

（ tips ・私見：様々なツールのドキュメント類に書かれている `npm install -g` のような `-g` オプションをつけることにより Node.js のシステム自体にグローバルにインストールすることもでき、例えば `npm install -g webpack webpack-cli` とすれば `webapck` とコマンド入力するだけで動かすことができるようになります。しかし、この方法を採用すると本番環境でも `npm install -g` をしないといけなくなるので、グローバルではないインストールの方が可搬性があってより良いと思います。要らなくなったら `node_modules` 消したら終わるし。それに例えばあるプロジェクトの `webpack.config.js` で特定バージョン以上でないと利用できない機能を使っていたりした場合、それ未満のバージョンの `webpack` がグローバルにインストールされていたら単なる `webpack` コマンドでは動かないでしょう。プロジェクト内に閉じた環境にインストールして利用パッケージのバージョンを一致させることがベストプラクティスであると思います。）

## 練習課題

1. ここまでできたら、 [webpack-cliで利用可能なコマンド](https://webpack.js.org/api/cli/) を見て、試しにバンドルファイルをビルドしてみましょう。もちろんコマンドには `npx` を先頭につけることをお忘れなく。 `public/packs` ディレクトリに `main.ce5b5fc52a137b3fd42e.js` のようなファイルができていれば成功です。

## Rails から読み込めるようにする

Parcel を動かすところまでできたなら、次は Rails へ組み込んで web アプリの中に表示できるようにします。これまでの Rails 開発であれば、 `rails server` コマンドを実行するとサーバが立ち上がり、 JavaScript や CSS を含んだアセットもいい感じに取得することができるようになっていましたが、これからは JavaScript を Parcel が出力したものを使うため、それを `<script>` タグで読みに行くようにしなければいけません。

ひとまずは Parcel を開発のための watch モードで動かします。エントリポイントとなる `index.html` は `app/javascripts/packs` に置いて（これは `webpacker` gem のファイルの置き場所と同じにしています）、 `public/packs` というディレクトリに出力し、 `http://localhost/packs/index.js` のような URL でアクセスできるようにします。 Parcel がファイルを生成するディレクトリは自動的にファイルが削除されたりするので、このように `public` のなかにサブディレクトリを掘って運用することにします。

それを実現する Parcel watch コマンドが以下の通りです。

```
$ npx parcel watch app/javascripts/packs/index.html -d public/packs --public-url /packs/ --hmr-port 50000
```

色々オプションが付いていますがこのようにするという形で一旦覚えておいてください。このままだとコマンドが少し長いですね。これを記録して簡単なコマンドとして実行できる NPM Scripts という機能があります。 `package.json` に以下を書いてみてください。

```json:package.json
{
  // ...
  "scripts": {
    "watch": "parcel watch app/javascripts/packs/index.html -d public/packs --public-url /packs/ --hmr-port 50000"
  }
}
```

すでに `scripts` のなかに `test` が存在していた場合、それとは別に書いておきましょう（注意： `npx` は必要なくなります）。保存後に `npm run watch` を実行すると、先ほどと同じ結果になりましたね。 `public/packs` の中身は Parcel が自動的に生成するファイルであるため、このパスも `.gitignore` に記載しておきましょう。

しかしここで問題があります。 `public/packs` に生成されたバンドル済みの js ファイルは `packs.e31bb0bc.js` のようなファイル名となり、 `app/views/layouts/application.html.erb` に記述されている `<%= javascript_include_tag 'application' %>` のような方法で読み込めなくなっています。この js ファイル名はバンドル元の js ファイルが変更されると別のファイル名になるためです。なぜこのようなことになっているかと言うと、ブラウザは同じ URL の js ファイルをキャッシュしており、変更したファイルを同じ名前でサーバ上に配置しなおしたとしても、リロードしないと変更が反映されないようになっています。そのため、バンドルした js ファイルの内容が異なる場合には衝突しないファイル名をつけることで、リロードをせずとも変更が反映されるようにしているのです。Rails を Heroku で動かすと `application-xxxxxxx.js` のようなファイル名になっているのもこれが理由です。

Rails から `public/packs` に存在するバンドル済み js ファイルを読み込むヘルパーメソッドを作りましょう。そのためには、バンドル済み js ファイルがどれかということがわかるようにしなければなりません。 [mugi-uno/parcel-plugin-bundle-manifest](https://github.com/mugi-uno/parcel-plugin-bundle-manifest) というバンドル済 js ファイルがどれであるかを記載した .json ファイルを吐き出してくれる小さな Parcel プラグインが公開されているので、これを使いましょう。これまでと同じように NPM を使ってインストールしてみてください。 `npm run watch` した時に使うに当たっては特に細かな設定は必要ありません。 `npm run watch` を再実行して、 `public/packs/parcel-manifest.json` が生成されたことを確認してください。

（注意： `app/javascripts/packs/index.html` に `<script src="./index.js"></script>` を書いておかないと `index.js` はトランスパイルされません。これは、 Parcel が実際にコードで使われているファイルのみを抽出してトランスパイルするからです）

実際に `app/helpers/application_helper.rb` に `javascript_pack_tag` ヘルパーメソッドを書いて、 `app/views/layouts/application.html.erb` から呼び出すようにします（ちなみに `javascript_pack_tag` という名前は `webpacker` gem に存在するもので、そこからインスパイアを受けています）。少し複雑なコードになるので、以下のコードを読み解きながら実装してください。

```ruby:app/helpers/application_helper.rb
module ApplicationHelper
  def javascript_pack_tag(name)
    javascript_include_tag(manifest["#{name}.js"])
  end

  private

    def manifest
      @manifest ||= load
    end

    def load
      manifest_path = Rails.root.join('public', 'packs', 'parcel-manifest.json')
      if manifest_path.exist?
        JSON.parse manifest_path.read
      else
        {}
      end
    end
end
```

これで `app/views/layouts/application.html.erb` に `<%= javascript_pack_tag 'index' %>` と書くとバンドル済 js が `<script>` タグで読み込まれるようになります。開発環境をリロードして、読み込まれていることを確認してください。

## 次回予告

ついに本題であるところの [Vue](https://jp.vuejs.org) を導入し、本格的なフロントエンド開発に乗り出します。 Vue や React の何が jQuery などの他のフロントエンドライブラリと比べて優れているかについて知ることができます。
