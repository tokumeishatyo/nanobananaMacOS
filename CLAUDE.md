# AI創作工房 macOS Native App - 開発コンテキスト

## プロジェクト概要

**AI創作工房**のPythonアプリ（`/app`フォルダ）をmacOS SwiftUIネイティブアプリに移植するプロジェクト。

- **元アプリ**: Python + CustomTkinter
- **移植先**: macOS SwiftUI
- **API**: Google Gemini API (gemini-2.0-flash-preview-image-generation)

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

**実装前に必ずユーザーと意識合わせを行う。** Python版での失敗の原因は、確認なしに実装を進めたことにある。

1. **確認** - Python版とSwift版を比較し、差分を報告
2. **意識合わせ** - ユーザーに変更内容を確認し、承認を得る
3. **実装** - 承認を得てから実装
4. **ビルド確認** - ユーザーがXcodeでビルド・動作確認
5. **ドキュメント更新** - 必要に応じてCLAUDE.mdや設計ドキュメントを更新
6. **コミット** - ユーザーの指示でコミット
7. **次の確認へ** - 次の項目の確認に移る

**このサイクルを崩さないこと。**

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
│   ├── YAMLGeneratorService.swift # YAML生成（Python版準拠）
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
- `/docs/実装設計_UI構造.md` - UI構造の詳細設計
- `/docs/実装設計_状態管理.md` - 状態管理の詳細設計

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
  - YAMLGeneratorService（YAML生成）
  - ClipboardService（クリップボード）
  - FileService（ファイル保存/読込）
- [x] 設定の保存・復元機能
  - MainViewModelに各出力タイプの設定を保存
  - 設定ウィンドウ再オープン時に復元
  - 出力タイプ変更時の確認ダイアログ
- [x] YAML生成機能（顔三面図）
  - Python版と同一形式のYAML出力
  - コピー/保存/読込機能
- [ ] YAML生成機能（残り9種類の出力タイプ）
- [ ] Gemini API呼び出し
- [ ] ファイル選択ダイアログの実装（各設定ウィンドウの「参照」ボタン）
- [ ] 漫画コンポーザー
- [ ] 背景透過ツール

## 次のステップ

1. 残りの出力タイプのYAML生成実装（素体三面図、衣装着用、ポーズ等）
2. Gemini API連携の実装
3. ファイル選択ダイアログの実装

## 注意事項

- `/docs/`、`/app/`、`/ref/`フォルダは.gitignoreに入っており、リモートにプッシュしない
- `/template/`フォルダも.gitignoreに入っている
- `memo.txt`も.gitignoreに入っている
