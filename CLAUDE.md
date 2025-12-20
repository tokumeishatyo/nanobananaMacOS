# AI創作工房 macOS Native App - 開発コンテキスト

## プロジェクト概要

**AI創作工房**のPythonアプリ（`/app`フォルダ）をmacOS SwiftUIネイティブアプリに移植するプロジェクト。

- **元アプリ**: Python + CustomTkinter
- **移植先**: macOS SwiftUI
- **API**: Google Gemini API (gemini-2.0-flash-preview-image-generation)

---

## 🎉 マイルストーン達成（2024年12月）

**Python版の機能を忠実に再現完了。**

全10種類のYAML生成機能がPython版と同一形式で動作することを確認。
これ以降はPython版を参照せず、macOS版独自の機能拡張・YAML更新を行う。

### 完了した移植作業
- ✅ UI実装（3カラム構成、10種類の詳細設定ウィンドウ）
- ✅ 全10種類のYAML生成（Python版と同一出力形式）
- ✅ 設定の保存・復元機能
- ✅ ファイル選択ダイアログ（全設定ウィンドウ）
- ✅ title_overlay作者名対応（Python版バグ修正含む）

### 今後の開発方針
- Python版（`/app`フォルダ）は参照資料としてのみ使用
- macOS版独自の機能拡張を自由に行う
- YAMLフォーマットの改善も独自に実施可能

---

## 開発方針

### 絶対に守ること

1. **UIと機能の分離** - MVVMパターンを採用
2. **各機能のモジュール化** - 機能ごとにファイルを分割
3. **早めのファイル分割** - 1ファイルが大きくなりすぎないよう、早めに分割を検討する
   - 目安: 1ファイル200〜300行程度を上限とする
   - Python版では`main.py`に書きすぎて管理が困難になった教訓を活かす
4. **ビルド確認はユーザーが行う** - Xcodeでのビルド・動作確認はユーザー側で実施
5. **UI実装を優先** - 全UIの実装が完了するまで機能実装には入らない
6. **選択UIのパターン**
   - **4個以下の選択肢** → segmented picker（横並びボタン）
   - **5個以上の選択肢** → ドロップダウン（Picker）
   - ※全UI実装完了後、ユーザーから具体的な変更箇所の指示あり
   - ※4個の基準は今後変更の可能性あり

### 開発サイクル（厳守）

**実装前に必ずユーザーと意識合わせを行う。**

1. **確認** - 変更内容・影響範囲を報告
2. **意識合わせ** - ユーザーに変更内容を確認し、承認を得る
3. **実装** - 承認を得てから実装
4. **ビルド確認** - ユーザーがXcodeでビルド・動作確認
5. **ドキュメント更新** - 必要に応じてCLAUDE.mdや設計ドキュメントを更新
6. **コミット** - ユーザーの指示でコミット
7. **次の確認へ** - 次の項目の確認に移る

**このサイクルを崩さないこと。**

> **注:** Python版との比較は移植フェーズ完了により不要。機能拡張は独自に実施。

### アーキテクチャ: MVVM + Services

```
nanobananaMacOS/
├── Models/           # データモデル、定数
│   ├── Constants.swift        # アプリ基本定数（出力タイプ、モード、解像度等）
│   └── DropdownOptions.swift  # プルダウン選択肢を集約
├── ViewModels/       # ビューモデル（状態管理、ビジネスロジック）
│   ├── MainViewModel.swift
│   └── SettingsViewModels.swift  # 各設定ウィンドウ用ViewModel
├── Views/            # ビュー（UI）
│   ├── MainView.swift
│   ├── LeftColumnView.swift
│   ├── MiddleColumnView.swift
│   ├── RightColumnView.swift
│   ├── Settings/     # 設定ウィンドウ
│   └── Components/   # 再利用可能なUIコンポーネント
├── Services/         # サービス層（機能実装）
│   ├── ValidationService.swift    # バリデーション
│   ├── YAMLGeneratorService.swift # YAML生成（テンプレートエンジン使用）
│   ├── TemplateEngine.swift       # テンプレートエンジン（実装予定）
│   ├── ClipboardService.swift     # クリップボード操作
│   └── FileService.swift          # ファイル保存/読込
├── Utilities/        # ユーティリティ
│   └── WindowManager.swift    # 移動可能ウィンドウ管理
└── ContentView.swift # エントリーポイント
```

## APIキー管理（重要）

- **保存しない** - メモリ上のみ保持
- **アプリ終了で消滅**
- **アスタリスク表示** - SecureFieldを使用
- **通常リセットでは消えない** - APIキー専用のクリアボタンを用意

## スタイル設定の方針（重要）

Python版では「スタイル」設定が複数箇所（メイン画面、顔三面図、素体三面図、衣装着用）に散在しており、混乱とコンフリクトの原因になっていた。

**macOS版での整理方針:**
- **メイン画面のみ**でスタイル（アニメ調/ドット絵/ちびキャラ等）を設定
- **各ステップ（顔/素体/衣装等）からはスタイル設定を削除**
- **スタイル変換**は「既存画像を別スタイルに変換する」専用ツールとして維持

これにより：
- 設定が1箇所で完結し、混乱を防止
- 各ステップは「何を生成するか」に集中
- スタイル変換は後処理ツールとして明確な役割を持つ

## YAML生成の方針（重要）

### Python版との互換性

YAML生成は**Python版と同一の出力形式**を維持する。これはAI（Gemini API）に渡すプロンプトの品質に直結するため、非常に重要。

**参照すべきPythonコード:**
- `/app/main.py` - `_generate_character_sheet_yaml()` 等のYAML生成メソッド
- `/template/` - YAMLテンプレートファイル

### 顔三面図YAMLの構造（Python版準拠）

```yaml
# Face Character Reference Sheet (character_basic.yaml準拠)
type: character_design
title: "キャラクター名"
author: "作者名"

output_type: "face character reference sheet"

# レイアウト指示（三角形配置）
layout:
  arrangement: "triangular, inverted triangle formation"
  direction: "all views facing LEFT"
  top_row: [...]
  bottom_row: [...]

headshot_specification:
  type: "Character design base body (sotai) headshot..."
  coverage: "From top of head to base of neck..."
  ...

character:
  name: "キャラクター名"
  description: "外見説明"
  outfit: "NONE - bare skin only, no clothing"
  expression: "neutral expression"

character_style:
  style: "日本のアニメスタイル, 2Dセルシェーディング"
  proportions: "Normal head-to-body ratio (6-7 heads)"
  style_description: "High quality anime illustration"

output:
  format: "reference sheet with multiple views"
  views: "front view, 3/4 view, side profile"
  ...

constraints:
  layout: [...]
  design: [...]
  face_specific: [...]

anti_hallucination: [...]

output_cleanliness: [...]

style:
  color_mode: "fullcolor"
  output_style: ""
  aspect_ratio: "1:1"
```

### YAMLGeneratorServiceの実装方針

1. **Python版のメソッド構造を踏襲** - 各出力タイプに対応するメソッドを用意
2. **セクション構成を維持** - layout, headshot_specification, character_style等
3. **コメント（#）を含める** - AIへの視覚的な区切りとして機能
4. **制約セクションを必ず含める** - constraints, anti_hallucination, output_cleanliness
5. **説明文の改行はカンマ区切りに変換** - AIが特徴を正確に認識しやすくするため
   - 入力: `ポニーテールの赤い髪（改行）左顎にほくろ`
   - 出力: `description: "ポニーテールの赤い髪, 左顎にほくろ"`

## シーンビルダーのUI分割ルール

SceneBuilderSettingsViewは3つのシーンタイプ（ストーリー、バトル、ボスレイド）を持つ。

**分割方針:**
- 現在は1ファイルで管理
- **各シーンタイプが300行を超えたら**、個別ファイルに分割
  - `StorySceneView.swift`
  - `BattleSceneView.swift`
  - `BossRaidSceneView.swift`
- ViewModel（SceneBuilderSettingsViewModel）は分割せず、共通で使用

**分割の目安:**
- 各シーンタイプが約200〜250行の段階で分割を検討
- 新機能追加時に300行を超える見込みがあれば先に分割

## ポーズ設定の同一性保持（重要・機能実装時の注意）

Python版にあった「同一性保持」スライダーはUIから削除。

**理由:**
- ポーズキャプチャ時、参考画像から取り込むのは**ポーズのみ**
- 顔・衣装は入力画像（衣装着用三面図）のものを**常に保持**したい
- スライダーがあると設定に迷う原因になる

**機能実装時の対応:**
- API呼び出し時、同一性保持パラメータは**最大値（1.0）で固定**
- ユーザーが調整する必要なし

## 画面構成（3カラム）

### 左カラム（基本設定）
- 出力タイプ選択（10種類）
- 詳細設定ボタン
- スタイル設定（カラーモード、スタイル、アスペクト比）
- 基本情報（タイトル、作者名）
- YAML生成・リセットボタン
- 漫画コンポーザー、画像ツールボタン

### 中央カラム（API設定）
- 出力モード（YAML/API）
- APIキー入力（SecureField）
- APIモード（通常/清書/シンプル）
- 参考画像選択
- 解像度選択
- 画像生成ボタン
- 参考画像プレビュー
- API使用状況表示

### 右カラム（プレビュー）
- YAMLプレビュー（コピー/保存/読込ボタン付き）
- 画像プレビュー（保存/加工ボタン付き）

## 出力タイプ一覧

1. 顔三面図 (step1_face)
2. 素体三面図 (step2_body)
3. 衣装着用 (step3_outfit)
4. ポーズ (step4_pose)
5. シーンビルダー (scene_builder)
6. 背景生成 (background)
7. 装飾テキスト (decorative_text)
8. 4コマ漫画 (four_panel_manga)
9. スタイル変換 (style_transform)
10. インフォグラフィック (infographic)

## 参照ファイル

### 設計ドキュメント（/docs/）
- `/docs/機能仕様書.md` - 全機能の詳細仕様
- `/docs/操作マニュアル.md` - ユーザー向け操作説明
- `/docs/ネイティブアプリ移植ガイド.md` - 移植手順の確認
- `/docs/MacOSネイティブアプリ実装設計.md` - macOS版の全体設計
- `/docs/実装設計_template_design.md` - テンプレート設計
- `/docs/実装設計_新顔三面図.md` - 新テンプレートエンジン方式の設計
- `/docs/旧/` - 旧設計ドキュメント（アーカイブ）

### Python版ソースコード（/app/）
- `/app/constants.py` - Python版定数定義
- `/app/main.py` - Python版メインUI
- `/app/logic/` - Python版ロジック層
- `/app/ui/` - Python版設定ウィンドウ

### その他
- `/template/` - YAMLテンプレート

## 現在の進捗

### 完了
- [x] プロジェクト構造作成（MVVM）
- [x] 定数ファイル（Constants.swift）
- [x] MainViewModel（状態管理）
- [x] メイン画面UI（3カラム構成）
  - LeftColumnView
  - MiddleColumnView
  - RightColumnView
  - 共通コンポーネント
- [x] 各出力タイプの詳細設定ウィンドウUI（10種類）
  - FaceSheetSettingsView（顔三面図）※スタイル設定削除済み
  - BodySheetSettingsView（素体三面図）※スタイル設定削除済み
  - OutfitSettingsView（衣装着用）※スタイル設定削除済み、形状動的選択対応
  - PoseSettingsView（ポーズ）※Python版準拠に修正済み、同一性保持は固定
  - SceneBuilderSettingsView（シーンビルダー）※Python版準拠に修正済み、装飾テキスト配置対応
  - BackgroundSettingsView（背景生成）※シンプル化済み（参考画像トグル+説明のみ）
  - DecorativeTextSettingsView（装飾テキスト）※Python版準拠に修正済み、全スタイル対応
  - FourPanelSettingsView（4コマ漫画）※Python版準拠に修正済み、セリフ2個+ナレーション対応
  - StyleTransformSettingsView（スタイル変換）※Python版準拠に修正済み、背景透過対応
  - InfographicSettingsView（インフォグラフィック）※Python版準拠に修正済み、多言語対応
- [x] 各設定ウィンドウ用ViewModel（SettingsViewModels.swift）
- [x] 詳細設定ボタンと設定ウィンドウの接続
- [x] 移動可能な設定ウィンドウ（WindowManager + NSWindow）
  - .sheet()から独立ウィンドウ方式に変更
  - ウィンドウのドラッグ移動が可能に

### 機能実装（進行中）
- [x] サービス層の基盤実装
  - ValidationService（バリデーション）
  - YAMLGeneratorService（YAML生成 - モジュール化済み）
  - ClipboardService（クリップボード）
  - FileService（ファイル保存/読込）
- [x] 設定の保存・復元機能
  - MainViewModelに各出力タイプの設定を保存
  - 設定ウィンドウ再オープン時に復元
  - 出力タイプ変更時の確認ダイアログ
- [x] YAML生成機能（顔三面図）
  - Python版と同一形式のYAML出力
  - コピー/保存/読込機能
- [x] YAML生成機能（素体三面図）
  - 顔三面図からの参照画像対応
  - 体型/バスト特徴/表現タイプ対応
- [x] YAML生成機能（衣装着用）
  - プリセットモード（カテゴリ/形状/色/柄/印象）
  - 参考画像モード（フィットモード/頭部装飾オプション対応）
  - Python版と同一形式のYAML出力
- [x] YAML生成機能（ポーズ）
  - 通常モード（プリセット選択/手動入力）
  - ポーズキャプチャモード（参考画像からポーズのみ抽出）
  - 同一性保持は1.0固定（UIから削除済み）
  - Python版と同一形式のYAML出力
- [x] YAML生成機能（シーンビルダー - ストーリーシーン）
  - 背景設定（画像ファイル/プロンプト生成）
  - キャラクター配置（最大5人、動的生成）
  - ダイアログ設定（ナレーション/セリフ）
  - 装飾テキストオーバーレイ
  - **スタイルセクション追加（Python版で欠落していた不具合を修正）**
  - バトルシーン・ボスレイドは後日実装予定
- [x] YAML生成機能（背景生成）
  - 背景キャプチャモード（参考画像あり）
  - テキスト記述モード（参考画像なし）
  - 人物自動除去オプション
  - Python版と同一形式のYAML出力
- [x] YAML生成機能（装飾テキスト）
  - 4タイプ対応（技名テロップ/決め台詞/キャラ名プレート/メッセージウィンドウ）
  - メッセージウィンドウは3モード（フル/顔のみ/セリフのみ）
  - Python版と同一形式のYAML出力
- [x] YAML生成機能（4コマ漫画）
  - キャラクター設定（2人まで、参照画像対応）
  - 4コマ分のシーン・セリフ・ナレーション
  - MangaPanelDataをclassに変更（SwiftUI警告対策）
  - Python版と同一形式のYAML出力
- [x] title_overlay作者名対応（Python版バグ修正）
  - 作者名なし: タイトルのみtop-center
  - 作者名あり: タイトル左(large)、作者名右(small)
  - 全ジェネレーターで対応
- [x] YAML生成機能（スタイル変換）
  - ちびキャラ化（4スタイル、衣装/ポーズ保持オプション）
  - ドットキャラ化（5スタイル、5スプライトサイズ、色保持オプション）
  - 背景透過対応
  - Python版と同一形式のYAML出力
- [x] YAML生成機能（インフォグラフィック）
  - 5スタイル対応（グラフィックレコーディング/ノート風/スケッチ/マインドマップ/ホワイトボード）
  - 多言語出力対応（日本語/英語/中国語/韓国語/その他）
  - 8セクションの情報配置
  - メイン/おまけキャラクター画像対応
  - Python版と同一形式のYAML出力
- **✅ 全10種類のYAML生成機能完了**
- [x] ファイル選択ダイアログの実装（全10種類の設定ウィンドウ）- SwiftUI fileImporter使用
- [x] YAML読み込み機能
  - ローカルのYAMLファイル（.yaml/.yml）を読み込んでプレビュー表示
  - UTType(filenameExtension:)による拡張子フィルタリング
  - 読み込んだYAMLはコピー/保存で再利用可能
- [x] YAML部分更新機能
  - プレビューにYAMLがある状態で「YAML生成」→ 部分更新モード
  - 更新対象: title, author, color_mode, aspect_ratio, title_overlay
  - 詳細設定のバリデーションをスキップ（読み込んだYAMLの編集用）
  - タイトル空欄はエラー（通常モードと同じ）
- [x] 作者名ハンドリングの統一
  - 作者名が空欄の場合、`author:`行自体を出力しない
  - 新規生成・部分更新の両モードで一貫した動作
  - 全10ジェネレーターでgenerateAuthorLine()ユーティリティを使用
- [x] 二色刷り（Duotone）機能
  - カラーモード「二色刷り」選択時、`duotone_style`フィールドをYAMLに追加
  - 現在は「赤×黒」固定（将来的に色の追加可能な設計）
  - 全10ジェネレーターで対応
  - UIはドロップダウン非表示、`(赤×黒)`ラベル表示
- [ ] Gemini API呼び出し
- [ ] 漫画コンポーザー
- [ ] 背景透過ツール

## 現在進行中：テンプレートエンジン リファクタリング

### 背景

従来のYAML生成は各ジェネレーター（10ファイル、約680行のOutfitSheetYAMLGeneratorなど）にYAML構造がハードコーディングされていた。Windows移植も見据え、テンプレートファイルとコードを分離するリファクタリングを実施中。

### ブランチ構成

- `main` - 最新として前進（リファクタリング作業）
- `feature/template-engine-refactor` - 旧コード保険用（凍結）

### 進捗

**Phase 1: 旧コード削除 ✅ 完了**
- [x] デバッグUI削除（LeftColumnView.swift）
- [x] useTemplateEngineプロパティ削除（MainViewModel.swift）
- [x] 旧Generators/フォルダ削除（10ファイル）
- [x] 旧TemplateEngine/フォルダ削除（5ファイル）
- [x] 旧Resources/Templates/削除（2ファイル）
- [x] YAMLGeneratorService.swiftシンプル化（プレースホルダー実装）
- [x] 旧設計ドキュメント移動（docs/旧/フォルダへ14ファイル）
- [x] 新設計ドキュメント作成（docs/実装設計_新顔三面図.md）

**Phase 2: 新テンプレートエンジン実装（進行中）**
- [x] TemplateEngine.swift新規作成
  - テンプレートファイル読み込み（バンドルリソース優先）
  - パーシャル展開（`{{> header param="value"}}`）
  - 変数置換（`{{variable}}`）
  - 空白値フィールド削除（`key: ""` → 行削除、空セクション削除）
- [x] yaml_templatesフォルダをnanobananaMacOS/内に移動
- [x] Xcodeプロジェクト設定（Copy Bundle Resources）
- [x] 顔三面図（01_face_sheet.yaml）実装・動作確認完了
- [x] authorデフォルト値を空欄に変更（"Unknown" → ""）
- [ ] 素体三面図（02_body_sheet.yaml）
- [ ] 衣装着用（03_outfit_preset/reference.yaml）
- [ ] 他の出力タイプを順次対応

### テンプレートファイル

`nanobananaMacOS/yaml_templates/` フォルダに配置：
- `header.yaml` - 共通ヘッダーパーシャル
- `01_face_sheet.yaml` 〜 `10_infographic.yaml`
- Xcodeの「Copy Bundle Resources」に追加必須

### 設計方針

- テンプレートはHandlebars風の変数構文（`{{variable}}`）
- パーシャル展開（`{{> header header_comment="..."}}`）
- constraints/anti_hallucination/output_cleanlinessは共通化しない（各出力タイプで固有）

---

## 旧情報（参考）

### YAML生成機能 ✅ 旧実装完了（削除済み）

全10種類のYAML生成機能の旧実装は削除済み。テンプレートエンジン方式で再実装中。

### 残りの実装タスク

- [ ] Gemini API呼び出し
- [ ] 漫画コンポーザー
- [ ] 背景透過ツール

## Python版シーンビルダーのスタイルセクション欠落について

### 問題

Python版のシーンビルダーでは、トップ画面の「スタイル設定」（カラーモード、スタイル、アスペクト比）がYAMLに反映されていなかった。

### 原因

シーンビルダー機能を実装する際、他の機能とは異なるワークフローテンプレートをベースにしたため、スタイルセクションが含まれていなかった。

### macOS版での修正

macOS版では、他のジェネレータと同様に以下のスタイルセクションをYAML末尾に追加：

```yaml
style:
  color_mode: "fullcolor"
  output_style: "anime"
  aspect_ratio: "16:9"
```

これにより、トップ画面のスタイル設定が正しくYAMLに反映されるようになった。

---

## アスペクト比のYAML出力について（Googleフィードバック対応）

### 問題

YAML出力で`aspect_ratio: "1:1（正方形）"`のように日本語説明が含まれていた。

### 原因

`AspectRatio`enumの`rawValue`をそのままYAML出力に使用していた。`rawValue`はUI表示用に日本語説明を含んでいる。

### 修正

YAML出力時は`rawValue`ではなく`yamlValue`プロパティを使用するように変更：

```swift
// Before
let aspectRatioValue = mainViewModel.selectedAspectRatio.rawValue  // "1:1（正方形）"

// After
let aspectRatioValue = mainViewModel.selectedAspectRatio.yamlValue  // "1:1"
```

**対象ジェネレータ:**
- BackgroundYAMLGenerator
- DecorativeTextYAMLGenerator
- StorySceneYAMLGenerator
- PoseYAMLGenerator

**注意:** 他のジェネレータ（FaceSheet, BodySheet, Outfit）はアスペクト比が固定値のためこの問題は発生しない。

---

## 注意事項

- `/docs/`、`/app/`、`/ref/`フォルダは.gitignoreに入っており、リモートにプッシュしない
- `/template/`フォルダも.gitignoreに入っている
- `memo.txt`も.gitignoreに入っている
