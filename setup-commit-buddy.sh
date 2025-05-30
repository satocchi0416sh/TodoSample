#!/bin/bash

# Commit Buddy セットアップスクリプト
# Usage: ./setup-commit-buddy.sh

set -e

# カラー出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
cat << "EOF"
  ____                          _ _     ____            _     _       
 / ___|___  _ __ ___  _ __ ___ (_) |_  | __ ) _   _  __| | __| |_   _ 
| |   / _ \| '_ ` _ \| '_ ` _ \| | __| |  _ \| | | |/ _` |/ _` | | | |
| |__| (_) | | | | | | | | | | | | |_  | |_) | |_| | (_| | (_| | |_| |
 \____\___/|_| |_| |_|_| |_| |_|_|\__| |____/ \__,_|\__,_|\__,_|\__, |
                                                               |___/ 
🤖 AI-Powered Conventional Commit Generator
EOF
echo -e "${NC}"

info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}" >&2
}

# 依存関係チェック
check_dependencies() {
    local missing_deps=()
    
    info "依存関係をチェック中..."
    
    if ! command -v git &> /dev/null; then
        missing_deps+=("git")
    fi
    
    if ! command -v curl &> /dev/null; then
        missing_deps+=("curl")
    fi
    
    if ! command -v jq &> /dev/null; then
        missing_deps+=("jq")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        error "以下のコマンドがインストールされていません: ${missing_deps[*]}"
        echo
        echo "インストール方法:"
        echo "  Ubuntu/Debian: sudo apt-get install ${missing_deps[*]}"
        echo "  macOS: brew install ${missing_deps[*]}"
        echo "  CentOS/RHEL: sudo yum install ${missing_deps[*]}"
        exit 1
    fi
    
    success "依存関係の確認完了"
}

# 環境変数設定
setup_environment() {
    echo
    info "🔧 環境変数の設定"
    echo
    
    # APIキーの入力
    while [[ -z "$DIFY_API_KEY" ]]; do
        echo -e "${YELLOW}Dify APIキーを入力してください:${NC}"
        read -s DIFY_API_KEY
        if [[ -z "$DIFY_API_KEY" ]]; then
            warning "APIキーが入力されていません。再度入力してください。"
        fi
    done
    
    # ベースURLの入力（オプション）
    echo -e "${YELLOW}DifyベースURL (デフォルト: https://dify.arklet.jp/v1):${NC}"
    read DIFY_BASE_URL_INPUT
    DIFY_BASE_URL="${DIFY_BASE_URL_INPUT:-https://dify.arklet.jp/v1}"
    
    # 環境変数を.envファイルに保存
    cat > .env << EOF
# Commit Buddy Configuration
DIFY_API_KEY="$DIFY_API_KEY"
DIFY_BASE_URL="$DIFY_BASE_URL"
USER_ID="commit-buddy-user"
EOF
    
    success "環境変数を .env ファイルに保存しました"
    
    # .bashrcや.zshrcに追加するかユーザーに確認
    echo
    echo -e "${YELLOW}シェル設定ファイル（~/.bashrc, ~/.zshrc など）に環境変数を追加しますか？ (y/N)${NC}"
    read -r add_to_shell
    
    if [[ "$add_to_shell" =~ ^[Yy]$ ]]; then
        local shell_config=""
        if [[ "$SHELL" == *"zsh"* ]]; then
            shell_config="$HOME/.zshrc"
        elif [[ "$SHELL" == *"bash"* ]]; then
            shell_config="$HOME/.bashrc"
        else
            echo -e "${YELLOW}シェル設定ファイルを指定してください:${NC}"
            read shell_config
        fi
        
        if [[ -n "$shell_config" ]]; then
            echo "" >> "$shell_config"
            echo "# Commit Buddy Configuration" >> "$shell_config"
            echo "export DIFY_API_KEY=\"$DIFY_API_KEY\"" >> "$shell_config"
            echo "export DIFY_BASE_URL=\"$DIFY_BASE_URL\"" >> "$shell_config"
            
            success "環境変数を $shell_config に追加しました"
            warning "変更を反映するには 'source $shell_config' を実行するか、新しいターミナルを開いてください"
        fi
    fi
}

# 実行権限の設定
setup_permissions() {
    echo
    info "🔐 実行権限の設定"
    
    chmod +x commit-buddy.sh
    success "commit-buddy.sh に実行権限を設定しました"
    
    if [[ -f ".githooks/pre-commit" ]]; then
        chmod +x .githooks/pre-commit
        success ".githooks/pre-commit に実行権限を設定しました"
    fi
}

# Git hooks の設定
setup_git_hooks() {
    echo
    info "🪝 Git hooks の設定"
    
    # .githooksディレクトリが存在するかチェック
    if [[ -d ".githooks" ]]; then
        # Git hooksディレクトリを.githooksに設定
        git config core.hooksPath .githooks
        success "Git hooks パスを .githooks に設定しました"
        
        echo
        echo -e "${YELLOW}Pre-commit hookを有効にしますか？ (y/N)${NC}"
        echo "  → commitする度に自動でConventional Commitメッセージを生成します"
        read -r enable_precommit
        
        if [[ "$enable_precommit" =~ ^[Yy]$ ]]; then
            if [[ -f ".githooks/pre-commit" ]]; then
                success "Pre-commit hook が有効になりました"
            else
                warning "Pre-commit hook ファイルが見つかりません"
            fi
        else
            if [[ -f ".githooks/pre-commit" ]]; then
                mv .githooks/pre-commit .githooks/pre-commit.disabled
                info "Pre-commit hook を無効にしました（.githooks/pre-commit.disabled に移動）"
            fi
        fi
    else
        warning ".githooks ディレクトリが見つかりません"
    fi
}

# GitHub Secrets の設定ガイド
setup_github_secrets() {
    echo
    info "🔐 GitHub Secrets の設定ガイド"
    echo
    echo "GitHub Actionsを使用する場合は、以下のSecretを設定してください:"
    echo
    echo "1. GitHubリポジトリの Settings → Secrets and variables → Actions に移動"
    echo "2. 以下のSecretsを追加:"
    echo "   - Name: DIFY_API_KEY"
    echo "     Value: $DIFY_API_KEY"
    echo "   - Name: DIFY_BASE_URL"
    echo "     Value: $DIFY_BASE_URL"
    echo
    warning "⚠️  APIキーなどの機密情報は安全に管理してください"
}

# テスト実行
test_commit_buddy() {
    echo
    info "🧪 テスト実行"
    echo
    
    echo -e "${YELLOW}Commit Buddyのテストを実行しますか？ (y/N)${NC}"
    read -r run_test
    
    if [[ "$run_test" =~ ^[Yy]$ ]]; then
        # 環境変数を読み込み
        source .env
        
        echo "テスト用の変更を作成中..."
        echo "# Commit Buddy Test" > commit-buddy-test.txt
        git add commit-buddy-test.txt
        
        echo
        info "Commit Buddy をテスト実行中..."
        
        if ./commit-buddy.sh --dry-run; then
            success "テストが正常に完了しました！"
            
            # テストファイルを削除
            git reset HEAD commit-buddy-test.txt
            rm -f commit-buddy-test.txt
        else
            error "テストに失敗しました"
            # テストファイルを削除
            git reset HEAD commit-buddy-test.txt || true
            rm -f commit-buddy-test.txt || true
        fi
    fi
}

# メイン処理
main() {
    echo
    info "Commit Buddy のセットアップを開始します..."
    echo
    
    # Gitリポジトリチェック
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        error "Gitリポジトリではありません。git init を実行してください。"
        exit 1
    fi
    
    # 依存関係チェック
    check_dependencies
    
    # 環境変数設定
    setup_environment
    
    # 実行権限設定
    setup_permissions
    
    # Git hooks設定
    setup_git_hooks
    
    # GitHub Secrets設定ガイド
    setup_github_secrets
    
    # テスト実行
    test_commit_buddy
    
    echo
    success "🎉 Commit Buddy のセットアップが完了しました！"
    echo
    echo "使用方法:"
    echo "  1. 基本的な使用: ./commit-buddy.sh"
    echo "  2. ドライラン: ./commit-buddy.sh --dry-run"
    echo "  3. 全変更を追加してcommit: ./commit-buddy.sh --add-all"
    echo "  4. ヘルプ表示: ./commit-buddy.sh --help"
    echo
    echo "詳細は README.md を確認してください。"
}

# メイン実行
main "$@" 