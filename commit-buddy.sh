#!/bin/bash

# Commit Buddy - Conventional Commit 自動生成ツール
# Usage: ./commit-buddy.sh [options]

set -e

# .envファイルを読み込み（存在する場合）
if [[ -f ".env" ]]; then
    source .env
fi

# 設定（環境変数で上書き可能）
DIFY_BASE_URL="${DIFY_BASE_URL:-https://dify.arklet.jp/v1}"
DIFY_API_KEY="${DIFY_API_KEY}"
USER_ID="${USER_ID:-commit-buddy-user}"

# カラー出力用
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ヘルプ表示
show_help() {
    cat << EOF
🤖 Commit Buddy - Conventional Commit 自動生成ツール

USAGE:
    ./commit-buddy.sh [OPTIONS]

OPTIONS:
    -h, --help          このヘルプを表示
    -d, --dry-run       実際にcommitせず、生成されたメッセージのみ表示
    -a, --add-all       全ての変更をstageしてからcommit
    -f, --force         強制実行（警告を無視）

ENVIRONMENT VARIABLES:
    DIFY_API_KEY        Dify APIキー（必須）
    DIFY_BASE_URL       DifyベースURL（デフォルト: https://dify.arklet.jp/v1）
    USER_ID             ユーザーID（デフォルト: commit-buddy-user）

EXAMPLES:
    # 基本的な使用方法
    ./commit-buddy.sh

    # ドライラン
    ./commit-buddy.sh --dry-run

    # 全変更をstageしてcommit
    ./commit-buddy.sh --add-all

SETUP:
    1. Dify APIキーを設定:
       export DIFY_API_KEY="your-api-key"

    2. スクリプトを実行可能にする:
       chmod +x commit-buddy.sh

EOF
}

# エラー出力
error() {
    echo -e "${RED}❌ ERROR: $1${NC}" >&2
    exit 1
}

# 成功出力
success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# 警告出力
warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# 情報出力
info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# 必須環境変数チェック
check_environment() {
    if [[ -z "$DIFY_API_KEY" ]]; then
        error "DIFY_API_KEY 環境変数が設定されていません"
    fi

    # gitリポジトリチェック
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        error "Gitリポジトリではありません"
    fi
}

# stagingエリアのdiffを取得
get_staged_diff() {
    local diff
    diff=$(git diff --cached)
    
    if [[ -z "$diff" ]]; then
        error "stagingエリアに変更がありません。'git add' を実行してください"
    fi
    
    echo "$diff"
}

# Dify APIを呼び出してcommitメッセージを生成
generate_commit_message() {
    local diff="$1"
    local response
    local commit_message
    
    info "AI がconventional commitメッセージを生成中..." >&2
    
    # JSONエスケープ
    local escaped_diff
    escaped_diff=$(echo "$diff" | jq -Rs .)
    
    # Dify API呼び出し
    response=$(curl -s -X POST "$DIFY_BASE_URL/workflows/run" \
        -H "Authorization: Bearer $DIFY_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{
            \"inputs\": {
                \"diff\": $escaped_diff
            },
            \"response_mode\": \"blocking\",
            \"user\": \"$USER_ID\"
        }")
    
    # レスポンスチェック
    if [[ $? -ne 0 ]]; then
        error "Dify API呼び出しに失敗しました"
    fi
    
    # エラーチェック
    local error_msg
    error_msg=$(echo "$response" | jq -r '.error // empty')
    if [[ -n "$error_msg" ]]; then
        error "Dify API エラー: $error_msg"
    fi
    
    # commitメッセージ抽出
    commit_message=$(echo "$response" | jq -r '.data.outputs.commit // .data.outputs.text // empty')
    
    if [[ -z "$commit_message" || "$commit_message" == "null" ]]; then
        error "commitメッセージの生成に失敗しました。APIレスポンス: $response"
    fi
    
    # commitメッセージのクリーンアップ（バッククォートや余分な記号を削除）
    commit_message=$(echo "$commit_message" | sed 's/`//g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    echo "$commit_message"
}

# commitを実行
perform_commit() {
    local message="$1"
    local dry_run="$2"
    
    echo
    info "生成されたcommitメッセージ:"
    echo -e "${GREEN}📝 $message${NC}"
    echo
    
    if [[ "$dry_run" == "true" ]]; then
        success "ドライランモードです。実際のcommitは実行されませんでした"
        return 0
    fi
    
    # 確認プロンプト
    if [[ "$FORCE" != "true" ]]; then
        echo -e "${YELLOW}このメッセージでcommitしますか？ (y/N)${NC}"
        read -r confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            warning "commitがキャンセルされました"
            exit 0
        fi
    fi
    
    # commit実行
    if git commit -m "$message"; then
        success "commitが完了しました！ 🎉"
    else
        error "commitに失敗しました"
    fi
}

# メイン処理
main() {
    local dry_run=false
    local add_all=false
    
    # オプション解析
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -d|--dry-run)
                dry_run=true
                shift
                ;;
            -a|--add-all)
                add_all=true
                shift
                ;;
            -f|--force)
                FORCE=true
                shift
                ;;
            *)
                error "不明なオプション: $1"
                ;;
        esac
    done
    
    # 環境チェック
    check_environment
    
    # 全変更をstage
    if [[ "$add_all" == "true" ]]; then
        info "全ての変更をstaging..."
        git add .
    fi
    
    # diff取得
    local diff
    diff=$(get_staged_diff)
    
    # commitメッセージ生成
    local commit_message
    commit_message=$(generate_commit_message "$diff")
    
    # commit実行
    perform_commit "$commit_message" "$dry_run"
}

# 依存関係チェック
check_dependencies() {
    local missing_deps=()
    
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
        error "必要なコマンドがインストールされていません: ${missing_deps[*]}"
    fi
}

# 初期化
check_dependencies

# メイン実行
main "$@" # テスト修正
