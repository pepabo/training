# 付録 1　フロントエンドのコーディング規約

{% raw %}

## JavaScript

### 全般

[ESLint](https://eslint.org) の [recommended](https://eslint.org/docs/rules/) を押さえておけばいいです。直感的にものすごく変なコードを書かない限りエラーになることはないです。

15 章後半からは基本的に何らかのトランスパイラをかけてブラウザ上で実行される JavaScript を生成するので、あまりコーディング規約に対して神経質にならなくて良いです。とはいえ野放図にコードを書くと保守やレビューで問題があるので、一定のルールを作っておきます。

### Better Practice

* 使えるところは極力 `const` を使う。オブジェクトの内容変更も `const` でできる。やむをえない場合のみ `let` を使う。 `var` は使わない。
* 使えるところは極力 arrow function を使う。 `function` は極力使わない。 `async` も arrow function にできる。
* インデントに使うタブ・スペースの数を統一する。

### Project Specific

このフロントエンド研修プロジェクトでは以下のルールでコードを書いてください。

* 変数名は lowerCamelCase とする。 `const` も別に定数を意味しないので `VARIABLE_NAME` のような表記は使わない。
* インデントはスペース 2 つとする。
* 文字列は string interpolation が必要な時のみ backtick を使う。 string interpolation がない場合シングルクオーテーションとする。
* オブジェクトのキーはキーにハイフンが入る時以外クオートしない。
* セミコロンを省略しない。
* arrow function の変数が 1 つの時もカッコを省略しない。
* オブジェクト、配列の最後の要素のあとにコンマを入れるか入れないかは自由とする。

## Vue

### 全般

[eslint-plugin-vue](https://eslint.vuejs.org) の recommended と [Style Guide](https://vuejs.org/v2/style-guide) をまず守りましょう。案外見落としがちなのが以下です。

* `data` を関数にする。
* SFC のファイル名は UpperCamelCase にする、 `component` としても UpperCamelCase で import する。
* SFC template と DOM template には微妙な違い [1](https://vuejs.org/v2/style-guide/#Component-name-casing-in-templates-strongly-recommended) [2](https://vuejs.org/v2/style-guide/#Self-closing-components-strongly-recommended) がある。
* `v-if` と `v-for` を同じ要素に対して使わない。

### Project Specific

* template への変数展開は前後にスペースを入れる。 `{{ someVariable }}`

{% endraw %}
