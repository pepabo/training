# 第 17 章　JavaScript 非同期処理とネットワーク通信

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

JavaScript によるネットワーク通信を実装する場合も、同じようにコールバック関数による後続処理の実装が求められることがあります。
例えば、古くから利用されているブラウザ組み込みの処理 [XMLHttpRequest](https://developer.mozilla.org/ja/docs/Web/API/XMLHttpRequest/Synchronous_and_Asynchronous_Requests) では、後続処理は `xhr.onload` に書きます。

しかし、コールバック関数を要求する処理を複数行う場合（例えばある Web API のレスポンスを使って他の Web API にアクセスしたい場合）など、コールバック関数の中にコールバック関数が入ることになってインデントの回数も多くなり、大変見にくいコードとなってしまいます。
関数を変数に代入して引数に渡せばインデントは深くならないですが、今度は上下にコードの塊が散らかってしまうので、これもまた見にくい状況になってしまいます。

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

この複雑化に対応できるのが [Promise](https://developer.mozilla.org/ja/docs/Web/JavaScript/Guide/Using_promises) です。
Promise を使うとコールバックを連ねていたのが `.then` のチェーンに落とし込むことができます（それ以外にも複数の非同期処理の終了を待ち合わせる API もあります）。

## 練習問題 1

1. `setTimeout()` を Promise でラップしたものを返す `sleep(ms)` 関数を作り、 `sleep(ms)` を呼び、`.then` でチェーンさせた内部でもう一度 `sleep(ms)` を `return` し、 `.then` が2個チェーンした形になるようにしてください。
2. `fs.writeFile()` は `node:fs/promises` からimportすると、Promise版の `writeFile()` を利用できます。試してみましょう。

## async/await

コールバック地獄は Promise で解決することができますが、 Promise に直したところでいくつかの問題が別で発生します。
一つは、`.then` のチェーンで行数がだらだらと伸びてしまうこと。
もう一つは、例外発生時の `.catch` のフローが一見してわかりづらく、処理を目で追いづらいということです。
処理を直感的に追えないというのは変数の代入にも言えて、例えば以下のようなコードが Promise では発生してしまいます。

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

これを直列的に書けるようにしたのが **async function** です。さっきのコードが以下のようなコードになります。
大事なのは宣言時に `async` をつけることと、 Promise を返却する関数を実行する際には `await` を頭につけることで待ち合わせして結果を取り出せるということです。
async function を実行した結果は暗黙のうちに Promise として返却されるので、 async function 実行の結果を `.then` で引き継ぐこともできます。

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

## fetch

ブラウザ標準の組み込みAPIに [Fetch](https://developer.mozilla.org/ja/docs/Web/API/Fetch_API/Using_Fetch) があります。
`fetch()` はPromiseを返却するので、これまで説明した `.then()` によるメソッドチェーンや `async` / `await` 構文を利用することができます。
