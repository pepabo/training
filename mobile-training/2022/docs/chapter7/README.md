# 7章 自由にアプリを作ってみる

今までの章で行ったことを活用してアプリを作ってみましょう。

- APIを利用する場合
    - GraphQL APIを利用する
        - APIを活用する場合、APIの機能ベースのアプリとなると思うので、使いたいAPIを探してみましょう。
            - 参考) 
                - https://github.com/IvanGoncharov/graphql-apis
        - SUZURI
        - Qiita
        - ...
        - (著作権に問題ありそうなものは公開しないようにしましょう)
    - REST APIを利用する
        - GraphQLのAPI がこんなに数が少なく見つからないと思わなかったので、REST APIも使えた方が自由にアプリが作れますね。
        - APIを活用する場合、APIの機能ベースのアプリとなると思うので、使いたいAPIを探してみましょう。
            - 参考)
                - https://github.com/public-apis/public-apis#index
                - https://rapidapi.com/collection/free-apis-no-credit-card
                - https://rapidapi.com/collections
                - https://www.google.co.jp/search?q=api+%E7%84%A1%E6%96%99&ie=utf-8&oe=utf-8&client=ubuntu&channel=fs
        - SUZURI
- ユーザー認証を行う場合は、OAuth2.0で行う。
    - サービスによって認証の方法が違い個別の対応が大変で時間がかかりそうなので、github以外でOAuthを行うのは避けてもらった方がよさそうです。
    - SUZURIやQiitaなど、個人用のアクセストークンを発行できる場合、そちらで認証を行ってください。
- ウィジェットは公式ドキュメントを参照したりして、色々使ってみてください
- Flutterパッケージは自由に追加してみてください
    - スター数やライセンスなども確認してください。
- プラットフォームお好みで
    - パッケージを導入する際には対応プラットフォームを確認する
- 時間的には3画面ぐらいのアプリがちょうど良いかも
    - 例)
        - 都市を保存 > 都市ごとの天気情報を表示
        - 図鑑作る
        - 画面イメージ参考: https://www.uisources.com/home, https://giginc.co.jp/blog/giglab/apps-uidesign, 

どの様なアプリを作るか、ゴールを決めてワクワク作りましょう。

```
例)
# 自分で設定したゴール
## どのようなものを作成することがゴールか
- 複数の都市を保存できる
- 複数の都市の天気一覧で見ることができる
- モダンで使いやすいUI/UX

## 何を達成すればゴールできるか
- [ ] 複数の都市を保持できる
- [ ] お天気情報APIから情報を取得する
- [ ] UI/UXが良い感じか
```