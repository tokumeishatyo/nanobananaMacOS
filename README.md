# AI創作工房 for macOS

**AI創作工房**は、Google Gemini APIを活用したキャラクターデザイン・イラスト生成支援ツールです。

macOS SwiftUIネイティブアプリとして開発されており、キャラクターの顔三面図から衣装、ポーズ、シーン構築まで、一貫したワークフローでAI画像生成をサポートします。

---

## 主な機能

### キャラクターデザインワークフロー

| ステップ | 機能 | 説明 |
|---------|------|------|
| Step 1 | 顔三面図 | キャラクターの顔を正面・斜め・横から生成 |
| Step 2 | 素体三面図 | 体型を設定した素体（裸体）を生成 |
| Step 3 | 衣装着用 | 素体に衣装を着せた三面図を生成 |
| Step 4 | ポーズ | 様々なポーズのキャラクターを生成 |

### シーン・コンテンツ生成

| 機能 | 説明 |
|------|------|
| シーンビルダー | 背景とキャラクターを組み合わせたシーンを生成 |
| 背景生成 | 風景・室内などの背景画像を生成 |
| 装飾テキスト | 技名テロップ、決め台詞などの装飾文字を生成 |
| 4コマ漫画 | 4コマ形式の漫画を生成 |

### 画像変換・ツール

| 機能 | 説明 |
|------|------|
| スタイル変換 | ちびキャラ化、ドット絵化など |
| インフォグラフィック | 情報を視覚的に整理した画像を生成 |

---

## 出力モード

| モード | 説明 |
|--------|------|
| **YAMLモード** | YAMLプロンプトを生成（API不使用） |
| **通常モード** | 生成したYAMLでGemini APIを呼び出し |
| **清書モード** | 参考画像を元に高品質な画像を再生成 |
| **シンプルモード** | 自然言語で簡単に画像を編集 |

---

## 動作環境

- **OS**: macOS 12.0 (Monterey) 以降
- **アーキテクチャ**: Apple Silicon (M1/M2/M3) / Intel
- **Xcode**: 15.0 以降（ビルド時）
- **API**: Google Gemini API キーが必要

---

## インストール

### ソースからビルド

```bash
# リポジトリをクローン
git clone https://github.com/your-username/nanobanana.git
cd nanobanana

# Xcodeでプロジェクトを開く
open nanobananaMacOS.xcodeproj

# Xcodeでビルド & 実行 (Cmd + R)
```

### 必要な設定

1. Xcodeでプロジェクトを開く
2. Signing & Capabilitiesで自分のTeamを設定
3. ビルド & 実行

---

## 使い方

### 1. APIキーの設定

1. [Google AI Studio](https://aistudio.google.com/)でAPIキーを取得
2. アプリの中央カラムにAPIキーを入力
3. APIキーはメモリ上のみに保持され、アプリ終了時に消去されます

### 2. 基本的なワークフロー

1. **出力タイプを選択** - 左カラムから生成したい種類を選択
2. **詳細設定** - 「詳細設定」ボタンで設定ウィンドウを開く
3. **基本情報を入力** - タイトル、作者名などを入力
4. **YAML生成** - 「YAML生成」ボタンでプロンプトを生成
5. **画像生成** - 「画像生成」ボタンでAPIを呼び出し

### 3. YAMLモードの活用

APIキーなしでも、YAMLプロンプトを生成できます。
生成したYAMLは：
- クリップボードにコピー
- ファイルに保存
- Google AI Studioで直接使用

---

## アーキテクチャ

```
nanobananaMacOS/
├── Models/           # データモデル、定数
├── ViewModels/       # 状態管理、ビジネスロジック (MVVM)
├── Views/            # SwiftUI ビュー
│   ├── Settings/     # 設定ウィンドウ
│   └── Components/   # 再利用可能コンポーネント
├── Services/         # サービス層
│   ├── GeminiAPIService.swift    # Gemini API呼び出し
│   ├── TemplateEngine.swift      # YAMLテンプレート処理
│   └── YAMLImageExtractor.swift  # YAML解析
├── Utilities/        # ユーティリティ
│   └── WindowManager.swift       # ウィンドウ管理
└── yaml_templates/   # YAMLテンプレートファイル
```

---

## 技術スタック

| カテゴリ | 技術 |
|---------|------|
| **言語** | Swift 6 |
| **UI** | SwiftUI |
| **アーキテクチャ** | MVVM |
| **API** | Google Gemini API (REST) |
| **テンプレート** | 自作テンプレートエンジン (Handlebars風) |

---

## 注意事項

### APIキーについて

- APIキーはローカルに保存されません
- 通信はHTTPS経由でのみ行われます
- アプリ終了時にメモリから消去されます

### 生成画像について

- 生成された画像の利用はユーザーの責任となります
- Gemini APIのSafety Filterにより、一部のコンテンツは生成が拒否される場合があります
- API利用料金はユーザー負担となります

### 免責事項

- 本アプリはGoogle Gemini APIを使用します
- APIの利用にはユーザー自身のAPIキーが必要です
- 生成された画像の著作権・利用権はユーザーの責任で管理してください

---

## 開発ドキュメント

詳細な開発ドキュメントは `/docs/` フォルダを参照してください：

- `機能仕様書.md` - 全機能の詳細仕様
- `操作マニュアル.md` - ユーザー向け操作説明
- `MacOSネイティブアプリ実装設計.md` - 技術設計書
- `ネイティブアプリ移植ガイド.md` - 移植ガイド（Windows対応予定）

---

## ライセンス

MIT License

---

## 関連リンク

- [Google AI Studio](https://aistudio.google.com/) - APIキーの取得
- [Gemini API Documentation](https://ai.google.dev/docs) - API公式ドキュメント
