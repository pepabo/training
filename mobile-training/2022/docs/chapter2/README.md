# 2章 Dart言語

## JavaScriptとの比較

元々 JavaScript の代替を意識して作られていたという経緯もあり、 Dart 言語は JavaScript と大差ない文法で記述できます。
1点、大きな違いがあるとすれば、それは Dart がコンパイル言語であるということです。

## Language Tour

Dart 公式の Web サイトに [Language Tour](https://dart.dev/guides/language/language-tour) というページがあります。このページでは、 Dart でコードを書く上で必要最低限の文法が網羅されています。Flutter 初学者の方は、ひとまずこのページを眺めて知らない書き方を見つけたら読み込んでおくと、この先の研修でつまづくポイントが減るでしょう。

Language Tourは分量があり、全てを読むとかなりの時間がかかってしまうでしょう。まずは以下に示す項目を読み、それ以外の項目は章を進める途中でリファレンスとして用いることを推奨します。

必須
- A basic Dart program
- Important concepts
- Variables
- Functions

## コードを書く

Language Tour を読んだら、実際にコードを書いてみましょう。
書いたコードは [DartPad](https://dartpad.dev/?null_safety=true) で実行するのが最も簡単でしょう。
dartがインストールされていれば、ローカルでの実行も可能です。

```bash
$ dart run target.dart
```

### 1. Class and Factory constructors

## 課題1
以下の要件で`User`というクラスを作ってみましょう。

- `String name`, `int age` を持つ
- 全てのフィールドを`final`で保持する
- `User.fromJson(Map<String, dynamic> json)`という[Factory constructors](https://dart.dev/guides/language/language-tour#factory-constructors)を持つ
- 以下のコードを実行すると、`John` `24`が出力される

```dart
final Map<String, dynamic> json = {
  "name": "John",
  "age": 24
};

final user = User.fromJson(json);
print(user.name);
print(user.age);
```

### 2. Generics

Dartを含む様々な言語では、Genericsという機能があります。
これは、クラスやメソッドの中で使用する型を、利用側が決定できるものです。
これまで使ってきた`Map<String, dynamic>`もGenericsの機能を用いています。

`Map`は2種類の型を利用側が指定できます、一つ目がMapのkeyとなる型、二つ目がMapのvalueとなる型です。
例えば、keyを`String`, valueを`int`にしたければ、以下のように宣言します。

```dart
Map<String, int> map;
map = {
  "first": 1,
  "second": 2
};
```

## 課題2

以下の要件を満たすコードを書いてみましょう。

- Generic Type `int` を持つ `List` を`final`で作成し、`1, 3, 5, 7, 9`を要素として保持する
- コードを実行すると、`合計結果: 25`が出力される

- Generic Type `String` を持つ `List` を`final`で作成し、`p,e,p,a,b,o`を要素として保持する
- コードを実行すると、`結合結果: pepabo`が出力される

<details>
<summary>ヒント</summary>
`List<T>`には`forEach`メソッドが実装されています。

[ドキュメント](https://api.dart.dev/stable/2.13.4/dart-core/Iterable/forEach.html)
</details>

### 3. Null Safety

Dart は v2.12 から Null 安全な言語になりました。
そのため、 Null が入りうるパラメータは、`?`というキーワードを使って宣言する必要があります。

```dart
// safeVariableは宣言した時点では何も代入されておらず、参照先は null になってしまう
// Dart 2.12 以降ではこのコードはコンパイルエラーとなる
String safeVariable;

// 代わりに?キーワードを使用して、参照先が null となりうることを明示する
String? nullableVariable;

// nullableな値にアクセスする場合には、nullでないことを確認する(null check)必要がある
if (nullableVariable != null) {
  print(nullableVariable);
}
```

## 課題3
以下のコードを実行して、次のような出力がされるコードを書いてください。

```dart
void main() {
  printName("taro");
  printName("taro", lastName: "yamada");
  printName("taro", lastName: "");
  printName("taro", lastName: null);
}
```

期待される出力
```
Fisrt Name: taro
Full Name: taro yamada
Fisrt Name: taro
Fisrt Name: taro
```

<details>
<summary>ヒント</summary>
`String`クラスには`.isNotEmpty`というプロパティがあります。

https://api.dart.dev/stable/2.13.4/dart-core/String/isNotEmpty.html

メソッドの引数の一部をOptionalにするには、`{}`を使います。

https://dart.dev/guides/language/language-tour#parameters
</details>
