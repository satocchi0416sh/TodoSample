# 🎯 PR Concierge セットアップガイド

## 🚨 現在のエラー解決手順

### 1. GitHub Secrets の設定

リポジトリページで以下を設定：
```Settings → Secrets and variables → Actions
```

**必須Secrets:**
- `DIFY_PR_API_KEY`: PR Concierge用のDify APIキー
- `DIFY_BASE_URL`: https://dify.arklet.jp/v1 (デフォルト)

### 2. Difyワークフローの作成

PR Concierge用に以下の仕様でDifyワークフローを作成してください：

**入力仕様:**
```json
{
  "diff": "string - PRのdiff内容",
  "env": "string - 環境情報（例: frontend）"
}
```

**出力仕様:**
```json
{
  "data": {
    "outputs": {
      "pr_body_md": "string - 生成されたPR本文（Markdown形式）"
    }
  }
}
```

または

```json
{
  "data": {
    "outputs": {
      "text": "string - 生成されたPR本文（Markdown形式）"
    }
  }
}
```

### 3. ワークフロー例

以下のような内容を生成するワークフローを作成：

```markdown
## 📝 変更概要
[変更の概要]

## 🎯 変更内容
- [変更内容1]
- [変更内容2]

## ⚠️ リスク
- [潜在的なリスク1]
- [潜在的なリスク2]

## 🧪 テスト案
- [ ] [テスト項目1]
- [ ] [テスト項目2]
```

### 4. 動作確認

1. Difyワークフローを作成
2. APIキーを取得
3. GitHub Secretsに設定
4. 新しいPRを作成してテスト

### 5. トラブルシューティング

**エラーコード126の一般的な原因:**
- APIキー未設定または無効
- Difyワークフローが存在しない
- ワークフローの入出力仕様が不一致

**確認項目:**
- [ ] GitHub Secretsが正しく設定されている
- [ ] Difyワークフローが作成されている
- [ ] APIキーがワークフローに対応している
- [ ] ワークフローの入出力仕様が正しい

### 6. 一時的な無効化

問題が解決するまでPR Conciergeを無効化したい場合：

```bash
# ワークフローファイルを一時的にリネーム
mv .github/workflows/pr-concierge.yml .github/workflows/pr-concierge.yml.disabled
``` 