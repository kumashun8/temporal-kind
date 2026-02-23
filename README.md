# temporal-kind

Temporal Server を kind (Kubernetes in Docker) クラスター上にデプロイするサンプルプロジェクト。

## アーキテクチャ

- **Temporal Server**: Helm chart (`helm template`) から生成した manifest を `kubectl apply` でデプロイ
- **PostgreSQL**: Temporal のバックエンドとして kind 上にデプロイ（素の k8s manifest）
- **Temporal Web UI**: ブラウザから Workflow 実行履歴を確認
- **Go サンプル**: 最小限の Hello World Workflow で動作確認

## 前提条件

- [Docker](https://www.docker.com/)
- [kind](https://kind.sigs.k8s.io/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/) (manifest 再生成時のみ)
- [Go](https://go.dev/) 1.22+

## ディレクトリ構成

```
├── k8s/
│   ├── kind-config.yaml              # kind クラスター設定
│   ├── namespace.yaml                # temporal namespace
│   ├── postgres/                     # PostgreSQL manifest
│   └── temporal/
│       ├── values-postgresql.yaml    # Helm values (manifest 生成用)
│       ├── namespace-setup-job.yaml  # Temporal default namespace 作成 Job
│       └── generated/               # helm template で生成された manifest
└── temporal/                         # Go サンプルプログラム
    ├── workflow.go                   # Workflow + Activity 定義
    ├── worker/main.go               # Worker
    └── starter/main.go              # Workflow 実行
```

## クイックスタート

```bash
# 1. kind クラスター作成
make cluster-create

# 2. 全コンポーネントデプロイ (PostgreSQL → スキーマ初期化 → Temporal Server → namespace 作成)
make deploy-all

# 3. ポートフォワード (別ターミナル)
make port-forward-temporal

# 4. Worker 起動 (別ターミナル)
make run-worker

# 5. Workflow 実行
make run-starter
# => Workflow result: Hello, Temporal!
```

## Web UI

```bash
make port-forward-ui
```

http://localhost:8080 で Temporal Web UI にアクセスできます。

## Temporal manifest の再生成

Temporal のバージョンを変更する場合や `values-postgresql.yaml` を編集した場合:

```bash
make generate-temporal-manifests
```

## クリーンアップ

```bash
make teardown
```
