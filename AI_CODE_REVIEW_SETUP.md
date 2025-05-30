# 🤖 AI Code Review Setup Guide

AI Code Review は、Pull Request に対して AI による自動コードレビューを実行する GitHub Actions ワークフローです。

## 🚀 機能

- PR の変更差分（patch）を Dify AI に送信
- AI が生成したコードの改善提案を GitHub の Inline Review コメントとして投稿
- `Apply suggestion` ボタンで簡単に修正を適用可能
- ラベルによる対象 PR のフィルタリング（オプション）

## 📋 必要な設定

### 1. GitHub Secrets の設定

リポジトリの `Settings` → `Secrets and variables` → `Actions` で以下のシークレットを設定：

| Secret 名             | 説明                                                             | 必須 |
| --------------------- | ---------------------------------------------------------------- | ---- |
| `DIFY_REVIEW_API_KEY` | Dify AI Code Review ワークフローの API キー                      | ✅    |
| `DIFY_BASE_URL`       | Dify API のベース URL（デフォルト: `https://dify.arklet.jp/v1`） | ❌    |

### 2. Dify ワークフローの設定

Dify 側で以下の入出力を持つワークフローを作成してください。

#### 入力（inputs）
```json
{
  "patch": "GitHub PR の patch 形式差分"
}
```

#### 出力（outputs）
```json
{
  "review_suggestions": [
    {
      "file": "path/to/file.ts",
      "line": 42,
      "suggestion": "改善されたコード",
      "comment": "なぜこの変更が必要か（オプション）"
    }
  ]
}
```

## 🏷️ ラベルフィルタリング（オプション）

特定のラベルが付いた PR のみでレビューを実行したい場合は、`.github/workflows/ai-code-review.yml` の以下の部分のコメントを外してください：

```yaml
# LABELS=$(gh pr view ${{ github.event.pull_request.number }} --json labels --jq '.labels[].name' | tr '\n' ' ')
# if [[ "$LABELS" == *"ai-review"* ]]; then
#   echo "skip_review=false" >> $GITHUB_OUTPUT
# else
#   echo "skip_review=true" >> $GITHUB_OUTPUT
#   echo "::notice::Skipping AI review - 'ai-review' label not found"
# fi
```

## 🔧 動作の流れ

1. **トリガー**: PR が opened/synchronize/ready_for_review のいずれかのイベントで起動
2. **差分取得**: GitHub API を使用して PR の patch 形式差分を取得
3. **AI レビュー**: Dify API に差分を送信してレビュー提案を生成
4. **コメント投稿**: 各提案を GitHub の Inline Review コメントとして投稿

## 📝 レビューコメントの形式

AI が生成したレビューコメントは以下の形式で投稿されます：

```
なぜこの変更が必要か（AIのコメント）

```suggestion
改善されたコード
```

GitHub UI では `Apply suggestion` ボタンが表示され、ワンクリックで修正を適用できます。

## ⚠️ トラブルシューティング

### API キーエラー
```
DIFY_REVIEW_API_KEY secret is not set
```
→ GitHub Secrets に `DIFY_REVIEW_API_KEY` を設定してください

### Dify API エラー
```
Dify API HTTP Error: 401
```
→ API キーが正しいか確認してください

### レビューコメント投稿エラー
```
Failed to post comment for file.ts:42 (HTTP 422)
```
→ 指定された行番号が PR の変更範囲内にない可能性があります

## 🎯 カスタマイズ

### レビュー対象の制限

- **ラベル**: 上記のラベルフィルタリング機能を有効化
- **ファイルタイプ**: Dify ワークフロー側で特定のファイルタイプのみレビューするよう設定
- **PR サイズ**: 大きすぎる PR をスキップする条件を追加

### Dify ワークフローの改善

- 言語別のレビュー基準を設定
- プロジェクト固有のコーディング規約を学習
- セキュリティやパフォーマンスの観点を追加 