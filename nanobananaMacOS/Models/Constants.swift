// rule.mdを読むこと
import Foundation

// ============================================================
// アプリ基本定数
// 出力タイプ、出力モード、解像度、アプリ設定など
// プルダウン選択肢は DropdownOptions.swift を参照
// ============================================================

// MARK: - Output Types
/// 出力タイプ定義
enum OutputType: String, CaseIterable, Identifiable {
    case faceSheet = "顔三面図"
    case bodySheet = "素体三面図"
    case outfit = "衣装着用"
    case pose = "ポーズ"
    case sceneBuilder = "シーンビルダー"
    case background = "背景生成"
    case decorativeText = "装飾テキスト"
    case fourPanelManga = "4コマ漫画"
    case styleTransform = "スタイル変換"
    case infographic = "インフォグラフィック"

    var id: String { rawValue }

    var internalKey: String {
        switch self {
        case .faceSheet: return "step1_face"
        case .bodySheet: return "step2_body"
        case .outfit: return "step3_outfit"
        case .pose: return "step4_pose"
        case .sceneBuilder: return "scene_builder"
        case .background: return "background"
        case .decorativeText: return "decorative_text"
        case .fourPanelManga: return "four_panel_manga"
        case .styleTransform: return "style_transform"
        case .infographic: return "infographic"
        }
    }
}

// MARK: - Output Mode
/// 出力モード
enum OutputMode: String, CaseIterable, Identifiable {
    case yaml = "YAML出力"
    case api = "画像出力(API)"

    var id: String { rawValue }
}

// MARK: - API Sub Mode
/// APIサブモード
enum APISubMode: String, CaseIterable, Identifiable {
    case normal = "通常"
    case redraw = "参考画像清書"
    case simple = "シンプル"

    var id: String { rawValue }
}

// MARK: - Resolution
/// 解像度
enum Resolution: String, CaseIterable, Identifiable {
    case oneK = "1K"
    case twoK = "2K"
    case fourK = "4K"

    var id: String { rawValue }
}

// MARK: - App Constants
/// アプリ定数
struct AppConstants {
    static let maxSpeechLength = 30
    static let maxRecentFiles = 5
    static let maxCharacters = 5

    static let windowMinWidth: CGFloat = 1200
    static let windowMinHeight: CGFloat = 700

    static let leftColumnWidth: CGFloat = 320
    static let middleColumnWidth: CGFloat = 380

    // キャラクターデータベース
    static let appSupportFolderName = "nanobananaMacOS"
    static let characterDatabaseFileName = "characters.json"
}
