# フロントエンド・ SPA 研修

GMO ペパボ株式会社エンジニア・デザイナー向けフロントエンド・ SPA (Single Page Application) 講習のドキュメントです。

一般的にウェブアプリケーションにおけるフロントエンド領域では、ユーザーがシステムと対話するために必要な様々な技術を取り扱います。
たとえば、以下のようなものがあると考えられます。

- ユーザー体験のよいユーザーインタフェースの設計や、それを実現するための実装 (たとえばJavaScriptなどの) 技術
- システムとユーザーインタフェースがやりとりするためのインタフェース (Web APIと呼ばれるようなもの)
- ユーザーインタフェースの素早い提供のためのサーバサイドにおける最適化
- キャッシュ機構
- アクセシビリティ
- などなど...

この研修では、これらの領域の中から以下のような内容を学習することができます。

* ECMAScript / JavaScript
* JavaScript のモジュールシステム
* JavaScript ビルドツール
* 実行環境 / パッケージマネージャー
* React の初歩的な使い方
* 非同期、コールバック、 Promise, async/await
* SPA とは何か（JavaScript による URL ハンドリング、pushState/popState）
* フロントエンドのテストについて

このリポジトリが Rails Tutorial を一通り終わらせているものとなっているので、ここから `git clone` して使ってもらっても大丈夫です。
とはいえ、この研修では一部 Ruby と Rails の知識が必要とされるので、Rails Tutorial を先にやっておくことを推奨します。

Rails Tutorial が 14 章で終了なので、この研修教材ではその続きという意味も含めて 15 章スタートになっています。

## 大前提

 **それが何かを理解していない状態でインターネットで拾ってきたコードをコピペするのが一番危険です**。

公式のドキュメント（使っているツールのバージョンに合致しているもの）の一次情報に当たること、万が一動かないということがあった場合そのツールのコード、GitHub issue, Pull Request に当たること。
これらが重要です。これはエンジニアリングにおける良い習慣のひとつなので、しっかりと意識してください。

## Web 上の参照できる資料

* [JavaScriptの入門書 #jsprimer](https://jsprimer.net/)
  * モダンフロントエンド開発において、 JavaScript と呼ばれているものはおおよそ ECMAScript 20xx を指しています（なぜそうなっているかは後述）。JavaScript/ECMAScript 20xx の言語仕様や各種 API に困った時はこのサイトを見てください。
* [ドキュメントオブジェクトモデル (DOM) - Web API](https://developer.mozilla.org/ja/docs/Web/API/Document_Object_Model)
  * JavaScript には言語仕様や各種型、 API とは別にブラウザに表示されるページを操作したり、ブラウザ固有の機能を動作させる DOM API が存在します。
* [Node.js Documentation](https://nodejs.org/api/documentation.html)
  * Node.js （雑に言うとコマンドラインから JavaScript が動かせるもの）にも固有の API が存在します。バージョンに対応した一次ドキュメントを参照してください。
* [Can I use...](https://caniuse.com/)
  * あるブラウザのあるバージョンが最新の言語仕様や機能に対応しているかを調べられます。
* [React Docs](https://ja.react.dev/)
  * React の使い方について困ったときはまず公式ドキュメントを調べてみましょう。
* [Vue.js ガイド](https://ja.vuejs.org/)
  * Vue のドキュメントは公式の翻訳が一番充実しているので、これを調べることをお勧めします。
