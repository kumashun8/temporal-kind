# temporal-kind

Temporal Serverをk8s clusterにデプロイするサンプルをkindで稼働させる。

## ディレクトリ構成

- k8s/kind-config.yaml: kindクラスタ設定
- k8s/argocd/: Argo CD Application CRの置き場（postgresql.yaml, temporal.yaml）
- k8s/temporal/: Temporal関連のk8sマニフェスト（namespace-setup-job.yaml）
- temporal/: TemporalでWorkflowを実行するサンプルプログラムの置き場（Go）

## アーキテクチャ構成

- Temporal ServerはArgo CDがHelm chartを直接レンダリングしてデプロイする
- PostgreSQLはBitnami Helm chartをArgo CD経由でデプロイする
- Argo CD ApplicationはHelmリポジトリを直接sourceとして参照する（Gitリポジトリは使わない）
- TemporalのbackendにはPostgreSQLを使う。PostgreSQLもkind上にデプロイする
- PrometheusとGrafanaはTemporal Helm chartのサブチャートとしてデプロイする
- Temporal実行のサンプルはGolangで実装する

## セットアップフロー

1. `make cluster-create` - kindクラスタを作成
2. `make deploy-all` - Argo CDインストール → PostgreSQL App → Temporal App → namespace作成を順にデプロイ（待機処理込み）
3. `make port-forward-temporal` - Temporal frontendをlocalhost:7233に公開
4. `make port-forward-ui` - Temporal Web UIをlocalhost:8080に公開
5. `make port-forward-argocd` - Argo CD UIをlocalhost:8443に公開
6. `make port-forward-grafana` - Grafana UIをlocalhost:3000に公開（パスワードは `make grafana-password` で取得）
7. `make port-forward-prometheus` - Prometheus UIをlocalhost:9090に公開
8. `make run-worker` - Goのworkerを起動
9. `make run-starter` - Workflowを実行

## その他のMakeターゲット

- `make argocd-password` - Argo CD管理者パスワードを表示
- `make grafana-password` - Grafana管理者パスワードを表示
- `make teardown` - kindクラスタを削除（cluster-deleteのエイリアス）
