# temporal-kind

Temporal Server を kind (Kubernetes in Docker) クラスター上に Argo CD でデプロイするサンプルプロジェクト。

## アーキテクチャ

- **Argo CD**: PostgreSQL / Temporal Server の Helm chart を Application CR として管理・デプロイ
- **PostgreSQL**: Bitnami Helm chart を Argo CD 経由でデプロイ (Temporal のバックエンド)
- **Temporal Server**: temporalio Helm chart を Argo CD 経由でデプロイ
- **Temporal Web UI**: ブラウザから Workflow 実行履歴を確認
- **Go サンプル**: 最小限の Hello World Workflow で動作確認

## 前提条件

- [Docker](https://www.docker.com/)
- [kind](https://kind.sigs.k8s.io/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Go](https://go.dev/) 1.22+

## ディレクトリ構成

```
├── k8s/
│   ├── kind-config.yaml              # kind クラスター設定
│   ├── argocd/
│   │   ├── postgresql.yaml           # Argo CD Application: Bitnami PostgreSQL Helm
│   │   └── temporal.yaml             # Argo CD Application: temporalio Helm
│   └── temporal/
│       └── namespace-setup-job.yaml  # Temporal default namespace 作成 Job
└── temporal/                         # Go サンプルプログラム
    ├── workflow.go                   # Workflow + Activity 定義
    ├── worker/main.go               # Worker
    └── starter/main.go              # Workflow 実行
```

## クイックスタート

```bash
# 1. kind クラスター作成
make cluster-create

# 2. 全コンポーネントデプロイ (Argo CD → PostgreSQL → Temporal Server → namespace 作成)
make deploy-all

# 3. ポートフォワード (別ターミナル)
make port-forward-temporal

# 4. Worker 起動 (別ターミナル)
make run-worker

# 5. Workflow 実行
make run-starter
# => Workflow result: Hello, Temporal!
```

## Argo CD UI

```bash
make port-forward-argocd
make argocd-password
```

https://localhost:8443 で Argo CD UI にアクセスできます。ユーザー名は `admin`、パスワードは `make argocd-password` で取得できます。

## Temporal Web UI

```bash
make port-forward-ui
```

http://localhost:8080 で Temporal Web UI にアクセスできます。

## クリーンアップ

```bash
make teardown
```
