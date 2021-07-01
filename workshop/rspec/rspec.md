## RSpec基礎講座

- 2021年6月30日(水)
- GMOペパボ株式会社
- 五十嵐邦明 / igaiga
  - https://twitter.com/igaiga555

## この資料は何か

- RailsでよくつかわれるテストフレームワークRSpecの基礎を学ぶ資料です
- テストやTDDについて詳しくはt-wadaさんの講義が予定されてますのでおたのしみに！
- 自分で読んで手を動かしていく形式です
  - この資料に書かれているコードのうち、動かせそうなものは手元で書いて動かしてみてください
  - マイペースでやってください
- 質問があれば受け付けますのでお声かけください
  - 「ここよくわからん」くらいの雑な質問でもOKです
- 手を動かす課題のほかに、最後に練習問題も用意しています
  - 講義時間内に提出していただければ確認します
- サンプルコードリポジトリ: https://github.com/igaiga/rails6132_ruby301_rspec
  - 説明につかっているコードがだいたい入っていると思います

## 前提知識

- Railsチュートリアルを一通りやっていること
- RailsでCRUDな操作を理解できること

## おおまかな流れ

- 環境構築
  - RSpecコードを書くRailsアプリを作成
- Model spec
- RSpecの基礎文法
- FactoryBotの使い方
- System spec
- モック、スタブの使い方
- Request spec
- 練習問題

## 環境

- 以下よりも新しいバージョンが出ていたら、新バージョンでOKです

- Rails6.1系最新
    - Rails 6.1.4
- Ruby3.0系最新
    - Ruby 3.0.1
- rspec-rails 最新
    - rspec-rails 5.0.1
    - rspec-core 3.10.1

- Railsチュートリアル第4版アプリ(Rails5.1)
    - 参考: フロントエンド研修リポジトリ
        - https://github.com/pepabo/frontend-training/tree/master/app_start
    - 練習問題でこちら利用しますが、本編では不要です

## minitestとRSpecの違い

- RSpec
  - シェアが多く、事実上の標準
  - 書いたことがあるエンジニアが多い
  - 道具が豊富な反面、過度に道具をつかった構造化も書けてしまう
  - minitestにRSpecのガワをかぶせているので、中のコードはやや追いづらい
- minitest
  - Railsのデフォルト
  - 複数DB機能など、一早く新機能が導入される
  - シンプルで、道具はアドオンとして追加する方針
  - シェアが少なく、書いたことがないエンジニアも多い

## 参考資料

- RSpecリファレンスページ https://relishapp.com/rspec/rspec-rails/docs
- Railsガイド 「Railsテスティングガイド」 https://railsguides.jp/testing.html
- Capybara: https://rubydoc.info/github/teamcapybara/capybara/master/Capybara/Node/Matchers

## RSpec環境構築

- RSpecコードを書くRailsアプリを作成します
    - 参考用に作成済みサンプルコードを置いておきます
    - https://github.com/igaiga/rails6132_ruby301_rspec

- $ rails new app_name --skip-test
    - `--skip-test` オプションはRails標準であるminitest関連ファイルを作成しないオプションです
    - 既にminitest込みでrails new済みのアプリへRSpecを追加するときは、RSpecを入れたあとでtestフォルダを削除すれば問題ないです
- Gemfileを編集してrspec-rails gem追加
    - https://github.com/rspec/rspec-rails

```Gemfile
group :development, :test do
  ...
  gem 'rspec-rails'
  ...
end
```

- $ bundle install
- $ bin/rails generate rspec:install
    - 設定ファイルなどを作成します
- 動作確認としては以下を実行すればOKです
  - $ bundle exec rspec spec/
  - `0 examples, 0 failures` といった表示がでれば問題ないです

## bin/rspec コマンドでspringをつかう

- この作業はやらなくても問題はないのですが、やるとbin/rspecコマンドが作成され、起動にspringが使われて速くなります

Gemfile
```Gemfile
group :development do
  ...
  gem 'spring-commands-rspec'
  ...
end
```

- Gemfileを編集してrspec-rails gem追加
    - 追加環境はdevelopmentだけで良いようです
    - インストール時だけでなく、使っている間はずっと入れておく必要があるようです

- $ bundle install
- $ bundle exec spring binstub rspec

- 動作確認としては以下を実行すればOKです
  - $ bin/rspec spec/
  - `0 examples, 0 failures` といった表示がでれば問題ないです

- springは前回の実行時の情報をキャッシュします
- もしも動作にコード変更が反映されていないときは、以下のコマンドでspringを停止して再実行してください
  - $ bin/spring stop
  - spring起動コマンドはなく、実行したら勝手に起動します

## factory_bot をつかう準備

- factory_botはテスト用モデルデータを作成する道具です
    - 詳しくは後で説明します
- Gemfileを編集してfactory_bot_rails gem追加
    - https://github.com/thoughtbot/factory_bot_rails

```Gemfile
group :development, :test do
  ...
  gem 'factory_bot_rails'
  ...
end
```

- $ bundle install

## テスト対象コード作成

- 今回はscaffoldをつかってテスト対象のコードを作成することにします
    - booksのCRUDをするアプリです
    - テスト対象コードをテストコードと対比してプロダクションコードと呼びます
- $ bin/rails g scaffold books title author
    - rspecやfactorybotのひな形もつくってくれます
- $ bin/rails db:migrate
- イメージをつかみたい人はrails sしていじってみてください

## Railsアプリでよく書かれるテスト

- Railsアプリでよくつかうテストは以下の3種類です
- Model spec: モデルのテスト
- System spec: ブラウザをつかったE2E(=アプリ全範囲)テスト
- Request spec: ブラウザをつかわないE2Eテスト
    - minitestではController test, Integration testに相当
- JSを動かしたいときはSystem spec、APIの場合はRequest specをつかうのがおすすめです
- ほか、ActiveJobやActionMailerなど、Railsの各部品用テストが用意されています
    - 詳細: https://railsguides.jp/testing.html
- Controller specやView specなどはE2Eテストで賄えるので、ほぼつかわれません
    - ややこしいですが、Controller specとController test(minitest)は別物です

## Model specを書く - RSpecを実行してみる

- それではテストを書いてみましょう
- scaffoldで生成されているspec/models/book_spec.rb(Bookモデルのspec)をエディタで開きます

spec/models/book_spec.rb

```spec/models/book_spec.rb
require 'rails_helper' # 設定ファイルrails_helper.rbを読み込むコードが全テストにあります

RSpec.describe Book, type: :model do # Bookモデルのテストコードをブロック内に書いていきます
  # ここにBookモデルのテストコードを書いていきます
  pending "add some examples to (or delete) #{__FILE__}"
end
```

- pendingはテスト実行を保留してコメントを表示するメソッドです
- まずはこのまま実行してみましょう
- $ bin/rspec spec/models/book_spec.rb
    - `1 example, 0 failures, 1 pending`
- このファイルを編集してテストを書いていきます

## RSpec実行方法一覧

- $ bin/rspec spec/
  - 全テスト実行
- $ bin/rspec spec/models/
    - 指定フォルダ以下の全テスト実行
- $ bin/rspec spec/models/book_spec.rb
    - ファイル指定実行
- $ bin/rspec spec/models/book_spec.rb:5
    - ファイル指定+行数指定実行
- 前提として、RAILES_ENV=test なDBは事前に準備が必要です
    - 最近のRailsでは便利機能が入って、development環境DBがあれば、test環境ではそのスキーマをコピーして自動生成します

## Model specを書く - NGになるテストを書く

- 次にNGになる(=失敗する)テストを書いてみます
    - 環境が正しく動作するかの確認にもなります
- 「falseを期待しているときに、trueになる」テストを書きます

spec/models/book_spec.rb

```spec/models/book_spec.rb
require 'rails_helper'
RSpec.describe Book, type: :model do
  it "trueであるとき、falseになること" do # itの後にNG時に表示される "説明文" を書く
    expect(true).to eq(false)
    # expect(テスト対象コード).to マッチャー(想定テスト結果)
    # マッチャーとはマッチ(一致)するかを判定する道具です
    # マッチャーはここでは==で一致判定するeqをつかっています
  end
end
```

- $ bin/rspec spec/models/book_spec.rb
    - `1 example, 1 failure`
    - failureが1で表示されれば想定通りです
- エラーメッセージの読み方を次に説明します

## NG時のメッセージの読み方

- 失敗しているかどうか、expected/got、失敗した行番号あたりが便利な情報です

```console
$ bin/rspec spec/models/book_spec.rb
(略)
Failures:
  1) 1) Book trueであるとき、falseになること #itの後ろに書いたテスト名
     Failure/Error: expect(true).to eq(false) # NGになったテストコード

       expected: false # テストコードが想定した結果
            got: true # 今回のexpect内の実行結果

     # ./spec/models/book_spec.rb:5:in `block (2 levels) in <main>' # 失敗した行番号
(略)
Finished in 0.0556 seconds (files took 0.1898 seconds to load)
1 example, 1 failure # 全テスト中の失敗したテスト数

Failed examples: # 失敗したテスト一覧
rspec ./spec/models/book_spec.rb:4
```

## Model specを書く - OKになるテストを書く

- 「trueを期待しているときに、trueになる」テストを書きます
    - 復習: itブロック内に expect(テスト対象コード).to マッチャー(想定テスト結果) を書く

spec/models/book_spec.rb

```spec/models/book_spec.rb
require 'rails_helper'
RSpec.describe Book, type: :model do
  it "trueであるとき、trueになること" do
    expect(true).to eq(true)
  end
end
```

- `1 example, 0 failures` OKのときの結果表示はあっさりです
- itを1行で書くときは次のように書きます
    - `it("trueであるとき、trueになること"){ expect(true).to eq(true) }`
    - Rubyでは1行で書くときはブロックを `{}`で書き、複数行では `do end` で書く慣習です

## Model specを書く - Bookモデルをつかう

- テスト対象にBookモデルをつかってみましょう
- Book.newが行われることを確認するテストを書きます
- 資料ではほかを省略してitだけ書きます

spec/models/book_spec.rb

```spec/models/book_spec.rb
it "Bookモデルをnewしたとき、nilではないこと" do
  expect(Book.new).not_to eq(nil)
end
```

- 否定のテストを書く expect().not_to をつかいました
- `eq(nil)` は `be_nil` というマッチャーもあります
- `expect(Book.new).not_to be_nil`
-  eqほか標準マッチャー一覧: https://rubydoc.info/gems/rspec-expectations/frames#built-in-matchers

## Model specを書く - Bookモデルのメソッドを呼び出す

- テスト対象をBookモデルのtitle_with_authorメソッドとして実装して、そのテストコードを書きます

app/models/book.rb

```app/models/book.rb
class Book < ApplicationRecord
  def title_with_author
    "#{title} - #{author}"
  end
end
```

spec/models/book_spec.rb

```spec/models/book_spec.rb
require 'rails_helper'
RSpec.describe Book, type: :model do
  describe "Book#title_with_author" do # describeメソッドをつかってメソッドごとに区切ると読みやすいです
    it "Book#title_with_authorを呼び出したとき、titleとauthorを結んだ文字列が返ること" do
      book = Book.new(title: "RubyBook", author: "matz")
      expect(book.title_with_author).to eq("RubyBook - matz")
    end
  end
end
```

## RSpecデバッグ方法

- デバッグしたいときは、itブロック中などでbinding.irbして止めてみてください

spec/models/book_spec.rb

```spec/models/book_spec.rb
require 'rails_helper'
RSpec.describe Book, type: :model do
  describe "Book#title_with_author" do
    it "Book#title_with_authorを呼び出したとき、titleとauthorを結んだ文字列が返ること" do
      book = Book.new(title: "RubyBook", author: "matz")
      binding.irb # ここで実行がとまってirbを利用できる
      expect(book.title_with_author).to eq("RubyBook - matz")
    end
  end
end
```

## describe: 区切る道具

- さきほどのテストコードの構成はdescribeをつかってメソッドごとに区切られました
    - インスタンスメソッドは#で表す `describe "Book#title_with_author" do`
    - クラスメソッドは.で表す `describe "Book.new" do`
- メソッドごとにdescribeブロックをつくって区切っていくのがお勧めです
    - 私の観測範囲でよくつかわれる区切り方の慣習です
- describeブロックは区切って構造をつくるための文法です
    - 書かなくても同じ動きをします
    - describeブロックを複数書いて入れ子にもできるので、区切りたいときに書いてください

spec/models/book_spec.rb

```spec/models/book_spec.rb
RSpec.describe Book, type: :model do
  describe "Book#title_with_author" do # describeメソッドをつかってメソッドごとに区切ると読みやすいです
    it "Book#title_with_authorを呼び出したとき、titleとauthorを結んだ文字列が返ること" do
      expect(book.title_with_author).to eq("RubyBook - matz")
...
```

## context: 状況で区切る道具

- contextブロックも構造をつくるための文法です
    - describeと同じ動作をしますが、プログラマが解釈する意味あいが違います
- `context "Book#titleが文字列のとき" do end` のように「〇〇のとき」を書く道具です
- contextはdescribeの中に複数書かれることが多いです
- describeとcontextを組み合わせて入れ子になることもあります

spec/models/book_spec.rb

```spec/models/book_spec.rb
describe "Book#title_with_author" do
  context "Book#titleが文字列のとき" do # 状況を説明する
    it "titleとauthorを結んだ文字列が返ること" do
      book = Book.new(title: "RubyBook", author: "matz")
      expect(book.title_with_author).to eq("RubyBook - matz")
    end
  end
  context "Book#titleがnilのとき" do # 状況を説明する
    it "空のtitleとauthorを結んだ文字列が返ること" do
      book = Book.new(author: "matz")
      expect(book.title_with_author).to eq(" - matz")
    end
  end
end
```

## RSpec テストコード構造の基本形

- RSpec テストコード構造の基本形をまとめると次のような構成になります
    - Model spec以外も同様です
    - describe, contextが入れ子構造になることもあります

```ruby
require 'rails_helper'
RSpec.describe Book, type: :model do
  describe "#.メソッド名" do
    context "○○なとき" do
      it "○○なこと" do end
      it "○○なこと" do end
    end
    context "○○なとき" do
      it "○○なこと" do end
    end
  end
  describe "#.メソッド名" do ... end
end
```

- Model specだけでなく、ほかのテストも同様です

## before: テストの前準備をする道具

- beforeメソッドをつかうと、itを実行する前に実行するブロックを書けます
    - beforeとitで変数を共通利用するときはインスタンス変数をつかいます

```ruby
context "Book#titleが文字列のとき" do
  before do
    @book = Book.new(title: "RubyBook", author: "matz")
  end
  it "titleとauthorを結んだ文字列が返ること" do
    expect(@book.title_with_author).to eq("RubyBook - matz")
  end
end
```

- beforeでテスト対象を準備して、itで期待する結果を書きます
- beforeをつかうかどうかもプロジェクトやケースに依存します
    - 私はつかうことが多いです
- あまりつかわないですがafterもあります
- 詳細: https://relishapp.com/rspec/rspec-core/docs/hooks/before-and-after-hooks

## subject: テスト対象を書く道具

- subjectメソッドというテスト対象を明示する道具もあります
- 次のコードでは `Book.new(title: "RubyBook", author: "matz")` がテスト対象であることを明示します
- itの外に書くことに気をつけてください
- subjectでテスト対象を、itで期待する結果を書きます

```ruby
context "Book#titleが文字列のとき" do
  subject { Book.new(title: "RubyBook", author: "matz") }
  it "titleとauthorを結んだ文字列が返ること" do
    expect(subject.title_with_author).to eq("RubyBook - matz")
  end
end
```

- つかうかどうかはプロジェクトに寄ると思います
    - 私はつかわない派です

## subjectに名前をつけることもできる

- subjectに名前をつけることもできます

```ruby
context "Book#titleがnilのとき" do
  subject(:book){ Book.new(author: "matz") } # subjectにbookと名前をつける
  it "空のtitleとauthorを結んだ文字列が返ること" do
    expect(book.title_with_author).to eq(" - matz") # bookはBook.new(author: "matz")を指す
  end
end
```

## let, let!: 変数を書く道具

- 変数を書く道具としてlet、let!が用意されています
- 文法は名前付きsubjectと同じです
- subjectは「テスト対象である」ことを含んでいましたがlet, let!にはその意味はありません
- つかうかどうかはプロジェクトに寄ると思います
    - 私はlet, let!をつかわないでbeforeをつかう派です
- letとlet!の違いは実行タイミングです
    - letは利用時に実行されます
    - let!は書かれた場所で実行されます
    - ちなみに、letをつかうな派も、let!をつかうな派もいます（どうしろと）

```ruby
context "Book#titleが文字列のとき" do
  let(:book){ Book.new(title: "RubyBook", author: "matz") }
  it "titleとauthorを結んだ文字列が返ること" do
    expect(book.title_with_author).to eq("RubyBook - matz")
  end
end
```

## System Spec

- ブラウザを動かしてRailsアプリ全体をテストするE2Eテスト
    - ブラウザを動かすのでJSを実行できます
    - ブラウザを動かすので低速になります
    - 明示してPOSTすることはできないので、POSTするためにはブラウザ操作でフォームをsubmitする必要があります
- spec/system フォルダ以下に置かれます
- Railsでつかえるマッチャー一覧: https://relishapp.com/rspec/rspec-rails/docs/matchers
- ブラウザを操作するためにCapybara gemがよく利用されます
- Capybaraをつかうとブラウザ用の操作メソッドとマッチャーが提供されます
- Capybaraドキュメント
  - マッチャー一覧: https://rubydoc.info/github/teamcapybara/capybara/master/Capybara/Node/Matchers
  - ブラウザ操作アクション: https://rubydoc.info/github/teamcapybara/capybara/master/Capybara/Node/Actions
  - ブラウザ操作ファインダー: https://rubydoc.info/github/teamcapybara/capybara/master/Capybara/Node/Finders

## System Spec 環境構築

Gemfile

```Gemfile
group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdriver'
end
```

spec/rails_helper.rb

```spec/rails_helper.rb
RSpec.configure do |config|
  ...
  config.before(:each, type: :system) do
    driven_by(:selenium_chrome_headless)
    # driven_by(:selenium_chrome)
    # driven_by(:rack_test)
  end
end
```

- $ bundle install

- headless Chromeをつかうとき    `driven_by(:selenium_chrome_headless)`
- headあり(ふつうの) Chromeをつかうとき  `driven_by(:selenium_chrome)`
- rack_test(高速だがJS実行などブラウザ機能は利用できない)をつかうとき `driven_by(:rack_test)`

- 以下のようなエラーが出るときはChromeDriverを手動インストールしてみてください
  - https://chromedriver.chromium.org/downloads
      - Downloadして /usr/local/bin/chromedriver として配置
  - またはhomebrewをつかって /usr/local/bin/chromedriver へインストールできます

```
Selenium::WebDriver::Error::SessionNotCreatedError:
            session not created: This version of ChromeDriver only supports Chrome version 87
            Current browser version is 90.0.4430.212 with binary path /Applications/Google Chrome.app/Contents/MacOS/Google Chrome
```

- 「headless Chrome」と「headあり Chrome」を切り替えるときに、環境変数を利用すると実行コマンドから切り替えられて便利です

spec/rails_helper.rb

```ruby
if ENV['WITHHEAD'].present?
  driven_by(:selenium_chrome)
else
  driven_by(:selenium_chrome_headless)
end
```

- headあり Chrome をつかうときはコマンドでWITHHEAD環境変数を定義する
  - $ WITHHEAD=t bin/rspec spec
- デフォルトではheadless Chromeがつかわれる
  - $ bin/rspec spec

## GETするSystem Specを書く

- spec/system/book_spec.rb を以下で作成します
    - spec/system フォルダがなければあわせて作成してください

```spec/system/book_spec.rb
require "rails_helper"

RSpec.describe "books", type: :system do
  it "GET /books" do
    visit "/books" # /booksへHTTPメソッドGETでアクセス
    expect(page).to have_text("Books") # 表示されたページに Books という文字があることを確認
  end
end
```

- bundle exec rspec spec/system/book_spec.rb
- have_text以外のマッチャーは以下のCapybaraのドキュメントで調べられます
  - https://rubydoc.info/github/teamcapybara/capybara/master/Capybara/Node/Matchers

## System specをNGにするとスクショが自動撮影される

- System specがNGになると自動でスクショ撮影されます
- デバッグに便利です

spec/system/book_spec.rb

```spec/system/book_spec.rb
require "rails_helper"

RSpec.describe "books", type: :system do
  it "GET /books" do
    visit "/books" # /booksへHTTPメソッドGETでアクセス
    expect(page).to have_text("foo") # 表示されたページに foo という文字があることを確認
  end
end
```

```console
$ bin/rspec spec/system/book_spec.rb
...
[Screenshot Image]: /Users/igarashi/work/rails6132_ruby301_rspec/tmp/screenshots/failures_r_spec_example_groups_books_enables_me_to_create_widgets_252.png
...
```

- 失敗しなくてもCapybaraの機能（たぶん）でスクショ撮れます
- `save_screenshot('ss.png')`
    - tmp/capybara/ss.png にスクショファイルが置かれます

## フォームからPOSTするSystemSpecを書く

- new画面でフォームを表示して、フォームの各欄に値を入力し、ボタンを押してPOSTリクエストするテストを書いてみましょう

spec/system/book_spec.rb

```spec/system/book_spec.rb
require "rails_helper"
RSpec.describe "books", type: :system do
  it "GET /books" do
    visit "/books"
    expect(page).to have_text("Books")
  end

  it "POST /books" do
    visit "/books/new"
    fill_in "Title", with: "RubyBook" # Title入力欄に"RubyBook"を入力する
    fill_in "Author", with: "matz"
    click_button "Create Book" # Create Bookボタンを押す

    expect(page).to have_text("Book was successfully created.")
    expect(page).to have_text("Title: RubyBook")
    expect(page).to have_text("Author: matz")
  end
end
```

## Request Spec

- ブラウザを動かさないRailsアプリ全体をテストするE2Eテスト
    - 高速
    - HTTPメソッドGET以外のテストを明示して書くことができる
    - ブラウザを動かさないのでJSは実行できない
    - 失敗時にスクショも撮れない
- spec/requests フォルダ以下に置かれます
- 主にAPI（JSONを返すパス）のテストで利用される

## テスト対象APIをつくる

- Request Specを書くためにテスト対象APIをつくります
    - GET /status したときにJSONで { status: "ok" } を返すパスをつくる
- $ bin/rails generate controller status
- spec/requests/status_request_spec.rb もあわせて生成される

config/routes.rb
```config/routes.rb
Rails.application.routes.draw do
  resources :books
  get 'status' => 'status#index', defaults: { format: 'json' }
end
```

app/controllers/status_controller.rb
```app/controllers/status_controller.rb
class StatusController < ApplicationController
  def index
  end
end
```

app/views/status/index.json.jbuilder
```
json.status "ok"
```

## Request specを書く

spec/requests/status_spec.rb
```spec/requests/status_spec.rb
require 'rails_helper'
RSpec.describe "Statuses", type: :request do
  it "GET /status" do
    get "/status"
    expect(response).to have_http_status(200)
    expect(response.content_type).to eq("application/json; charset=utf-8")
    expect(response.body).to include({ status: "ok" }.to_json)
  end
end
```

## factory_botをつかってテストデータを作成する

- factory_bot: テスト用モデルデータをつくる道具
    - Rails標準ではfixtureという道具が用意されていますが、factory_botがよく利用されます
    - 比較は後述します
- Railsアプリでは前述のfactory_bot_rails gemを利用します
- spec/factories フォルダに定義ファイル群が置かれます
- scaffoldしたときにspec/factories/books.rb にfactoryのひな形が作成されています
- 新規でfactory定義ファイルをつくる場合は以下のコマンドでファイル生成もできます
  - $ bin/rails g factory_bot:model book

## factory_botの定義ファイルを書く

spec/factories/books.rb
```spec/factories/books.rb
FactoryBot.define do
  factory :book do # :book はモデル名を全小文字にしてシンボルにしたもの
    title { "RubyBook" } # カラム title のデータとして "RubyBook" をつかう
    author { "matz" } # カラム author のデータとして "matz" をつかう
  end
end
```

- カラムにつづけてブロック `{}` を書き、ブロック中に代入したいデータを書きます
- この定義ファイルをつかって、次にデータをつくってみます

## factory_botの定義ファイルからモデルデータをつくる

- `FactoryBot.create(:book)` でDBにレコードを作成して、モデルオブジェクトを得られます
- rails consoleからも試行できます

```console
$ bin/rails c
irb> book = FactoryBot.create(:book)
irb> book
=> #<Book:0x... id: 1, title: "RubyBook", author: "matz", created_at: ..., updated_at: ...>
```

- DBにレコードを生成せずにモデルオブジェクトだけを作成したいときはbuildメソッドがつかえます
  - createメソッドの替わりにbuildメソッドをつかうとDB保存せずモデルオブジェクトをつくります
  - `FactoryBot.build(:book)`
- factory_botドキュメントも参考になります: https://github.com/thoughtbot/factory_bot/wiki

## 関連を持った定義ファイルを書く

- book(本)とvariation(バリエーション)の関連をつくる
  - バリエーションモデルでPDFや紙本といった種類を表現します

```console
$ bin/rails g model variation kind book:references
$ bin/rails db:migrate
```

app/models/book.rb
```ruby
class Book < ApplicationRecord
  ...
  has_many :variations
  ...
end
```

spec/factories/variations.rb

```ruby
FactoryBot.define do
  factory :variation do
    kind { "PDF" } # "PDF" に変更
    book { nil } # デフォルトのまま ※1
  end
end
```

- rails consoleから実行

```console
$ bin/rails c
irb> book = FactoryBot.create(:book)
irb> book
=> #<Book id: 3, title: "RubyBook", memo: "Good", created_at: "2020-07-07 04:29:51", updated_at: "2020-07-07 04:29:51">
irb> variation = FactoryBot.create(:variation, book: book)
irb> variation
=> #<Variation id: 1, kind: "PDF", book_id: 3, created_at: "2020-07-07 04:30:11", updated_at: "2020-07-07 04:30:11">
irb> variation.book
=> #<Book id: 3, title: "RubyBook", memo: "Good", created_at: "2020-07-07 04:29:51", updated_at: "2020-07-07 04:29:51">
```

- 関連はオブジェクト生成時に関連づけるのがお勧めです
- factory定義に関連を持たせることもできますが、メンテナンスがすごくすごく難しいです
  - 前述 spec/factories/variations.rb ※1 の行 `book { nil }` の部分
  - モデルが増えて関連が絡みあってきたときに書きづらくなっていくため
- または次に紹介するtraitを利用するのがお勧めです

## trait

- traitはfactory定義に複数パターンの生成方法を書くことができる機能です
  - https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md#traits
- factory定義に関連を書きたい場合にはtraitをつかうのがお勧めです
- Bookモデルに関連先variationsがあるサンプルコード

spec/factories/books.rb
```ruby
FactoryBot.define do
  # 前と同じ                
  factory :book do
    title { "RubyBook" }
    author { "matz" }
  end

  # 追加
  trait :with_variations do
    after(:create) do |book|
      book.variations.create!(kind: "paper book")
    end
    # （動作未確認）上のafterメソッドの代わりに、関連先のFactoryBotがあればこう書ける。
    # こちらだとFactoryBot.build時に関連先もbuildで作成できるかも。
    # FactoryBot.create_list(:variations, count, book: book)
  end
end
```

- 次の3つの書き方でfactoryを生成できます
- `FactoryBot.create(:book)` : traitなしのベース部分だけでfactoryを生成する
  - = 関連なしのオブジェクトをつくる
- `FactoryBot.create(:book, :with_variations)`: ベース部分に加えて `trait :with_variations` ブロックも実行する
  - = 関連先も一緒につくる
- `FactoryBot.create(:book, variations: [pdf_variation])`: variationsにpdf_variationを指定
  - = 関連先を指定する

```console
irb> book = FactoryBot.create(:book, :with_variations)
irb> book
=> <Book id: 6, title: "RubyBook", author: "matz", created_at: "2021-05-26 09:47:06.869090000 +0000", updated_at: "2021-05-26 09:47:06.869090000 +0000">
irb> book.variations
=> [#<Variation id: 3, kind: "paper book", book_id: 6, created_at: "2021-05-26 09:47:06.874868000 +0000", updated_at: "2021-05-26 09:47:06.874868000 +0000">]
```

## シーケンス

- レコード群を連番にしたいときにつかえる機能です
- パRails 7-3 にも詳しく書いてあります

```ruby
FactoryBot.define do
  factory :book do
    sequence { |i| "RubyBook vol.#{i}" }
  end
end
```

## fixture

- Rails標準のテストデータを登録するための道具
    - しかしあまりつかわれないです
    - factory_botの方が利用されています
- factory_botはcreateを書いたときにデータを作成します
- fixtureはテスト全体の開始前に全fixtureをデータを作成します
- 個々のテストで利用するテストデータを明示できると、個々のデータの結合度が下がります
    - それがfactory_botが好まれている大きな理由だと考えています

## factory_botでテストデータをつくってSystem specを書く

```ruby
require "rails_helper"

RSpec.describe "books", type: :system do
  it "enables me to create widgets" do
    book = FactoryBot.create(:book)
    visit "/books" # /booksへHTTPメソッドGETでアクセス
    expect(page).to have_text(book.title)
  end
end
```

## モック、スタブの使い方

- rspec-mocks
    - rspec-rails gemをつかうと依存gemとしてrspec-mocksも追加されて利用可能になる
        - https://github.com/rspec/rspec-rails/blob/main/rspec-rails.gemspec#L47-L57
    - よくつかわれているのでみんな文法を知っている
    - minitestでもつかえる
- rr, mochaなど機能や文法の違う別のライブラリもあります
    - https://relishapp.com/rspec/rspec-core/v/3-10/docs/mock-framework-integration

- rspec-mock以外のmockをつかうときはspec_helper.rbに設定を書きます
    - デフォルトはrspec-mockの設定 `config.mock_with :rspec` (=rspec-mock)になっていると思います

```ruby
config.mock_with :rspec do |mocks|
  ...
end
```

- 例題として、本には抽選で豪華なおまけがつくケースを考えます

app/models/book.rb


```ruby
class Book < ApplicationRecord
...
  def bonus
    return "著者サイン入りチェキ" if lucky?
    "しおり"
  end

  def lucky?
    [true, false].sample
  end
end
```

- テストコードをふつうに書くと、ランダムに成功したり失敗したりするようになってしまいます。

spec/models/book_spec.rb
```ruby
describe "Book#bonus" do
  context "lucky?がtrueのとき" do
    it "チェキが返ること" do
      book = Book.new
      expect(book.bonus).to eq("著者サイン入りチェキ")
    end
  end
end
```

- このようなときにモックをつかうことで問題を解決することができます
- テスト対象メソッドbonus内で呼び出している別のメソッドlucky?を操作するためにモックをつかいます

spec/models/book_spec.rb
```ruby
describe "Book#bonus" do
  context "lucky?がtrueのとき" do
    it "チェキが返ること" do
      book = Book.new
      allow(book).to receive(:lucky?).and_return(true)
      expect(book.bonus).to eq("著者サイン入りチェキ")
    end
  end
end
```

- allow(対象のオブジェクト).to receive(メソッド名のシンボル).and_return(戻り値)
- このように書くと、対象のオブジェクトのreceiveで指定したメソッド呼び出しだけ動作を変更することができます
- receiveで指定したメソッドは、本来のメソッドは呼び出されず、and_returnで指定した戻り値を返すだけになります
- and_return以外にもこんな道具が用意されています
  - https://relishapp.com/rspec/rspec-mocks/v/3-10/docs/configuring-responses
- allowメソッドのドキュメント
  - https://relishapp.com/rspec/rspec-mocks/v/3-10/docs/basics/allowing-messages

- receiveで指定したメソッドが呼び出されたかどうか確認することもできます

```ruby
describe "Book#bonus" do
  context "lucky?がtrueのとき" do
    it "チェキが返ること" do
      book = Book.new
      allow(book).to receive(:lucky?).and_return(true)
      expect(book).to receive(:lucky?) # 確認するメソッド呼び出しを実行する前に書く
      expect(book.bonus).to eq("著者サイン入りチェキ")
    end
  end
end
```

- ここでのbookのように、メソッド戻り値を改ざんされたオブジェクトを「モック」や「スタブ」と呼びます
- 呼び出されたか確認する機能があるとき、「モック」と呼ばれます
- メソッドの戻り値を改ざんする機能だけのときは、「スタブ」と呼ばれます
- とはいえ、実用上は「モック」「スタブ」のどちらで呼んでも通じるので問題ないです

- ここでのbookは既存のオブジェクトの一部の動作を変更することでテスト用のオブジェクトをつくりました
- doubleメソッドをつかうと、対象クラスのオブジェクトをつかわずにモックやスタブをつくれます
- 詳しく知りたい場合はドキュメントを読んでください
  - https://relishapp.com/rspec/rspec-mocks/v/3-10/docs/basics/test-doubles
  - https://relishapp.com/rspec/rspec-mocks/v/3-10/docs/verifying-doubles

- 参考資料
  - 基礎の説明
    - https://relishapp.com/rspec/rspec-mocks/v/3-10/docs
  - サンプルコードがいろいろ書かれている
    - https://relishapp.com/rspec/rspec-core/v/3-10/docs/mock-framework-integration/mock-with-rspec

##  例外を確認する技

- 例外が飛ぶことを確認するテストは次のように書きます
    - ほかのexpectの書き方と違ってブロックであることに注意

```ruby
expect { ... }.to raise_error
expect { ... }.to raise_error(ErrorClass)
expect { ... }.to raise_error(ErrorClass, "message")
```

app/models/book.rb

```ruby
class Book < ApplicationRecord
...
  def take_pictures
    raise RuntimeError.new("写真撮影はご遠慮ください")
  end
end
```

spec/models/book_spec.rb
```ruby
describe "Book#take_pictures" do
  context "呼び出すとき" do
    it "例外が投げられること" do
      book = Book.new
      expect{ book.take_pictures }.to raise_error(RuntimeError, "写真撮影はご遠慮ください")
    end
  end
end
```

## DRYにする技

- あるにはあります
- 気をつけて使わないと読みづらくなるしメンテナンスも大変なので要注意

- shared_example
    - 複数のitをまとめる技
    - 使いすぎるとテストコードが読みづらくなるので、あまりお勧めしません
    - https://relishapp.com/rspec/rspec-core/v/3-9/docs/example-groups/shared-examples

- shared_context
    - 複数のcontextをまとめる技
    - 使いすぎるとテストコードが読みづらくなるので、あまりお勧めしません
    - https://relishapp.com/rspec/rspec-core/v/3-9/docs/example-groups/shared-context

## 現在時刻を変更する技

Rails4.1で時刻変更するTimeHelpersが導入されました。
もしもtimecop gem がつかわれていたら、おそらく古い時代のコードなのでTimeHelpersメソッド群で置き換えるのが良さそうです。

リファレンス : http://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html

### TimeHelpersをつかうRSpecの設定

rails_helper.rb

```ruby
require 'active_support/testing/time_helpers' #追加
RSpec.configure do |config|
  config.include ActiveSupport::Testing::TimeHelpers #追加
end
```

### development環境で使うときの設定

includeできる環境で以下

```ruby
require 'active_support/testing/time_helpers'
include ActiveSupport::Testing::TimeHelpers
```

### travel_to

https://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html#method-i-travel_to

引数で指定した時刻で固定され、時間が進まなくなる。
戻すには travel_back メソッドをつかう。

ブロック付きで呼び出しすると、ブロックを抜けたタイミングで自動的にtravel_backされる。
ブロック中では時間が進まない。
travel_backメソッドの呼び出し忘れがないので、ブロック付きで呼び出せるならばその方が良い。

```ruby
it do
  travel_to(Time.current) do
    p Time.current #=> Mon, 11 Sep 2017 12:00:00 JST +09:00
    sleep 3
    p Time.current #=> Mon, 11 Sep 2017 12:00:00 JST +09:00
  end
end
```

### travel

https://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html#method-i-travel

travel_toと似ていて、違いは引数で指定した間隔だけ時刻を進めて固定されること。
戻すには同様に travel_back メソッドをつかう。
ブロック付きで呼び出しすると、ブロックを抜けたタイミングで自動的にtravel_backされるのも同様。

```ruby
Time.current # => Sat, 09 Nov 2013 15:34:49 EST -05:00
travel 1.day do # １日進める
  User.create.created_at # => Sun, 10 Nov 2013 15:34:49 EST -05:00
end
Time.current # => Sat, 09 Nov 2013 15:34:49 EST -05:00
```

### freeze_time

`travel_to Time.now` のエイリアス。ブロックも渡せる。戻すにはtravel_backメソッド、またはそのエイリアスのunfreeze_timeメソッド。

## 複数DB機能

- 複数のDBへアクセスできる機能がRails6.0で導入されました
- minitestでは自動で複数DBを構築し、並列実行してくれます
- RSpecだとまだ使えないけどそのうち入るかもしれません
- パーフェクトRails 3章 3-3 にも詳しく説明があります

## CI(Continuas Integration)

- 自動でRSpecなどのテストコードを実行するサービス
- PR作成時などをトリガーにテストを自動実行してくれます
- GitHub ActionsやCircleCIが有名です
- パーフェクトRails 9章 9-1 にも詳しく説明があります

## 練習問題

- RailsチュートリアルでつくったアプリでRSpecを動かせるようにしてください
    - minitestと共存もできます
- Model spec, Request spec, System specを1つずつ書いてみてください

## 参考資料

- RSpecリファレンスページ https://relishapp.com/rspec/rspec-rails/docs
- Railsガイド 「Railsテスティングガイド」 https://railsguides.jp/testing.html
- Capybara: https://rubydoc.info/github/teamcapybara/capybara/master/Capybara/Node/Matchers

## 参考資料(書籍)

- Everyday Rails - RSpecによるRailsテスト入門
    - https://leanpub.com/everydayrailsrspec-jp

- パーフェクトRails 増補改訂版(宣伝): https://gihyo.jp/book/2020/978-4-297-11462-6
    - ActionMailerとかRailsの各種機能の説明とテストコードもあわせて載ってる
    - ただしminitestをつかっています

- ソフトウェアテスト技法練習帳: https://gihyo.jp/book/2020/978-4-297-11061-1
    - テストパターンの作り方を学びたい人への補助資料

- willnetさん「Clean Test Code Revised 」
    - https://blog.willnet.in/entry/2019/03/27/092642
    - 「脳に負荷をかけない」テストの書き方

- willnetさん 「RSpec スタイルガイド」
    - https://github.com/willnet/rspec-style-guide
    - 前述のwillnetさんが「読みやすいRSpecを書く」指針をスタイルガイドとして実装したもの
