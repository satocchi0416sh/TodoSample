# 🤖 Commit Buddy - AI-Powered Conventional Commit Generator

**Conventional Commit メッセージを AI が一発生成！**

Commit Buddy は、Dify AI を使用して git diff から自動的に Conventional Commit 形式のメッセージを生成するツールです。

## 🌟 特徴

- ✨ **AI自動生成**: git diff を解析して適切な Conventional Commit メッセージを生成
- 🚀 **複数の使用方法**: CLI、pre-commit hook、GitHub Actions に対応
- 🎯 **Conventional Commit準拠**: feat, fix, docs などの標準的なプレフィックスを自動選択
- 🛡️ **安全な実行**: ドライランモードとユーザー確認機能
- 🎨 **美しい出力**: カラフルで分かりやすいコンソール出力
- ⚙️ **柔軟な設定**: 環境変数やオプションで動作をカスタマイズ可能

## 📦 構成ファイル

```
commit-buddy/
├── commit-buddy.sh           # メインスクリプト
├── setup-commit-buddy.sh     # セットアップスクリプト
├── .githooks/
│   └── pre-commit           # pre-commit hook
├── .github/workflows/
│   └── commit-buddy.yml     # GitHub Actions ワークフロー
└── COMMIT_BUDDY_README.md   # このファイル
```

## 🚀 クイックスタート

### 1. セットアップの実行

```bash
# セットアップスクリプトを実行可能にする
chmod +x setup-commit-buddy.sh

# セットアップを開始
./setup-commit-buddy.sh
```

セットアップスクリプトが以下を自動で行います：
- 依存関係の確認
- 環境変数の設定
- 実行権限の付与
- Git hooks の設定
- テスト実行

### 2. 基本的な使用方法

```bash
# ファイルを変更
echo "新機能を追加" > feature.txt

# ステージングエリアに追加
git add feature.txt

# AI が自動でcommitメッセージを生成
./commit-buddy.sh
```

## 🛠️ 設定

### 必須環境変数

```bash
export DIFY_API_KEY="your-dify-api-key"
```

### オプション環境変数

```bash
export DIFY_BASE_URL="https://dify.arklet.jp/v1"  # デフォルト値
export USER_ID="commit-buddy-user"                 # デフォルト値
```

### 設定ファイル (.env)

```bash
# Commit Buddy Configuration
DIFY_API_KEY="your-api-key"
DIFY_BASE_URL="https://dify.arklet.jp/v1"
USER_ID="commit-buddy-user"
```

## 💻 使用方法

### CLI直接実行

```bash
# 基本的な使用方法
./commit-buddy.sh

# ドライラン（commitせずメッセージのみ生成）
./commit-buddy.sh --dry-run

# 全ての変更をステージしてcommit
./commit-buddy.sh --add-all

# 確認プロンプトをスキップ
./commit-buddy.sh --force

# ヘルプを表示
./commit-buddy.sh --help
```

### Pre-commit Hook

1. **有効化**
```bash
# Git hooks パスを設定
git config core.hooksPath .githooks

# pre-commit hook に実行権限を付与
chmod +x .githooks/pre-commit
```

2. **使用方法**
```bash
# 通常通りcommitするだけ
git add .
git commit  # AI が自動でメッセージを生成
```

3. **無効化**
```bash
# hookファイルを無効化
mv .githooks/pre-commit .githooks/pre-commit.disabled

# または Git hooks パスをリセット
git config --unset core.hooksPath
```

### GitHub Actions

1. **Secrets の設定**

   GitHub リポジトリの Settings → Secrets and variables → Actions で以下を設定：
   - `DIFY_API_KEY`: Dify API キー
   - `DIFY_BASE_URL`: Dify ベース URL

2. **自動実行**

   main または develop ブランチにプッシュすると自動実行されます。

3. **手動実行**

   Actions タブから "🤖 Commit Buddy" ワークフローを手動実行できます。

4. **スキップ**

   commit メッセージに `[skip-commit-buddy]` を含めると実行をスキップします。

## 🎯 Conventional Commit 形式

生成されるメッセージの形式：

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### サポートされるタイプ

- `feat`: 新機能
- `fix`: バグ修正
- `docs`: ドキュメント
- `style`: コードスタイル
- `refactor`: リファクタリング
- `test`: テスト
- `chore`: その他の作業
- `perf`: パフォーマンス改善
- `ci`: CI/CD
- `build`: ビルドシステム
- `revert`: リバート

### 例

```bash
feat(auth): ユーザー認証機能を追加

- ログイン・ログアウト機能
- JWT トークンによる認証
- パスワードハッシュ化

Closes #123
```

## 🔧 トラブルシューティング

### よくある問題

**1. APIキーが無効**
```bash
❌ ERROR: Dify API エラー: Invalid API key
```
→ `DIFY_API_KEY` の値を確認してください

**2. ワークフローが見つからない**
```bash
❌ ERROR: Workflow not found
```
→ APIキーが正しいワークフローに関連付けられているか確認してください

**3. 依存関係が不足**
```bash
❌ ERROR: 必要なコマンドがインストールされていません: jq
```
→ 不足しているパッケージをインストールしてください

**4. ステージングエリアに変更がない**
```bash
❌ ERROR: stagingエリアに変更がありません
```
→ `git add` でファイルをステージしてください

### 依存関係のインストール

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install git curl jq
```

**macOS:**
```bash
brew install git curl jq
```

**CentOS/RHEL:**
```bash
sudo yum install git curl jq
```

### デバッグモード

環境変数 `DEBUG=1` を設定すると詳細なログが表示されます：

```bash
DEBUG=1 ./commit-buddy.sh --dry-run
```

## 🔐 セキュリティ

### APIキーの管理

- ❌ **してはいけない**: APIキーをコードにハードコード
- ❌ **してはいけない**: APIキーをコミット
- ✅ **推奨**: 環境変数や `.env` ファイルで管理
- ✅ **推奨**: GitHub Secrets を使用

### .gitignore 設定

```gitignore
# Commit Buddy
.env
```

## 🤝 カスタマイズ

### Dify ワークフローの要件

Commit Buddy が正常に動作するには、Dify ワークフローが以下の仕様を満たしている必要があります：

**入力:**
- `diff` (string): git diff の内容

**出力:**
- `commit` または `text` (string): 生成された Conventional Commit メッセージ

**注意:** APIキーは使用するワークフローアプリに関連付けられている必要があります。

### スクリプトの拡張

`commit-buddy.sh` を拡張して独自の機能を追加できます：

```bash
# カスタム関数の追加例
custom_validation() {
    local message="$1"
    # カスタム検証ロジック
}
```

## 📊 統計とモニタリング

### GitHub Actions の実行履歴

Actions タブで以下を確認できます：
- 実行回数と成功率
- 生成されたメッセージの履歴
- エラーログとデバッグ情報

### ローカル実行の履歴

```bash
# 最近のcommitメッセージを確認
git log --oneline -10

# Conventional Commit形式のメッセージを検索
git log --grep="^feat\|^fix\|^docs" --oneline
```

## 🚀 高度な使用方法

### 複数プロジェクトでの使用

```bash
# プロジェクトごとに異なるAPIキー
export DIFY_API_KEY_PROJECT_A="api-key-a"
export DIFY_API_KEY_PROJECT_B="api-key-b"

# プロジェクトディレクトリで実行
cd project-a && DIFY_API_KEY="$DIFY_API_KEY_PROJECT_A" ./commit-buddy.sh
cd project-b && DIFY_API_KEY="$DIFY_API_KEY_PROJECT_B" ./commit-buddy.sh
```

### CI/CD パイプラインとの統合

```yaml
# .github/workflows/release.yml
name: Release
on:
  push:
    branches: [main]
jobs:
  semantic-release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Semantic Release
        uses: semantic-release/semantic-release@v21
        # Conventional Commit に基づいて自動リリース
```

## 📚 参考リンク

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)
- [Dify Documentation](https://docs.dify.ai/)
- [Git Hooks](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks)

## 🐛 バグ報告・機能要望

issues や pull requests をお気軽にお送りください！

## 📄 ライセンス

MIT License

---

**Happy Committing! 🎉** 