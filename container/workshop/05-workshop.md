## 総合演習

今までの内容を総合した、総合演習を実施します！  
目的は、「未知の技術領域に先輩や同僚の力を借りてアプローチできるようになること」です。  
途中で課題が終了しても問題ありません。  
「○○を実現しようとして、今ここ」というのをアウトプット1で示してください。  

## アウトプットの指定

それぞれで共通するアウトプットを以下に示します。  
数字が若いものから作成してください。  
また、以下のアウトプットと成果物をまとめるリポジトリを作成してください。

### 1. 自分で設定したゴールと進捗状況をまとめた文章

以下の問に端的に答えられる文章を用意してください。  

- どういったものを作成することがゴールか？
- ゴールまでの進捗はどのくらいか？
- ゴールへの道を邪魔するものはなにか？
- 何を達成すればゴールできるか？

### 2. システムの特徴を140字でまとめたアブストラクト

作成したシステムを、140字程度でまとめた文章を添えてください。  
読んだ人に良さが伝わる文章だとよいです。   

### 3. 構成図

何と何が繋がるのか？などの構成図を作成してください。  
フォーマットはおまかせします。  

### 4. 構築ドキュメント

他の人が同様の環境を作成するための構築ドキュメントを作成してください。  

## 課題内容

Kubernetes を利用して以下の要件を満たしたシステムを構築してください。  

1. 互いに通信するコンポーネントを2つ以上組み合わせる
1. データを保存するコンポーネントを1つ以上構築する
1. コンテナにログインする運用は禁止
1. manifestはGitOpsでデプロイする
1. 外部からHTTPSでアクセス可能であること

EKS (Elastic Kubernetes Service) のクラスタを用意しておきました。  
個々人のnamespaceを用意してあり、その中であれば利用は自由です。  

aws コマンドが利用できれば、以下で認証情報を取得できます。  

```
aws eks --profile training --region us-east-1 update-kubeconfig --name training
```

クラスタには共有で利用できる次のコンポーネントが用意されています。必要に応じて利用してください。

* ArgoCD
* external-dns
* ingress-nginx
* cert-manager
* sealed-secrets

## 参考

Kubernetes を一から触るには、以下のサイトが参考になります。  
- [Introduction to Kubernetes](https://cybozu.github.io/introduction-to-kubernetes/introduction-to-kubernetes.html)
- [Learn Kubernetes using Interactive Browser-Based Labs | Katacoda](https://www.katacoda.com/courses/kubernetes)

ArgoCDについては公式の [Getting Started](https://argoproj.github.io/argo-cd/getting_started/) か次のサイトが参考になります。

[ArgoCDに入門する - TECHSTEP](https://techstep.hatenablog.com/entry/2020/09/22/113404)