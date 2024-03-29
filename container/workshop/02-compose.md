## 演習2日目: Docker Compose を使ってみる

### Docker Compose とは？
Docker Compose は、その名の通り Docker コンテナを組み合わせ、組み立ててシステムを作るためのソフトウェアです。  

### Docker Compose でできること

docker run だと、スクリプトで管理するのが大変です。  
Docker Compose なら、`docker-compose.yaml` というファイルであるべき姿を管理できます。  
また、Rails と Rails が利用する DB を両方上げるなど、複数のコンテナを起動してそれぞれを簡単に連携できるように設定ができます。  

### 演習2.1: DB を利用するアプリケーションを Docker Compose で実行する

みんな大好き Wordpress を Docker Compose を利用して起動してみましょう。  
Wordpress には、本体と DB が必要です。  
本体は[公式](https://hub.docker.com/_/wordpress/)の `wordpress` イメージを、DB も[公式](https://hub.docker.com/_/mysql/)の `mysql` イメージを使ってみましょう。  

上記イメージのページにはほぼ答えそのものが載っているので、演習2.1のみ参考にしていいページは[docker-compose.yaml の書き方  ](https://docs.docker.jp/compose/compose-file.html) だけとします。  
また、イメージは次のtagの物を利用してください。

* `wordpress:php7.4`
* `mysql:5.7`

wordpressは80番port、mysqlは3306番ポートでlistenしています。  
`wordpress`イメージと`mysql`イメージでは次の環境変数が利用できます。

**wordpress**

| 環境変数 | 説明 |
|:-|:-|
| `WORDPRESS_DB_HOST` | 接続先DBホスト名 |
| `WORDPRESS_DB_USER` | DB接続ユーザー |
| `WORDPRESS_DB_PASSWORD` | DB接続パスワード |
| `WORDPRESS_DB_NAME` | 接続先DB名 |

**mysql**

| 環境変数 | 説明 |
|:-|:-|
| `MYSQL_ROOT_PASSWORD` | `root`ユーザーのパスワード |
| `MYSQL_DATABASE` | 起動時に作成するDB名 |
| `MYSQL_USER` | 起動時に作成するユーザー名 |
| `MYSQL_PASSWORD` | `MYSQL_USER`のパスワード |
| `MYSQL_ALLOW_EMPTY_PASSWORD` | `yes`を指定すると`root`にパスワードなしでアクセス可 |
| `MYSQL_RANDOM_ROOT_PASSWORD` | `yes`を指定すると起動時に`root`のパスワードをランダムに生成してstdoutへ出力 |

### 演習2.2 docker-compose.yamlを修正してDocker Compose で実行する

[Gitea](https://gitea.io/ja-jp/)はセルフホスト型Gitサービスです。MySQLやPostgresなどのDBをバックエンドとして利用できます。

次の docker-compose.yaml はバックエンドとしてPostgresを利用しGiteaを動かそうとしていますが、間違ったところがあり正常に動作しません。
ブラウザで`http://localhost:3000`にアクセスして、Giteaのインストールが正常に行えるように修正してください。

```yaml
version: 3.7
services:
  gitea:
    image: gitea/gitea:latest
    environment:
      - DB_TYPE=postgres
      - DB_HOST=db:5432
      - DB_NAME=gitea
      - DB_USER=gitea
      - DB_PASSWD=gitea
    volumes:
      - git_data:/data
    ports:
      - 3000:3000
  postgres:
    image: postgres:alpine
    environment:
      - POSTGRESQL_USER=gitea
      - POSTGRESQL_PASSWORD=gitea
      - POSTGRESQL_DB=gitea
    volumes:
      - db_data:/var/lib/postgresql/data
    expose:
      - 5432
volumes:
  postgres_data:
  git_data:
```

Giteaのイメージの使い方について必要であればこちらのドキュメントを参考にすると良いでしょう。
[Installation with Docker - Docs](https://docs.gitea.io/en-us/install-with-docker/)

### 演習2.3: 謎のアプリケーションを Docker Compose で実行する
謎の Web アプリケーションを構築し、リクエストを受けられる状態まで組み立ててみましょう。
[`takutakahashi/blackbox-webapp`](https://hub.docker.com/r/takutakahashi/blackbox-webapp) というイメージを用意したので、あとは頑張ってください！  
`/` のパスでリクエストしたらとある文字列が返ってきますので、それを僕にスレで教えてください。  

### 追加演習1: Wordpress を SSL 対応する
プロダクションでは、web アプリケーションは基本的に https で配信をします。  
Wordpress も SSL で配信してみましょう。  
「オレオレ証明書」と呼ばれる、自己署名証明書を使いましょう。  

### 追加演習2: 謎のアプリケーションにはいろいろ謎がある
謎のアプリケーションには、いろいろな仕掛けが施されています。  
計4つ仕掛けてあるので、全て探してみましょう。  
それぞれ答えには動物の種類が文字列で入っています。さあなんでしょう？  
バイナリ解析すると全部分かるのでそれは禁止です。  

### 追加演習3: 自分で DB にアクセスするアプリを作って動かしてみる
自分で DB に接続するアプリを作成し、動かしてみてください。  
研修で Rails チュートリアルをやっているのであれば、そちらのアプリを動かすのでかまいません。  

### 追加演習4: Docker Compose っぽいことを行うスクリプトを作成する
Docker Compose っぽいことを行うスクリプトを作成し、実行してシステムが動くことを確認してください。  
以下の条件を満たしてください。  

- `docker-compose up -d` 相当の動作をする (バックグラウンドで起動)
- 動作させるアプリケーションは、演習2.2 で利用した謎のアプリケーション
- 謎のアプリケーションで依存しているシステムに利用するホスト名は、`host1` と `host2` の２つ
- takutaka が手元で実行して実行できる状態にする
- `--net host` は利用しない

### 追加課題5: docker-compose のカスタムネットワークを利用する

https://docs.docker.jp/compose/networking.html

こちらのカスタムネットワークを利用して、謎のアプリケーションのネットワークを分けてみてください。  
謎のアプリケーションのスタックを2つ起動し、お互いのスタックが通信できない状態で動作させてください。  

### 追加課題6: docker-compose のカスタムネットワークを実装する

カスタムネットワークを追加課題4のように Docker Compose を利用しないで実装してください。    
