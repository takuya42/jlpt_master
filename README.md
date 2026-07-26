# jlpt_master

JLPT Japanese Learning App

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## RevenueCat課金イベントのSlack通知

`functions/src/index.ts`の`revenueCatWebhook`は、RevenueCat Webhookを受信して対象の課金イベントをSlack Block Kit形式で通知するFirebase Functions v2のHTTP関数です。対象は`INITIAL_PURCHASE`、`RENEWAL`、`CANCELLATION`、`EXPIRATION`、`BILLING_ISSUE`、`PRODUCT_CHANGE`、`REFUND`です。`INITIAL_PURCHASE`と`REFUND`のみ`@channel`通知し、日時は日本時間、金額は通貨記号付きで表示します。対象外のイベントは正常に受領して無視します。

通知済みのRevenueCat `event.id`はFirestoreの`revenuecat_webhook_events`コレクションへ保存します。同じIDが再送された場合はSlackへ重複通知せずHTTP 200を返します。Slack送信が失敗した場合は予約データを削除してHTTP 502を返し、RevenueCatからの再試行を受け付けます。デプロイ先プロジェクトでFirestoreデータベースを事前に有効化してください。

### 1. RevenueCat Webhook設定

1. Firebaseへのデプロイ後に表示される関数URL（例: `https://asia-northeast1-PROJECT_ID.cloudfunctions.net/revenueCatWebhook`）を控えます。
2. RevenueCat Dashboardで **Project settings > Integrations > Webhooks** を開き、Webhookを追加します。
3. URLに関数URLを設定し、Authorization headerに推測困難な値を設定します（例: `Bearer <十分に長いランダム文字列>`）。ここで設定する文字列全体が、次項の`REVENUECAT_WEBHOOK_SECRET`と完全一致する必要があります。
4. Production/Testの送信範囲を選択し、保存後にRevenueCatのテスト送信でHTTP 200になることを確認します。

Authorizationが未設定または一致しないリクエストにはHTTP 401を返します。Secret値はログへ出力しません。

### 2. Firebase Secret登録

Firebase CLIで対象プロジェクトを選択し、次の2つのSecretを登録します。値をコマンドライン引数へ直接書かず、プロンプトへ入力してください。

```bash
firebase use PROJECT_ID
firebase functions:secrets:set REVENUECAT_WEBHOOK_SECRET
firebase functions:secrets:set SLACK_WEBHOOK_URL
```

Secretを変更した場合は、関数を再デプロイして新しいバージョンを反映します。

### 3. Slack Incoming Webhook設定

1. Slack APIの **Your Apps > Create New App > From scratch** からアプリを作成します。
2. **Incoming Webhooks** を有効にし、**Add New Webhook to Workspace** から通知先チャンネルを許可します。
3. 発行されたWebhook URLを`SLACK_WEBHOOK_URL`としてFirebase Secretへ登録します。URLをGitへコミットしたり、公開場所へ貼り付けたりしないでください。

### 4. デプロイ

Node.js 20とFirebase CLIを用意し、次を実行します。

```bash
cd functions
npm install
npm run build
cd ..
firebase deploy --only functions:revenueCatWebhook
```

関数は`asia-northeast1`にデプロイされます。デプロイ後、出力されたURLをRevenueCatへ設定してください。

### 5. ローカルテスト

依存関係をインストールし、単体テストを実行します。

```bash
cd functions
npm install
npm test
```

Functions Emulator用に、Git管理外の`functions/.secret.local`を作成します。

```dotenv
REVENUECAT_WEBHOOK_SECRET=Bearer local-test-secret
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/REPLACE/WITH/TEST_WEBHOOK
```

実在するテスト用Slack Webhookを使用し、リポジトリルートでEmulatorを起動します。

```bash
firebase emulators:start --only functions --project PROJECT_ID
```

別のターミナルから以下を実行します。URL内の`PROJECT_ID`は起動時に指定した値に置き換えてください。

```bash
curl -i -X POST \
  "http://127.0.0.1:5001/PROJECT_ID/asia-northeast1/revenueCatWebhook" \
  -H 'Authorization: Bearer local-test-secret' \
  -H 'Content-Type: application/json' \
  --data '{
    "api_version": "1.0",
    "event": {
      "id": "evt_local_initial_purchase_001",
      "type": "INITIAL_PURCHASE",
      "product_id": "jlpt_pro_monthly",
      "app_user_id": "local-test-user",
      "store": "APP_STORE",
      "country_code": "JP",
      "price_in_purchased_currency": 980,
      "currency": "JPY",
      "environment": "SANDBOX",
      "event_timestamp_ms": 1767225600000
    }
  }'
```

成功時はHTTP 200です。同じJSONを再送すると`Duplicate ignored`（HTTP 200）となり、Slackには再通知されません。Authorizationを別の値に変えた場合はHTTP 401になることも確認できます。Slackへの送信に失敗した場合はHTTP 502を返すため、RevenueCat側で再試行可能です。ローカルで重複防止まで確認する場合は、FunctionsとFirestoreを`firebase emulators:start --only functions,firestore --project PROJECT_ID`で起動してください。
