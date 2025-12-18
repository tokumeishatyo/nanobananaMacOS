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

### アーキテクチャ: MVVM

```
nanobananaMacOS/
├── Models/           # データモデル、定数
│   ├── Constants.swift        # アプリ基本定数（出力タイプ、モード、解像度等）
│   └── DropdownOptions.swift  # プルダウン選択肢を集約
├── ViewModels/       # ビューモデル（状態管理、ビジネスロジック）
│   └── MainViewModel.swift
├── Views/            # ビュー（UI）
│   ├── MainView.swift
│   ├── LeftColumnView.swift
│   ├── MiddleColumnView.swift
│   ├── RightColumnView.swift
│   └── Components/   # 再利用可能なUIコンポーネント
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

- `/docs/機能仕様書.md` - 全機能の詳細仕様
- `/docs/操作マニュアル.md` - ユーザー向け操作説明
- `/docs/ネイティブアプリ移植ガイド.md` - 移植手順の確認
- `/app/constants.py` - Python版定数定義
- `/app/main.py` - Python版メインUI
- `/app/logic/` - Python版ロジック層
- `/app/ui/` - Python版設定ウィンドウ
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
  - BackgroundSettingsView（背景生成）
  - DecorativeTextSettingsView（装飾テキスト）
  - FourPanelSettingsView（4コマ漫画）
  - StyleTransformSettingsView（スタイル変換）
  - InfographicSettingsView（インフォグラフィック）
- [x] 各設定ウィンドウ用ViewModel（SettingsViewModels.swift）
- [x] 詳細設定ボタンと設定ウィンドウの接続（.sheet()による表示）

### 未実装（機能は後回し）
- [ ] YAML生成ロジック
- [ ] Gemini API呼び出し
- [ ] 画像保存/読込
- [ ] ファイル選択ダイアログの実装（各設定ウィンドウの「参照」ボタン）
- [ ] 漫画コンポーザー
- [ ] 背景透過ツール

## 次のステップ

1. 残りの設定ウィンドウUIの調整（必要に応じてPython版を参照）
2. 機能実装（YAML生成、API呼び出しなど）

## 注意事項

- `/docs/`、`/app/`、`/ref/`フォルダは.gitignoreに入っており、リモートにプッシュしない
- `/template/`フォルダも.gitignoreに入っている
- `memo.txt`も.gitignoreに入っている
