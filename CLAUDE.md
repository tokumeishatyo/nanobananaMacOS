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

### アーキテクチャ: MVVM

```
nanobananaMacOS/
├── Models/           # データモデル、定数
│   └── Constants.swift
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
  - FaceSheetSettingsView（顔三面図）
  - BodySheetSettingsView（素体三面図）※Python版に合わせて調整済み
  - OutfitSettingsView（衣装着用）※Python版に合わせて調整済み
  - PoseSettingsView（ポーズ）
  - SceneBuilderSettingsView（シーンビルダー）
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
