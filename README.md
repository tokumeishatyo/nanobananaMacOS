# AI創作工房 (AI Sousaku Koubou)

**macOS Native Application for AI-Powered Illustration & Manga Creation**

![Version](https://img.shields.io/badge/version-5.1-blue)
![Platform](https://img.shields.io/badge/platform-macOS-lightgrey)
![API](https://img.shields.io/badge/API-Google%20Gemini-orange)

---

## 概要 (Overview)

AI創作工房は、Google Gemini APIを活用した高品質イラスト・漫画生成macOSネイティブアプリケーションです。

**「絵を描く技術がなくても、自分のイメージを画像に。」**

キャラクターデザインから漫画制作まで、一貫したワークフローで創作活動を支援します。

### ターゲットユーザー

- イラストレーター・漫画家（下書き・アイデア出し）
- TRPGプレイヤー（キャラクターシート作成）
- 同人誌・Web小説作家（表紙・挿絵作成）
- 教育・ビジネス用途（インフォグラフィック作成）

---

## 主な機能 (Features)

### キャラクター制作ワークフロー

顔から始めて、一貫性のあるキャラクターを段階的に作成できます。

```
顔三面図 → 素体三面図 → 衣装着用 → ポーズ → シーン合成/漫画
```

| Step | 機能 | 説明 |
|------|------|------|
| 1 | **顔三面図** | キャラクターの顔デザインを確定（正面・横・背面） |
| 2 | **素体三面図** | 体型を確定（顔はStep1を継承） |
| 3 | **衣装着用** | プリセットから選択 or 参考画像から着せ替え |
| 4 | **ポーズ** | プリセットポーズ or ポーズキャプチャ |

### シーン・漫画制作

| 機能 | 説明 |
|------|------|
| **シーンビルダー** | 背景 + 複数キャラクター（最大5人）を合成 |
| **漫画ページコンポーザー** | キャラカード生成、登場人物シート、1コマ/4コマ漫画作成 |
| **4コマ漫画** | 起承転結の4コマ漫画を1枚で生成 |
| **ストーリーYAML生成** | 漫画用YAMLを簡単に作成（英訳機能付き） |

### スタイル変換

| 機能 | 説明 |
|------|------|
| **ちびキャラ化** | 2〜3頭身のデフォルメキャラに変換 |
| **ドットキャラ化** | ピクセルアート/ゲームスプライト風に変換 |

### その他の機能

| 機能 | 説明 |
|------|------|
| **背景生成** | 様々なシチュエーションの背景画像を生成 |
| **装飾テキスト** | 技名テロップ、決め台詞、メッセージウィンドウ等 |
| **インフォグラフィック** | キャラクター中心の図解・情報整理画像 |
| **背景透過** | 生成画像の背景を透過処理（macOS 14.0+） |
| **画像リサイズ** | 生成画像のサイズ調整 |

---

## 画面構成 (Screen Layout)

```
┌─────────────────────────────────────────────────────────────┐
│  AI創作工房                                                  │
├─────────────┬───────────────────────┬───────────────────────┤
│  左列        │  中央列               │  右列                 │
│             │                       │                       │
│ [出力タイプ] │  [APIキー設定]        │  [YAMLプレビュー]     │
│ [詳細設定]   │  [APIモード]          │  [コピー][保存][読込] │
│ [スタイル]   │  [参考画像]           │                       │
│ [基本情報]   │  [解像度]             │  [生成画像プレビュー] │
│             │  [画像生成]           │  [保存][加工]         │
│ [YAML生成]   │                       │                       │
│ [リセット]   │                       │                       │
│             │                       │                       │
│ [キャラ管理] │                       │                       │
│ [衣装管理]   │                       │                       │
│ [ストーリー] │                       │                       │
│ [漫画コンポ] │                       │                       │
│ [画像ツール] │                       │                       │
└─────────────┴───────────────────────┴───────────────────────┘
```

---

## 出力モード (Output Modes)

| モード | 説明 | 用途 |
|--------|------|------|
| **YAML出力** | YAMLをクリップボードにコピー | ブラウザ版Geminiで使用 |
| **通常モード** | アプリ内で直接画像生成 | 標準的な画像生成 |
| **清書モード** | 参考画像+YAMLで高品質再描画 | ブラウザ版で成功した画像の高解像度化 |
| **シンプルモード** | テキストプロンプトのみで生成 | 手軽な画像生成 |

---

## 漫画コンポーザー (Manga Composer)

### 概要

漫画制作を支援する統合ツール。キャラクターカード生成から漫画ページ作成まで対応。

### 描画モード (render_mode)

| モード | 説明 |
|--------|------|
| `full_body` | 全身描画 |
| `bubble_only` | ちびアイコン付き吹き出し |
| `text_only` | 吹き出しのみ（効果音など） |
| `inset_visualization` | インセット（夢・画面・回想） |

### 吹き出しスタイル (bubble_style)

17種類のスタイルに対応：

```
normal, shout, whisper, think, narration,
angry, surprised, wavy, square, double,
burst, cloud, jagged, heart, star, ice, electric
```

### インセット機能

キャラクターの内面（夢、回想、画面内表示）を描画：
- 内部背景・衣装・状況・感情を個別設定
- ゲストキャラクター追加（最大2人）
- 9グリッド配置対応

### バージョン履歴

| Version | 主な機能 |
|---------|----------|
| 1.0 | 基本機能 |
| 2.0〜2.3 | render_mode, position auto, chibi_reference |
| 3.0〜3.4 | 品質プリセット, インセット, bubble_style 17種類 |
| 3.5 | ストーリーインポート修正, 手動衣装登録 |
| 4.0 | 1コマモード対応 |
| **5.0** | **ストーリーYAMLジェネレーター** |
| **5.1** | **英訳機能（gemini-2.5-flash）** |

---

## ストーリーYAML生成 (Story YAML Generator)

Version 5.0で追加された新機能。漫画コンポーザー用のYAMLを簡単に作成できます。

### 特徴

- **1コマ/4コマ対応** - モードを選択して作成
- **キャラクタDB連携** - 登録済みキャラクターを選択
- **インセット対応** - 夢・画面・回想シーンを設定
- **複数ゲスト** - インセット内にゲストキャラを追加
- **英訳機能** - gemini-2.5-flashで自動翻訳（APIキー必要）

### 翻訳対象フィールド

- scene（シーン説明）
- features（表情・ポーズ）
- internal_background/outfit/situation/emotion（インセット設定）
- guests.description（ゲスト外見）

---

## キャラクタ・衣装データベース

### キャラクタ管理

登録されたキャラクターは漫画コンポーザーで選択可能：
- 名前
- 顔の特徴 (faceFeatures)
- 体の特徴 (bodyFeatures)
- 顔参照画像 (face_reference)
- ちびキャラ参照画像 (chibi_reference)

### 衣装管理

登録された衣装はキャラクターに適用可能：
- 衣装名
- 衣装説明
- 参照画像

---

## 動作要件 (Requirements)

| 項目 | 要件 |
|------|------|
| **OS** | macOS 14.0 (Sonoma) 以降 |
| **API** | Google AI API Key |
| **ネットワーク** | インターネット接続必須 |

### APIキーの取得

1. [Google AI Studio](https://aistudio.google.com/apikey) にアクセス
2. Googleアカウントでログイン
3. 「Get API Key」でキーを取得

### API使用について

- Gemini APIは従量課金制です
- 無料枠を超えると料金が発生します
- 詳細は [Google AI料金ページ](https://ai.google.dev/pricing) を参照してください

---

## インストール (Installation)

### ソースからビルド

```bash
# リポジトリをクローン
git clone https://github.com/tokumeishatyo/nanobananaMacOS.git
cd nanobananaMacOS

# Xcodeでプロジェクトを開く
open nanobananaMacOS.xcodeproj

# Xcodeでビルド & 実行 (Cmd + R)
```

### 必要な設定

1. Xcodeでプロジェクトを開く
2. Signing & Capabilitiesで自分のTeamを設定
3. App Sandbox → Network → **Outgoing Connections (Client)** を有効化
4. ビルド & 実行

---

## 使い方 (Quick Start)

### 1. キャラクターを作る

```
1. 「顔三面図」で顔を作成 → 保存
2. 「素体三面図」で体型を決定（顔三面図を参照）→ 保存
3. 「衣装着用」で衣装を着せる（素体三面図を参照）→ 保存
4. 「ポーズ」でポーズを適用 → 完成！
```

### 2. 漫画を作る

```
1. 「キャラクタ管理」でキャラクターを登録
2. 「衣装管理」で衣装を登録
3. 「漫画コンポーザー」で漫画を作成
   - ストーリーYAMLをインポート or 直接入力
   - 各コマのシーン・セリフを設定
   - YAML生成 → 画像生成
```

### 3. ストーリーYAMLを作る

```
1. 「ストーリー作成」ボタンをクリック
2. 1コマ/4コマモードを選択
3. キャラクターを選択、シーン・セリフを入力
4. 「英訳する」にチェックで自動翻訳（APIキー必要）
5. YAML生成 → ファイル保存
```

---

## 技術仕様 (Technical Specifications)

| 項目 | 技術 |
|------|------|
| **言語** | Swift 5.9+ |
| **UI** | SwiftUI |
| **アーキテクチャ** | MVVM |
| **画像生成API** | Google Gemini API (gemini-3-pro-image-preview) |
| **翻訳API** | Google Gemini API (gemini-2.5-flash) |
| **データ形式** | YAML |
| **テンプレート** | 自作テンプレートエンジン (Handlebars風) |

### アーキテクチャ

```
nanobananaMacOS/
├── Models/           # データモデル、定数
├── ViewModels/       # 状態管理、ビジネスロジック (MVVM)
├── Views/            # SwiftUI ビュー
│   ├── Settings/     # 設定ウィンドウ (10種類)
│   └── Components/   # 再利用可能コンポーネント
├── Services/         # サービス層
│   ├── GeminiAPIService.swift      # 画像生成API
│   ├── TemplateEngine.swift        # YAMLテンプレート処理
│   ├── CharacterDatabaseService.swift  # キャラクタDB
│   └── WardrobeDatabaseService.swift   # 衣装DB
├── StoryGenerator/   # ストーリーYAML生成機能
│   ├── Views/
│   ├── ViewModels/
│   └── Services/
│       ├── StoryYAMLGenerator.swift
│       └── TranslationService.swift
├── Utilities/        # ユーティリティ
│   └── WindowManager.swift
└── yaml_templates/   # YAMLテンプレートファイル
```

---

## 制限事項 (Limitations)

### 一貫性について

- AI画像生成の特性上、完全に同一のキャラクターデザインが出力されることを保証するものではありません
- 三面図ワークフローにより一貫性の向上を図っていますが、若干の差異が生じる場合があります

### コンテンツについて

- Gemini APIのSafety Filterにより、一部のコンテンツは生成が拒否される場合があります
- 生成されたコンテンツの著作権・利用権はユーザーの責任で管理してください

### APIキーについて

- APIキーはメモリ上のみに保持され、アプリ終了時に消去されます
- 通信はHTTPS経由でのみ行われます
- ローカルに保存されません

---

## ライセンス (License)

MIT License

---

## 関連リンク (Links)

- [Google AI Studio](https://aistudio.google.com/) - APIキーの取得
- [Gemini API Documentation](https://ai.google.dev/docs) - API公式ドキュメント
- [Google AI Pricing](https://ai.google.dev/pricing) - 料金情報

---

## 謝辞 (Acknowledgments)

- [Google Gemini API](https://ai.google.dev/)
- SwiftUI & macOS Development Community

---

**AI創作工房** - 絵を描く技術がなくても、自分のイメージを画像に。
