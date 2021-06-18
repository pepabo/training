import { useState } from "react";

interface Item {
  id: number;
  name: string;
  price: number;
}

interface Props {
  name: string;
  answer: number;
  items: Item[];
}

const Showcase = (props: Props) => {
  const [isVisible, setIsVisible] = useState(true);
  const nameLengthThreshold = 8;

  const handleClickVisibilityToggleButton = () => {
    setIsVisible(!isVisible);
  };

  return (
    <>
      {/* 中括弧の中で props の値が使えます: */}
      <p>Hi, I'm {props.name}!</p>

      {/* props の値だけでなく、中括弧の中ではあらゆる JavaScript の式が使えます: */}
      <p>
        The answer is {props.answer}, so the doubled answer is{" "}
        {props.answer * 2}.
      </p>

      {/* 論理積演算子 && を使って、条件によって要素の表示と非表示を切り替えたり: */}
      {isVisible && <p>This is Visible.</p>}
      <button onClick={handleClickVisibilityToggleButton}>
        Toggle visibility
      </button>

      {/* 三項演算子を使って、条件によって表示する要素を出し分けたりできます: */}
      {props.name.length >= nameLengthThreshold ? (
        <p>name.length is equal or longer than {nameLengthThreshold}.</p>
      ) : (
        <p>name.length is less than {nameLengthThreshold}.</p>
      )}

      {/* 配列に対して map を使えば複数の要素を描画できます: */}
      <ul>
        {props.items.map((item) => (
          <li key={item.id}>
            {item.name} is {item.price} Yen.
          </li>
        ))}
      </ul>
    </>
  );
};

const App = () => {
  const name = "Pepayama Botaro";
  const answer = 42;
  const items = [
    {
      id: 1,
      name: "T-shirt",
      price: 100,
    },
    {
      id: 2,
      name: "Hoodie",
      price: 300,
    },
  ];

  return <Showcase name={name} answer={answer} items={items}></Showcase>;
};

export default App;
