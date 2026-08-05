# プロジェクト概要 & コンテキスト

## 1. アプリケーション概要
- **名称**: manga-shop
- **概要**: PDF等のファイルを販売・配信するRailsアプリケーション
- **インフラ/ホスティング**: Render (Web Service), Cloudflare R2 (S3互換オブジェクトストレージ)

## 2. 技術スタック & バージョン情報
- **Ruby**: 3.4.4
- **Ruby on Rails**: 7.x / 8.x
- **Web サーバー**: Puma 8.0.2 (Cluster mode / 1 worker)
- **ファイルストレージ**: ActiveStorage + aws-sdk-s3 (v1.228.2) -> Cloudflare R2
- **フロントエンド/通信**: Hotwire (Turbo Stream / Stimulus)
- **決済サービス**: Stripe Checkout（今後実装予定）

## 3. 現在の進捗状況
1. 本番環境（Render + Neon）への初回のダミーデプロイが完了（"Your service is live" を確認済み）。
2. ローカル環境の `Gemfile`（sqlite3 / pg のグループ分け）および `config/database.yml` を調整し、ローカル（SQLite3）と本番（Neon）でDBを切り替えて正しく動作することを確認済み。
3. Active Storage と Mangaモデル（`title`, `price`, `description`, `cover_image`, `pdf_file`）を定義し、ローカルで画像とPDFの登録・表示（`rails_blob_path`）ができる状態まで完了。

以下をそのまま「4. 今後進めたいこと」に貼り付けて使えます。

## 4. 今後進めたいこと
- Stripe Checkout の最小導入を行い、商品詳細画面から決済ページへ遷移できるようにする。  
- 決済成功時とキャンセル時の遷移先を実装し、テストモードで決済完了までの動作確認を行う。  
- 購入履歴を管理するためのデータモデル（例: purchases）を作成し、誰が何を購入したかを記録できるようにする。  
- 決済完了者のみに期限付きPDFダウンロードURLを発行する購入者限定ダウンロード機能を実装する。  
- Stripe Webhook（checkout.session.completed）を導入し、決済確定処理を冪等に実行できるようにする。  
- 本番運用に向けて、価格バリデーション、PDF形式・サイズ制限、購入フローの自動テストを追加する。  


## 5. これまでに発生・解決したトラブルと注意点

### Cloudflare R2 と ActiveStorage の互換性設定
- **アップロードオプションのキー名**: `config/storage.yml` では `upload_options:` ではなく `upload:` を使用すること。
- **S3 チェックサムエラー（NoSuchKey / InvalidRequest 回避）**:
  - `aws-sdk-s3` (v1.228+) では、R2 アップロード時に複数のチェックサムヘッダーが飛んで `InvalidRequest` エラーになる問題が発生した。
  - `config/storage.yml` の R2 設定において、`upload:` に `checksum_algorithm: "WHEN_REQUIRED"`（または `checksum_algorithm: nil`）を指定して単一チェックサム/無効化の対応を行っている。
- **PDFのダウンロード挙動**:
  - PDF はブラウザ直開きの代わりに `disposition: :attachment`（強制ダウンロード）で配信する構成をとっている。
＊2026年8月4日現在、上記のトラブルは解決済み。


### 環境変数 (Render / `.env`)
R2 との連携には以下の環境変数が必須：
- `R2_ACCESS_KEY_ID`
- `R2_SECRET_ACCESS_KEY`
- `R2_BUCKET_NAME`
- `R2_ENDPOINT`

## 6. AI への指示・開発ガイドライン
- コードを提案・変更する際は、既存の Cloudflare R2 接続仕様（`storage.yml` の `upload:` 設定）を崩さないように注意してください。
- エラー解析を行う際は、ActiveStorage や `aws-sdk-s3` と S3互換ストレージ（R2）の仕様差分を考慮してください。
- レスポンスは日本語で丁寧かつ簡潔に回答してください。