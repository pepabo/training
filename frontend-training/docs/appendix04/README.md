# 付録 3 　 Rails7 での準備

Rails 7(Rails Tutorial 第７版)では、それ以前の Rails チュートリアルとはフロントエンド周りの技術が一新され、Node.js 不要のフロントエンド環境をデフォルトとした内容になっていると思います。これは Rails アプリケーションでのフロントエンド開発においては１つの選択肢になり得ますが、一般的に多くのアプリケーションではまだまだ Node を利用したフロントエンド開発が主流です。そのため、この研修では Rails Tutorial 第７版で作成したアプリケーションに対して Babel や Webpack、Node.js といったツールを導入し進めることを前提としています。

Node 環境のセットアップは第 16 章で完了していると思います。Node.js のパッケージを管理するシステムである npm のセットアップがまだであればしておきましょう。

```
npm install -g npm
```

ここからは Rails 6 以前同様に npm で必要なパッケージを追加していきます。17 章の「Webpacker への依存を剥がす」を飛ばし、以降の手順を進めていきましょう。

必要なパッケージの追加が完了すると`package.json` `package-lock.json` `/node_modules`が新規で作成されていると思います。それぞれ ruby の場合、`Gamfile` `Gamfile.lock` `vendor/bundle`に相当すると認識しておくとよいでしょう。パッケージ群は Git 管理する必要はないので`.gitignore`の末尾に`/node_modules`を追加しておきましょう。

Rails Tutorial 第７版で作成したアプリケーションで利用している JavaScript は importmap を利用しているため、既存のものはこちらに任せたまま、新たに追加するコードについては webpack を利用するようにしていきます。そのため、既存の Javascript が格納されたファイルとは別に`/app/javascript/packs`フォルダを作成し、配下に`application.js`を作成します。Webpack の設定では、ここをエントリーポイントにして進められるようにしておきましょう。また、以降の資料ではここを作業ディレクトリとして置き換えて読み進めるようにしてください。

### 練習課題

1. ここまでできたら、 webpack-cli で[利用可能なコマンド](https://webpack.js.org/api/cli/) を見て、試しにバンドルファイルをビルドしてみましょう。 webpack.config.js で指定した ディレクトリに application.js のようなファイルができていれば成功です。成功していれば build したファイルも Git 管理の対象から除外しておきましょう。
2. 17 章の内容を参考に、Rails から JavaScript を読み込めるようにしましょう。
