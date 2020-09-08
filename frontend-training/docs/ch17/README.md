# 第 17 章　Rails フロントエンド環境セットアップ

前回 Parcel というツールを使って Rails フロントエンド開発をするという方針に決めました。そのためには、 Parcel をインストールしなければいけませんし、 Parcel を使っているということをリポジトリに残さないといけません。ちょうど、 Rails の開発に当たって `rails new` したとき `gem 'rails'` と書かれている `Gemfile` が生成されたり、そこに `gem 'bootstrap-rails'` と追記したりしたようにです。

JavaScript, というよりは Node.js の世界では `package.json` というファイルが `Gemfile` に相当し、 `package-lock.json` が `Gemfile.lock` に相当します。なので、何かライブラリをプロジェクトにインストールする場合、これらのファイルをリポジトリにコミットする必要があります。

まずは `package.json` を作りましょう。生成するコマンドは `npm` にあります。

```
$ npm init -y
$ npm init  # 対話的に内容を決めたい場合はこちら
```

これに Parcel をインストールする記録を残します。 `package-lock.json` はコマンド実行で自動生成されるので気にしなくて大丈夫です。

```
$ npm install parcel-bundler --save
```

`--save` オプションとは別で `--save-dev` というオプションもあります。`--save-dev` は `Gemfile` の `group :development, :test` のようなもので、開発時とテストの時のみ使うものにつけるオプションです。今回インストールするものは本番環境でサーバのように動かすものではないので `--save-dev` を使います。

インストールが正常終了したことを確認したら、 Parcel のコマンドが実際に使えることを確認します。 `npx parcel --help` というコマンドを実行すると、ヘルプがターミナルに出力されますね。ところで、なぜ `parcel --help` とだけ入力することでコマンド実行ができないのでしょうか。 `npm` コマンドを用いてインストールしたライブラリは `node_modules` ディレクトリの中に配置されるということを前述しました。 `parcel` コマンドも `node_modules/.bin` という特殊なディレクトリの中に配置されており、これを呼び出そうと思うと `./node_modules/.bin/parcel --help` のような煩雑なコマンドを入力しなければなりません。これを簡略化できるのが `npx` コマンドなのです。

（ tips ・私見：様々なツールのドキュメント類に書かれている `npm install -g parcel-bundler` のような `-g` オプションをつけることにより Node.js のシステム自体にグローバルにインストールすることもでき、この時は `parcel` とコマンド入力するだけで動かすことができるようになります。しかし、この方法を採用すると本番環境でも `npm install -g` をしないといけなくなるので、グローバルではないインストールの方が可搬性があってより良いと思います。要らなくなったら `node_modules` 消したら終わるし。）

## 練習課題

1. ここまでできたら、 [Parcel](https://parceljs.org/) の Hello World に従って、試しにファイルを作ってみましょう。もちろんコマンドには `npx` を先頭につけることをお忘れなく。
2. 前のチャプターで moment をインストールしていますね。これを読み込んで画面に現在時間を表示するコードを書き、 Parcel でバンドリングしてみてください。

（この練習問題で作ったファイルはこれ以降の研修で使わないので、このタイミングで消しておきましょう。）

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
