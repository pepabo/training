# Rails Tutorial のサンプルアプリケーション

これはフロントエンド研修に使う教材のアプリケーションです。
doc にあるテキストを読みながら、実際に SPA を作成していきます。
アプリケーションとしては　[Ruby on Rails チュートリアル：実例を使って Rails を学ぼう](https://railstutorial.jp/) を最終章まで完走した状態から一部機能（メール送信・ AWS S3 ）を除外した状態になっています。

## 使い方

フロントエンド研修を受ける場合は、 [pepabo/frontend-training の課題の提出方法](https://github.com/pepabo/frontend-training/#課題の提出方法について) に従ってください。リポジトリを作成したら、 rbenv と ruby-build を Homebrew なりでインストールしておいてから、セットアップコマンドを実行します。

```
$ bin/setup
```

その後、 Rails サーバを立ち上げます。

```
$ rails server
```
