---
name: run-all
description: デプロイ、ポートフォワード、Workerをバックグラウンドで起動し、Starterを実行する
disable-model-invocation: true
allowed-tools: Bash, Read
---

以下の手順でmakeターゲットを同時実行する:

1. `make deploy-apps` をフォアグラウンドで実行する（クラスタ・Argo CD インストール済み前提。PostgreSQL → Temporal を順にデプロイし、Healthy になるまで待機）

2. 以下の3つをバックグラウンド(`run_in_background: true`)で **同時に** 起動する:
   - `make port-forward-temporal`
   - `make port-forward-ui`
   - `make port-forward-argocd`

3. ポートフォワードが確立するまで2秒待ってから、`make run-worker` をバックグラウンドで起動する

4. Workerが起動するまで5秒待ち、Workerの出力を確認して `Started Worker` が含まれていることを確認する。失敗していた場合はエラー内容をユーザーに伝えて中断する

5. `make run-starter` をフォアグラウンドで実行し、結果をユーザーに表示する

完了後、稼働中のバックグラウンドタスク一覧をユーザーに表示する。
