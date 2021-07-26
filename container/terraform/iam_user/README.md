# AWSワークショップ構築

演習3から5で利用するIAM userをTerraformで管理します。

IAM user は us-east-1 region の EC2/RDS/ELB のフルアクセス権限だけを持ち、コンソールへのアクセスは許可されません。

コンソールへのアクセスはシングルサインオンによって行うようにします。
OneLogin で IAM user と同等のポリシーを適用した IAM role が連携されるように設定を行ってください。

## 事前準備

### GPG

secret access key を暗号化して管理するために `gpg` でキーペアを作成し、公開鍵を `terrafot,tfvars`の`pgp_public_key`に設定してください。

```console
$ docker run -it --rm -u $(id -u):$(id -g) -e HOME -v "$HOME":"$HOME" -v "$(pwd)":"$(pwd)" -w "$(pwd)" dockerizedtools/gpg:2.2.20 --gen-key

$ gpg --list-keys
/Users/xxxxxx/.gnupg/pubring.kbx
----------------------------------
pub   rsa2048 2021-07-24 [SC] [expires: 2023-07-24]
      475FEB09857A3F9295968562416F39C3D60DEC29
uid           [ultimate] training
sub   rsa2048 2021-07-24 [E] [expires: 2023-07-24]

$ gpg --export -a "training" | tail -n+2 | head -n-2 | tr -d '\n'
```

```
# terraform.tfvars
gpg_public_key = "mQENBGD7efk..."
```

参考: [Jonathan Bergknoff: Terraforming AWS IAM users](https://jonathan.bergknoff.com/journal/terraforming-aws-iam-users/)


### ユーザー

`terraform.tfvars`の`users`に研修を受ける人数分の名前のリストを記述します。

```
# terraform.tfvars
users = [
  "test1",
  "test2"
]
```

## 実行

適切なAWS profileに切り替えて `terraform apply` してください。

## IAM user の credential 参照

terraform 実行後、次のように確認できます。

`SECRET_ACCESS_KEY`はPGPで暗号化されているため、次のように複合します。

```
$ terraform output -json iam_users | jq .

{
  "test1": {
    "ACCESS_KEY": "AKIAY5ESHVN3JLSF6VRV",
    "SECRET_ACCESS_KEY": "-----BEGIN PGP MESSAGE-----\nVersion: Keybase OpenPGP v2.0.76\nComment: https://keybase.io/crypto\n\nwcBMA9A4m1LPQ2HvAQgAuzPvFRqxw4Qlk/OQ8rmCcYFcn3ojh+Zt9iQ0Q6OsPRIqzE4hjeSulwpAbL/mnJv64tZtAImfnoEdQANxEByHOleEl5tPHKKAujuB/H6EM2VqUS202V37921yHLlxfjVnWPEwCbfu8L0CGEIMRROq8jdPKtM91VK6LXaAOi21YR9/5av/lkZOSW1QWcytNKEZZ0osdlbLyO51HkcSLaWqnABSCLJ7nsouxh9eMuj89k05OKPOM6UWgQCvV54u4oEFsvfUuVnLuLSMAyKMD89qhputOifVZwyLZWyKvN7MhFwvEL80UrqPVx4B13SQXnFiPoL4b0BzYh6x72bGWiaOudLgAeS0ZXa00Bm2zNmBmOD22cc54dN44PngyOFTwuC84iXXsxXgcuXtS7i/8ChQgMJA7ov1IlZ9PE78FiUPymsRXILSjzzlH+An46YS5YlQuQa44J3k45HDYBeiO9rw6HMZx6qQpuKTLATh4UDfAA==\n-----END PGP MESSAGE-----\n"
  },
  "test2": {
    "ACCESS_KEY": "AKIAY5ESHVN3K7ZJTOC6",
    "SECRET_ACCESS_KEY": "-----BEGIN PGP MESSAGE-----\nVersion: Keybase OpenPGP v2.0.76\nComment: https://keybase.io/crypto\n\nwcBMA9A4m1LPQ2HvAQgAQUSbMaanJjXqfrL/+iav6FD1dBBLMYy+vnF0joC85FTcZtgB57aBmRD54n/ZN7sYkWme/jeDgHts2eR2hM7BqdMTZzuCBuVEnIzxr4yZFVKJGjSzorlXu/hqj3GoiRzjz5KM0/xUPlsEgL3iV5zS3E58s9WjNG7zjYgruXS1N5YSztyK2wQsWC3TUCYZWRg3+jLz7yqdIAPy8xuo6R8F6QQHtZPYoZ/xq3tabT9hgzE3GcsPrKG9Se9/BbzWv7iVA9b06LLqJkKI4xXu/0D3oJYciM1d0KTWdULnQIPA7HIlMGOf/5/CtWz9ADehqNFfwFKff3ESrJrFFHNL11pzzNLgAeR2LZTK1ukv2WkPPWjxC5m64dsj4LfgzeFWVuB94gbIlnfgk+VTEzl1y0ZCLkAnEKfSsb9opw/QAl3v/84fZDdp0m4FMOBE4yFPF4VVs/+T4Nvkj4cOSKM/bgPsYOV5ioii8+KXuSWp4UC1AA==\n-----END PGP MESSAGE-----\n"
  }
}

$ terraform output -json iam_users | jq -r '.test1.SECRET_ACCESS_KEY' | gpg -d
gpg: rsa2048鍵, ID D0389B52CF4361EF, 日付2021-07-24に暗号化されました
      "training"
XXXXXXXXXXXXXXXXXXXXXXXX
```
