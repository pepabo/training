# 第 19 章　JavaScript 非同期処理とネットワーク通信

ところで話はいきなり JavaScript の言語仕様の話になりますが、 **JavaScript では function はオブジェクトです**。つまり関数を変数に代入したり引数として別の関数に渡したりすることができます。下記は実際に動くコードです。

```js
const add = (x, y) => {
  return x + y;
}
console.log(add(3, 2));  // => 5

// 関数を引数に取って 2 番目の引数として 2 を与える新しい関数を返す関数
const apply2 = (f) => {
  return (x) => {
    return f(x, 2);
  }
}
const add2 = apply2(add);  // 2 を足す関数になる
console.log(add2(3));  // => 5

// 引数として直接 function を書くこともできる
const sub2 = apply2((x, y) => {
  return x - y;
})
console.log(sub2(3));  // => 1
```

また、 JavaScript は Ruby と違い、I/O 処理などをする時は時間がかかるので原則として処理の終了を待ちません。例えば第 16 章の練習問題で出てきた文字列をファイルに書き出す `fs.writeFile()` は直後にコードを挿入しても、その時にファイルへの書き込みが終了していることを保証しません（終了を待ち合わせする `fs.writeFileSync()` というのもあります）。 JavaScript ではこのような場合直列でコードを書くのではなく、関数を引数に渡して後続の処理を書くことになります。これを**コールバック関数**と呼びます。

```js
const fs = require('fs');

// もし膨大なデータを書き込もうとした場合…
fs.writeFile('output.txt', 'foo', () => {
  console.log('このコールバック関数の中では確実に書き込みが完了しています');
});
console.log('このコードの時点では書き込みが終了していることは保証されません');
```

JavaScript によるネットワーク通信を実装する場合も、同じようにコールバック関数による後続処理の実装が求められます。ブラウザで最初から使えるのは [XMLHttpRequest](https://developer.mozilla.org/ja/docs/Web/API/XMLHttpRequest/Synchronous_and_Asynchronous_Requests) です。リンク先にどのようなコードを書くかは掲載されていますが、実際のコーディングで使うことはないので眺める程度で大丈夫です。この場合後続処理は `xhr.onload` で書きます。

しかし、コールバック関数を要求する処理を複数行う場合（例えばある Web API のレスポンスを使って他の Web API にアクセスしたい場合）など、コールバック関数の中にコールバック関数が入ることになってインデントの回数も多くなり、大変見にくいコードとなってしまいます。関数を変数に代入して引数に渡せばインデントは深くならないですが、今度は上下にコードの塊が散らかってしまうので、これもまた見にくい状況になってしまいます。

```js
someFunction(() => {
  someFunction(() => {
    someFunction(() => {
      someFunction(() => {
        someFunction(() => {
          // Hell!!!!
        });
      });
    });
  });
});
```

```js
const otherFunction = () => {};

// very
// long
// code

someFunction(otherFunction);
```

この複雑化に対応できるのが [Promise](https://developer.mozilla.org/ja/docs/Web/JavaScript/Guide/Using_promises) です。 Promise を使うとコールバックを連ねていたのが `.then` のチェーンに落とし込むことができます（それ以外にも複数の非同期処理の終了を待ち合わせる API もありますが、あまり使わないのでここではそういうこともあるよという認識で大丈夫です）。

## 練習問題 1

1. `setTimeout()` を Promise でラップしたものを返す `sleep(ms)` 関数を作り、 `sleep(ms)` を呼び、`.then` でチェーンさせた内部でさらにもう一度 `sleep(ms)` を呼び、 `.then` が2個チェーンした形になるようにしてください。
2. `fs.writeFile()` の第 3 引数は、 Error オブジェクトが引数として渡ってくるコールバック関数ですが、これを考慮に入れて、 Promise でラップしたものを返す `write(filename, data)` 関数を作ってください。

## async/await

コールバック地獄は Promise で解決することができますが、 Promise に直したところでいくつかの問題が別で発生します。一つは、`.then` のチェーンで行数がだらだらと伸びてしまうこと。もう一つは、例外発生時の `.catch` のフローが一見してわかりづらく、処理を目で追いづらいということです。処理を直感的に追えないというのは変数の代入にも言えて、例えば以下のようなコードが Promise では発生してしまいます。

```js
let aValue;  // then 複数箇所で変数を使いまわしたい場合ここで宣言せざるを得ない

someFunction()  // 結果つきで Promise を返す関数
  .then((res) => {
    aValue = res.aAttr;  // この値を使いまわしたい
    return otherFunction(aValue);  // Promise を返す
  })
  .then((res) => {
    return anotherFunction(aValue, res.bAttr);
  });
```

これを直列的に書けるようにしたのが **async function** です。さっきのコードが以下のようなコードになります。大事なのは宣言時に `async` をつけることと、 Promise を返却する関数を実行する際には `await` を頭につけることで待ち合わせして結果を取り出せるということです。 async function を実行した結果は暗黙のうちに Promise として返却されるので、 async function 実行の結果を `.then` で引き継ぐこともできます。

```js
// 頭に async をつけて宣言する
// const foo = async () => でも書ける
async function foo() {
  const aRes = await someFunction();
  const aValue = aRes.aAttr;  // let でなくてよくなる
  const bRes = await otherFunction(aValue);
  return await anotherFunction(aValue, bRes.bAttr);
}

// async function は Promise を返却する
// return した値も then に渡す関数で使える
foo().then((res) => console.log(res));
```

async/await を使うメリットとして、例外発生時の処理がわかりやすくできるというのもあります。 async/await では例外発生時は `.catch()` ではなく `try {} catch {}` を使うことができ、前述したとおり直列にコードを書くことができるので、例外が発生する部分だけを `try {} catch {}` で囲んで書くことができるようになります。以下のようなコードです。

```js
async function foo() {
  let aRes;
  try {
    aRes = await someFunction();  // 例えば、この関数が例外を送出しうるとして
  } catch(err) {
    console.log('エラー発生！！', err);
    aRes = { aAttr: '' };
  }
  const aValue = aRes.aAttr;
  const bRes = await otherFunction(aValue);  // 必要に応じてここも try にしたりする
  return await anotherFunction(aValue, bRes.bAttr);
}
```

## axios

ここまでなぜ長々と Promise, async/await について書いてきたかというと、モダンな web フロントエンド開発においては XMLHttpRequest をそのまま書くようなことはあまりなく、 XMLHttpRequest をラップして Promise を返却するようなラッパーライブラリを使うからです。 Vue では [axios/axios](https://github.com/axios/axios) を使うことが推奨されています。詳細は GitHub の当該ページに譲りますが、リクエストの結果が Promise で返却されるのが見て取れると思います。

## 練習問題 2

1. NPM でインストールした axios を使って Reddit 上にある Vue の記事一覧 `https://www.reddit.com/r/vue.json` を取得し、結果を `console.log` で表示してください。
2. 上の問題で取得した Vue の記事一覧を取得するコードを、 async/await を使って書き直してください。
