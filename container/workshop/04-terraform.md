## 演習4: Terraform を使ってインフラを構築しよう

Terraform を使って、インフラをコードを使って構築してみましょう。  
リソース ID 等は、適宜用意された環境のものに置き換えて利用ください。  

## 4.0 準備をしよう

Terraform を使う準備をしましょう。  

### Terraform をインストール

terraform のバージョン管理である tfenv を利用してインストールします。  
```
brew install tfenv
tfenv install 1.0.1
tfenv use 1.0.1
```

### クレデンシャルの設定

terraform 用のリポジトリを作成して、そちらで作業をしましょう。  


以下の、backend.tf を作成します。  

```
terraform {
  backend "local" {}
}

```

ホームディレクトリの `.aws/credentials` に、以下の gist の内容を追記しましょう。  
ファイルやフォルダがなければ作成しましょう。 

```
ナイショ
```

`provider.tf` を作成しましょう。

```
provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = ".aws/credentials"
  profile                 = "training"
}
```

`terraform init` を実行して、以下の表示が出れば OK です。
```
% terraform init

Initializing the backend...

Successfully configured the backend "local"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Checking for available provider plugins on https://releases.hashicorp.com...
- Downloading plugin for provider "aws" (2.69.0)...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.aws: version = "~> 2.69"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

## 4.1 インスタンスを操作してみる

## 4.1.1 インスタンスを起動してみる

コンソールポチーで起動していたインスタンスをコードから起動してみましょう。  
以下のコードを、`instance.tf` という名前で保存します。

```
resource "aws_instance" "test" {
  ami           = "ami-0ac80df6eff0e70b5"
  instance_type = "t2.micro"
  subnet_id     = "subnet-0f82350780ed8c71b"

  vpc_security_group_ids = ["sg-03cffe5ebe505e62f"]

  tags = {
    Name = "training-[自分の名前]"
  }
}
```

そして、 `terraform plan` を実行します。  
実行したらどうなるかが返ってくるため、良さそうなら `terraform apply` します。  
すると、インスタンスが作成されます！


## 4.1.2 インスタンスを削除する

インスタンスを削除する際は、`terraform destroy` を実行すると削除されます。  
あるいは、instance.tf の中の記述をコメントアウトして、`apply` すると削除されます。  
`terraform destroy` を実行して、インスタンスを削除してみましょう。  

## 4.2 変数に切り出してみる

terraform では、variables という形で変数を切り出すことができます。  
ami を変数化して、再利用できるコードにしてみましょう。  
切り出したら、Amazon Linux 2 の ami ID である `ami-0f84e2a3635d2fac9` を変数に適用して plan, apply してみましょう。  

## 4.3 ストレージを作成してインスタンスに繋いでみる

`aws_ebs_volume` というリソースを利用して、  
インスタンスにストレージを追加することができます。  
また、リソースに `test` という名前を付けた場合、  
`aws_ebs_volume.test.id` といった形で情報を参照できます。  
以下のように、`aws_volume_attachment` リソースに  
volume の id とインスタンスの id を渡してあげると、  
インスタンスにストレージを追加することができます。  

```
resource "aws_volume_attachment" "test" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.test.id
  instance_id = aws_instance.test.id
}

```
上記の要領で、インスタンスにストレージを追加してみましょう。  

## 4.4 rds を import する

既存のリソースを取り込むことができます。  
rds を import してみましょう。  
また、import するだけだと、`apply` した際に設定が書き換わったり削除されてしまいます。  
`plan` しても設定が変わらないように、差分を埋めていきましょう。  

## 4.5 自分専用のネットワークを構築する

VPC、サブネット、ルートテーブル、セキュリティグループなどを構築して、  
自分専用のネットワークを作成しましょう。  
その中にインスタンスを起動して、
起動したインスタンスがインターネットと通信できるようにしてみましょう。  

## 4.6 システムの構成を検証する

awspec というツールを利用して、AWS の構成が想定のものかテストできます。  
以下のページを参考に、テストしてみましょう。  
https://dev.classmethod.jp/articles/use-awspec-to-test-aws-resrouces/

## 4.7 自動 plan, 自動 apply をしてみる

ペパボの GHE では、GitHub Actions を利用して CI/CD を構築することができます。  
PR を出したら `plan` を実行し、マージされたら `apply` が実行されるパイプラインを構築してみましょう。  
こちらを実行する際には、tfstate を local から s3 などの remote のものに切り替える必要があります。  
取り組む際に声をかけてください。  
