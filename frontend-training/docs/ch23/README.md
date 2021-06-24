# 第 23 章　デプロイをする

ここまでの技術で SPA を一通り実装できるようになりました。最後に、このアプリケーションを Heroku もしくはマネクラにデプロイしてみましょう。

## Heroku へのデプロイ

`sample_app` を Heroku にデプロイする場合は、 `package.json` や `Gemfile` がプロジェクトルートに存在しないといけないので、 `sample_app` をコピーして新たなリポジトリを作成します。

```bash
$ cp -a sample_app ../sample_app
$ cd ../sample_app
$ git init
$ git add .
$ git commit
```

Heroku では、 NPM Script に `build` が定義されるとデプロイした時に自動的に `npm run build` が実行されるようになります。 `package.json` に以下を記述してみましょう。

```json
// package.json

{
  // 略
  "scripts": {
    "build": "webpack --mode production",
    "watch": "webpack --mode development --devtool eval-cheap-module-source-map --watch",
    "typecheck": "tsc -p . --noEmit"
  },
  // 後略
}
```

### Procfile がまだ作られていない場合

現状では `Gemfile` と `package.json` が両方存在しているので、 Heroku 側がこれは何の言語で書かれたアプリケーションか認識できなくなってしまっています。 `Procfile` というファイルを設置すると Heroku 側がサーバを起動するコマンドを認識するようになります。

```
web: bundle exec rails server -p $PORT
```

（注意！！： `package.json` と `package-lock.json` に使用するパッケージの名前を書いてコミットしておかないと正しくデプロイされません。特に `--save` のつけ忘れに注意してください。）

NPM Scripts と `Procfile` の記述が終わったら Heroku への push を実行してみましょう。アプリケーションのビルドと起動が確認できるようになります。これでフロントエンド研修本編は以上です。お疲れ様でした。

## マネクラへのデプロイ

TBD
