# 第 18 章　Vue 開発ことはじめ

{% raw %}

それでは、いよいよ Vue を使っての開発に入ります。 NPM を使って `vue` パッケージをインストールしてください。 `app/javascript/packs/index.js` と `app/views/layouts/application.html.erb` を編集して、 Vue を組み込んでみましょう。

```js:app/javascript/packs/index.js
import Vue from 'vue/dist/vue';

document.addEventListener('DOMContentLoaded', () => {
  new Vue({
    el: '#app',
    data() {
      return {
        name: 'Taro'
      };
    }
  });
});
```

```erb:app/views/layouts/application.html.erb
<% # 略 %>
<div id="app">
  <p>Hello, {{ name }} !</p>
</div>
```

[Vue のドキュメント](https://jp.vuejs.org/v2/guide/)は大変よくできているので、なるべく一次情報としてこれを見るようにしましょう。 web 検索をして出てくるブログ記事などには現行バージョンであるバージョン 2 系だけではなく、 1 系や 0.9 系も混在しているので、そのような情報は公式ドキュメントで確実な裏付けを取ってから実装すると良いでしょう。

それでは、実際にページをロードして、画面に Hello, Taro! が表示されることを確認してください。このように、 Vue クラスのコンストラクタに渡す設定オブジェクトのうち `data` メソッドが return するオブジェクトが、テンプレートの中で使用できるようになっています。

`data` として文字列だけではなく、数値や真偽値、配列やオブジェクトを扱うこともできます。つまり以下のようなコードも動作します。テンプレート中では他の型も文字列に変換されて表示されます。

```js:app/javascripts/packs/index.js
// 略

  new Vue({
    el: '#app',
    data() {
      return {
        name: 'Taro',
        numberItem: 1,
        booleanItem: true,
        arrayItems: ['item', 'another item'],
        objectItem: { aKey: 'object inner item' }
      };
    }
  });

// 後略
```

```erb:app/views/layouts/application.html.erb
<% # 略 %>
<div id="app">
  <p>Hello, {{ name }} !</p>

  <% # 足し算もできる %>
  <p>1 + 1 = {{ nuberItem + 1 }}</p>

  <% # 真偽値は v-if で扱える、もちろん v-if には式も使える %>
  <p v-if="booleanItem">This is visible.</p>
  <p v-if="arrayItems.length > 0">This is visible, too.</p>

  <% # 配列は v-for で繰り返しする %>
  <div>
    <p v-for="item in arrayItems" v-bind:key="item">{{ item }}</p>
  </div>

  <% # オブジェクトに対しては JavaScript のようにアクセスする %>
  <p>{{ objectItem.aKey }}</p>
</div>
```

## イベントハンドリング

まずは Vue を導入して各種データを表示するところまで学びました。しかしこれだけでは静的なページとは何も変わらず、フロントエンド開発を行うメリットがありません。そこでユーザのアクションによってページが書き換わる、インタラクティブな要素を導入してみましょう。

```js:app/javascripts/packs/index.js
// 略

  new Vue({
    el: '#app',
    data() {
      return {
        visible: false
      };
    },
    methods: {
      toggleVisibility() {
        this.visible = !this.visible;
      }
    }
  });

// 後略
```

```erb:app/views/layouts/application.html.erb
<% # 略 %>
<div id="app">
  <p v-if="visible">Can you see this?</p>
  <button v-on:click="toggleVisibility">toggle</button>
</div>
```

書き換えてページを表示するとボタンがあり、ボタンを押すことでメッセージの表示・非表示が切り替わるようになっています。このようにユーザ入力に反応するためには `v-on` ディレクティブを使用します。今回はボタンクリックに反応するので、 `v-on:click` を使用しています。 `v-on` ディレクティブの対象としては `methods` に定義されたメソッド名が指定できますし、今回の例であれば `visible = !visible` のように実際の処理を記述することもできます（コード例では省略していますが、念のため試してみてください）。 `data` で定義されたデータは JavaScript コード中では `this.someValue =` のような形で、テンプレート中では直接の形で代入できるようになっています。また、このデータの変化は特に表示側に伝えるようなコードがなくても、自動的に表示へと反映されるようになっています。

## 練習問題 1

1. Parcel の環境を Rails Tutorial とは別に用意して、 Vue で以下の `data` の `pets` を表形式で表示するコードを書いてください。
2. Vue の公式ドキュメントを調べつつ、表に犬のみを表示するボタン、表に猫のみを表示するボタン、全てのペットを表示するボタンを実装してください（ヒント： `computed` を使うと綺麗にコードを書けます）。
3. （高度）ドキュメントを調べつつ、犬か猫を選べる新しいペットを登録するフォームを作ってください。新しいペットを登録すると表に追加して表示されるようにしてください（ヒント：フォーム要素には `v-bind:model` を使います）。

```js:index.js
document.addEventListener('DOMContentLoaded', () => {
  new Vue({
    el: '#app',
    data() {
      return {
        pets: [
          { name: 'Pochi', species: 'dog' },
          { name: 'Tama', species: 'cat' },
          { name: 'Mike', species: 'cat' },
          { name: 'Hachi', species: 'dog' }
        ]
      };
    }
  });
});
```

## Vue の何がかつてのフロントエンドライブラリと比べて優れていたか

練習問題 1-3 のような画面をかつて JavaScript で実装しようとした場合、フォームから取得した値をデータとして持つのではなく、単純に画面に表示する要素として追記していただけでした。しかし、これだと 1-2 のような絞込み機能を実装することがとても難しくなります。仮に `species` を表示要素のどこかに書き込んでおいて、繰り返しでその値をチェックして絞込みの対象でなければ消去するという処理を実装するにしても、「猫絞込み→犬絞込みへの切り替え」「猫絞込み→全件表示」のような 2 アクションの操作に対応しようと思うと、「消去したデータを保管する変数」のようなものを設けなければいけません。今回は単純なアプリケーションですが、これが複雑化して例えばゲームのような画面になった時には、数え切れないほどのパターンの状態と変更が発生するようになります。

このような複雑な UI を実装する手段として、データの状態をどこかに保持しておいて（それこそ Vue の `data` のように）、変更があったら UI の方も書き換えるというアプローチが取られるようになりました（ Vue の動きに似ていないですか？）。しかし、これを手で実装していた時はいつ UI を書き換えるかも手動で設定しなければならず、その結果として変更の反映がされてないというバグが発生することがありました。それならば、毎秒（ゲームなら毎フレーム）データから UI を生成できればよかったのですが、 JavaScript で UI を書き換えるという処理はとても遅く、毎秒全部書き換えでは非常にストレスフルなアプリケーションが出来上がってしまいます。

先ほど「全部書き換え」と書いたのが要点で、 Vue はそこを HTML の構造を模したオブジェクトを作成しデータ変更の前後でどこが書き換わるかを検知し、 UI のその部分のみを置き換えているのです。 JavaScript オブジェクトの比較は UI の直接変更より十分に短い時間でできるので、データが置き換わった時に毎回自動でチェックするようなフックを仕掛けられるようになります。この HTML の構造を模したオブジェクトを **Virtual DOM** と言います。よくモダンフロントエンドライブラリとして比較される [React](https://ja.reactjs.org) も同じ思想で実装されています（歴史的には React の方が先です）。

この思想が優れている点は「データから自動で UI を生成できること、そしてその UI は書き換えの回数が最小化される」という考え方は、 Web フロントエンドに限らず UI を備えたスマートフォンのアプリケーションやデスクトップアプリケーションにも応用できるということです。これが [ReactNative](https://facebook.github.io/react-native/) や [Flutter](https://flutter.dev) といったものです。

## 単一ファイルコンポーネント

これまでは実際に HTML のコードを書いて Vue の開発を行ってきました。このままでも大変便利ですが、実際の HTML は Rails が erb を出力しない限り、結果を確認することはできません。テンプレートの部分まで JavaScript に含まないとテンプレート自体の動的な切り替えができないので、 SPA (Single Page Application) の実現は困難になってしまいます。また、一つの HTML に Vue テンプレートを長々と書くと可読性が下がり、メンテナンスが困難な状況が発生してしまいます。

この問題に対応するために、 Vue には[単一ファイルコンポーネント](https://jp.vuejs.org/v2/guide/single-file-components.html) (SFC) という仕組みが用意されています。テンプレートと実行コードを .vue ファイルにまとめて小さく分割することにより、可読性を上げることができます。 .vue ファイルをトランスパイルする機能は Parcel に最初から用意されているので、特に何かを用意する必要はありません。

実際に Hello, Taro! を SFC に分離してみましょう。実現するコードは以下のようになります。

```vue:Hello.vue
<template>
  <p>Hello, {{ name }} !</p>
</template>

<script>
export default {
  data() {
    return {
      name: 'Taro'
    };
  }
}
</script>
```

```js:index.js
import Vue from 'vue/dist/vue';
import Hello from './Hello.vue';

document.addEventListener('DOMContentLoaded', () => {
  new Vue({
    el: '#app',
    render: (createElement) => {
      return createElement(Hello)
    }
  });
});
```

これで `app/views/layouts/application.html.erb` の `<p>` タグ部分は不要になります。実際に SFC が動いているところを確認してみましょう。

SFC には他にもメリットがあり、パーツを小さくすることやテンプレートを部分部分に切り離すことにより、コンポーネント単位でのユニットテストが可能になります。テストについては[付録 2](../chap02/) に記述してありますので、余力があったらチャレンジしてください。

さらにコンポーネントから別のコンポーネントを呼び出すこともできます。その時にコンポーネントの属性を `props` として渡すこともできます。例えば、上記では Taro に挨拶をすることしかできませんでしたが、 `props` を使うことで親コンポーネントから名前を指定して挨拶することもできるようになります。

```vue:Hello.vue
<template>
  <p>Hello, {{ name }} !</p>
</template>

<script>
export default {
  props: {
    name: String  // props として名前と型を指定する
  }
};
</script>
```

```vue:Parent.vue
<template>
  <div>
    <Hello name="Taro"></Hello>
    <Hello name="Hanako"></Hello>
  </div>
</template>

<script>
import Hello from './Hello.vue'

export default {
  components: {
    Hello
  }
};
</script>
```

（注意！： Parent.vue にある template の `<div>` を省略すると動かなくなります。これは Vue SFC template の最上位要素は単一である必要があるためです。最上位要素を `<Hello>` として複数並べることはできません。）

さらに、子のコンポーネントに渡す `props` として変数を指定することもできます。その場合は `v-bind:` として変数名を指定します。例えば、上記の Parent.vue は繰り返しと変数指定で以下のように書くこともできます。

```vue:Parent.vue
<template>
  <div>
    <Hello v-for="name in people" v-bind:name="name" v-bind:key="name"></Hello>
  </div>
</template>

<script>
import Hello from './Hello.vue'

export default {
  components: {
    Hello
  },
  data() {
    return {
      people: ['Taro', 'Hanako']
    };
  }
};
</script>
```

## 練習問題 2

1. 先ほど作ったペットリストと登録フォームの全体を SFC にしてください。
2. ペットリストの表の一行を表示する部分を SFC に切り出してください。
3. （高度）これまで作ったペットリストを SFC の集まりに分割する場合、どこで分割するのが良さそうか考えをまとめてください。

## 次回予告

ついに Vue を使ってフロントエンドを開発できるようになりました。しかし、そこに流し込みたいデータを Micropost アプリから読み取ることができません。次のチャプターでは Micropost アプリに Web API としての機能を追加し、 Vue 部分からデータを取得できるようにします。またその前段階として、 Ruby とは違う JavaScript 非同期コールバックモデルとその問題点、その問題点を解消した Promise や async/await について学びます。

{% endraw %}
