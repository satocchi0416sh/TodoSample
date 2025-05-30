# Todo管理アプリ

Next.js 14 + TypeScript + Tailwind CSSで構築されたモダンなTodo管理アプリケーションです。

## 機能

- ✅ Todo項目の追加
- ✅ Todo項目の完了/未完了切り替え
- ✅ Todo項目の削除
- ✅ 進捗状況の表示
- ✅ ローカルストレージによるデータ永続化
- ✅ レスポンシブデザイン
- ✅ 美しいモダンUI

## 技術スタック

- **Next.js 14** - React フレームワーク（App Router使用）
- **TypeScript** - 型安全性
- **Tailwind CSS** - スタイリング
- **Lucide React** - アイコンライブラリ

## セットアップ

1. 依存関係のインストール:
```bash
npm install
```

2. 開発サーバーの起動:
```bash
npm run dev
```

3. ブラウザで [http://localhost:3000](http://localhost:3000) を開く

## ビルド

本番用ビルドを作成:
```bash
npm run build
```

ビルドしたアプリを起動:
```bash
npm start
```

## 開発

- コードの lint チェック: `npm run lint`
- ファイルは `app/` ディレクトリ以下に配置
- スタイルは Tailwind CSS を使用

## データストレージ

現在はブラウザのローカルストレージを使用してデータを保存しています。
データはブラウザに保存されるため、ブラウザを変更したりデータを削除すると失われます。

## ライセンス

MIT License 