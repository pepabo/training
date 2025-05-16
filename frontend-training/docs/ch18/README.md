# 第 18 章　React 開発ことはじめ

それでは、いよいよ React を使っての開発に入ります。

最近の React は、React を直接組み込むよりもフレームワークを使った開発が主流です。公式ドキュメントでは Next.js, React Router, Expo などのフレームワークが紹介されています。

https://ja.react.dev/learn/creating-a-react-app

## React や Vue の何がかつてのフロントエンドライブラリと比べて優れていたか

練習問題 1-3 のような画面をかつて JavaScript で実装しようとした場合、フォームから取得した値をデータとして持つのではなく、単純に画面に表示する要素として追記していただけでした。しかし、これだと 1-2 のような絞込み機能を実装することがとても難しくなります。仮に `species` を表示要素のどこかに書き込んでおいて、繰り返しでその値をチェックして絞込みの対象でなければ消去するという処理を実装するにしても、「猫絞込み→犬絞込みへの切り替え」「猫絞込み→全件表示」のような 2 アクションの操作に対応しようと思うと、「消去したデータを保管する変数」のようなものを設けなければいけません。今回は単純なアプリケーションですが、これが複雑化して例えばゲームのような画面になった時には、数え切れないほどのパターンの状態と変更が発生するようになります。

このような複雑な UI を実装する手段として、データの状態をどこかに保持しておいて（React の `useState` で作られる変数や、それこそ Vue の `data` のように）、変更があったら UI の方も書き換えるというアプローチが取られるようになりました（ React / Vue の動きに似ていないですか？）。しかし、これを手で実装していた時はいつ UI を書き換えるかも手動で設定しなければならず、その結果として変更の反映がされてないというバグが発生することがありました。それならば、毎秒（ゲームなら毎フレーム）データから UI を生成できればよかったのですが、 JavaScript で UI を書き換えるという処理はとても遅く、毎秒全部書き換えでは非常にストレスフルなアプリケーションが出来上がってしまいます。

先ほど「全部書き換え」と書いたのが要点で、 React や Vue はそこを HTML の構造を模したオブジェクトを作成しデータ変更の前後でどこが書き換わるかを検知し、 UI のその部分のみを置き換えているのです。 JavaScript オブジェクトの比較は UI の直接変更より十分に短い時間でできるので、データが置き換わった時に毎回自動でチェックするようなフックを仕掛けられるようになります。この HTML の構造を模したオブジェクトを **Virtual DOM** と言います。

この思想が優れている点は「宣言的に UI を書ける」ということ、さらに『データから自動で UI を生成できる、そしてその UI は書き換えの回数が最小化される』という考え方が、 Web フロントエンドに限らず UI を備えたスマートフォンのアプリケーションやデスクトップアプリケーションにも応用できるということです。これが [ReactNative](https://reactnative.dev/) や [Flutter](https://flutter.dev) といったものです。

ここで、「宣言的に UI を書ける」という点をもう少し深掘りしてみましょう。宣言的UIプログラミングとは、「何をするか」ではなく「どうあるべきか」を記述するアプローチです。これは単なる実装テクニックではなく、UIを考える根本的な思考法の転換を意味します。

従来の命令型プログラミングでは、「ボタンやテキストを変数に束縛し、クリックイベントを登録し...」というように一連の手順を指示していました。例えば、フォームのバリデーションを命令的に実装すると

```js
// 命令的アプローチ
const emailInput = document.getElementById('email');
const submitButton = document.getElementById('submit');

emailInput.addEventListener('input', function() {
  const email = emailInput.value;
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  
  if (emailRegex.test(email)) {
    submitButton.disabled = false;
  } else {
    submitButton.disabled = true;
  }
});

// フォーム送信時の処理
const form = document.getElementById('contact-form');
form.addEventListener('submit', function(event) {
  event.preventDefault();
  
  // 送信中の状態に変更
  emailInput.disabled = true;
  submitButton.disabled = true;
  submitButton.textContent = '送信中...';
  submitButton.classList.add('loading');
  
  // 送信処理（仮想的な非同期処理）
  setTimeout(function() {
    // 成功時の処理
    form.innerHTML = '<div class="success">送信完了しました！</div>';
  }, 2000);
});
```

- DOM要素を直接操作する
- 状態変化のたびに影響を受ける要素を手動で更新する
- イベント処理が複雑になり、管理すべき状態が増え、バグが発生しやすくなる

対して宣言的アプローチでは、「この状態のときはこのように見える」という関係性を定義します。UIの状態とその表示方法を明確に分離することで、命令的アプローチにおける問題を解決します。

```js
// 宣言的アプローチ
function Form() {
  const [email, setEmail] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);
  const isValid = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  
  async function handleSubmit(e) {
    e.preventDefault();
    setIsSubmitting(true);
    
    // 送信処理（仮想的な非同期処理）
    await new Promise(resolve => setTimeout(resolve, 2000));
    setIsSuccess(true);
  }
  
  if (isSuccess) {
    return <div className="success">送信完了しました！</div>;
  }
  
  return (
    <form onSubmit={handleSubmit}>
      <input
        value={email}
        onChange={e => setEmail(e.target.value)}
        disabled={isSubmitting}
      />
      <button 
        type="submit"
        disabled={!isValid || isSubmitting}
        className={isSubmitting ? 'loading' : ''}
      >
        {isSubmitting ? '送信中...' : '送信'}
      </button>
    </form>
  );
}
```

- UIの各状態を明示的に定義する
- 状態に応じたUIの表示を宣言的に記述する
- 状態の変更が自動的にUIへと反映される
- DOMの直接操作を抽象化し、「何を表示するか」にフォーカスする

宣言的アプローチによって、DOM操作という手段を分離し、開発者は「何を表示するか」という本質的な問題に集中できるようになりました。この思想転換により、フロントエンド開発はコードの記述方法から考え方そのものが変わり、複雑なUIを扱う際の認知的負荷が大幅に軽減されました。

開発者は「このボタンをどう変更するか」ではなく「このデータ状態ではUIはどうあるべきか」という、より抽象度の高い設計に注力できるようになったのです。また、ユーザーのインタラクションに対しても、「何が起こるべきか」という宣言的なアプローチに移行できました。

この根本的な考え方の変化こそが、ReactやVueが今なおフロントエンド開発のデファクトスタンダードとして広く採用され続ける最大の理由です。

宣言的UIと命令的UIの比較については、Reactの公式ドキュメントにも詳しく記載されているので、こちらも併せて参照してください。[How declarative UI compares to imperative ](https://react.dev/learn/reacting-to-input-with-state#how-declarative-ui-compares-to-imperative)

この項以外にもReactの公式ドキュメントでは、基本的な思想からReactの使い方まで分かりやすく網羅的にカバーされています。一読しておくと、より理解を深めることができるでしょう。

また、ここまでで宣言的アプローチを実現する方法として、「React や Vue」というまとめ方をしてきましたが、以降の資料ではReactを使った研修内容になっています。

両者の比較については様々な観点からの考え方がありますが、ここでは詳細については触れず、単に社内における採用実績をベースとしてReactを選定しています。

## 練習問題 2

1. 先ほど作ったペットリストと登録フォームの全体を1つのコンポーネントに切り出してください（すでにそのように実装していればこの問題は飛ばしてください）。
1. これまで作ったペットリストをより小さなコンポーネントの集まりに分割する場合、どこで分割するのが良さそうか考えをまとめてください。

## 次回予告

ついに React を使ってフロントエンドを開発できるようになりました。しかし、そこに流し込みたいデータを Micropost アプリから読み取ることができません。次のチャプターでは Micropost アプリに Web API としての機能を追加し、 React 部分からデータを取得できるようにします。またその前段階として、 Ruby とは違う JavaScript 非同期コールバックモデルとその問題点、その問題点を解消した Promise や async/await について学びます。

{% endraw %}
