# 付録 1　フロントエンドのコーディング規約

[ESLint](https://eslint.org) の [recommended](https://eslint.org/docs/rules/) を押さえておきましょう。

世の中のベストプラクティスはプラグインとして公開されており、これを利用すれば概ねよいでしょう。
`create-react-router` や `create-vite` などのセットアップツールを使うと、ESLintおよび必要なプラグインをTUI上で選択してインストールすることもできます。

- TypeScript
  - [typescript-eslint](https://typescript-eslint.io/)
- React
  - [eslint-plugin-react](https://github.com/jsx-eslint/eslint-plugin-react)
- Vue.js
  - [eslint-plugin-vue](https://eslint.vuejs.org/)
  - [Vue.jsのスタイルガイド](https://ja.vuejs.org/style-guide/) も参考にできます

## Project Specific

このフロントエンド研修プロジェクトでは以下のルールでコードを書いてください。

* 変数名は lowerCamelCase とする。
* インデントはスペース 2 つとする。
* 文字列は string interpolation が必要な時のみ backtick を使う。 string interpolation がない場合シングルクオーテーションとする。
* オブジェクトのキーはキーにハイフンが入る時以外クオートしない。
* セミコロンを省略しない。
* arrow function の変数が 1 つの時もカッコを省略しない。
* オブジェクト、配列の最後の要素のあとにコンマを入れるか入れないかは自由とする。
