# temporal-kind

Temporal Serverをk8s clusterにデプロイするサンプルをkindで稼働させる。

## ディレクトリ構成

- k8s: kind, Temporalを含むk8s manifestの置き場
- temporal: TemporalでWorkflowを実行するサンプルプログラムの置き場

## アーキテクチャ構成

- Temporal ServerはHelm chartを使ってデプロイする
- kind含め全てのk8s manifestはkubectl apply -f によって手動デプロイする
- TemporalのbackendにはpostgreSQLを使う。簡単のため、postgreSQLもkind上にデプロイする
- Temporal実行のサンプルはGolangで実装する
