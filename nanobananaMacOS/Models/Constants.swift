import Foundation

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

// MARK: - Color Modes
/// カラーモード定義
enum ColorMode: String, CaseIterable, Identifiable {
    case fullColor = "フルカラー"
    case monochrome = "モノクロ"
    case sepia = "セピア色"
    case duotone = "二色刷り"

    var id: String { rawValue }

    var prompt: String {
        switch self {
        case .fullColor: return ""
        case .monochrome: return "monochrome, black and white, grayscale"
        case .sepia: return "sepia tone, vintage brown tint, old photograph style"
        case .duotone: return "" // Combined with DuotoneColor
        }
    }
}

/// 二色刷りカラー
enum DuotoneColor: String, CaseIterable, Identifiable {
    case redBlack = "赤×黒"
    case blueBlack = "青×黒"
    case greenBlack = "緑×黒"
    case purpleBlack = "紫×黒"
    case orangeBlack = "オレンジ×黒"

    var id: String { rawValue }

    var prompt: String {
        switch self {
        case .redBlack: return "red and black duotone, two-color print, manga style"
        case .blueBlack: return "blue and black duotone, two-color print"
        case .greenBlack: return "green and black duotone, two-color print"
        case .purpleBlack: return "purple and black duotone, two-color print"
        case .orangeBlack: return "orange and black duotone, two-color print"
        }
    }
}

// MARK: - Output Styles
/// 出力スタイル定義
enum OutputStyle: String, CaseIterable, Identifiable {
    case anime = "アニメ調"
    case pixelArt = "ドット絵"
    case chibi = "ちびキャラ"
    case realistic = "リアル調"
    case watercolor = "水彩画風"
    case oilPainting = "油絵風"

    var id: String { rawValue }
}

// MARK: - Aspect Ratios
/// アスペクト比定義
enum AspectRatio: String, CaseIterable, Identifiable {
    case square = "1:1（正方形）"
    case wide16_9 = "16:9"
    case tall9_16 = "9:16"
    case standard4_3 = "4:3"
    case portrait3_4 = "3:4"
    case ultraWide3_1 = "3:1"

    var id: String { rawValue }

    var ratio: (width: Int, height: Int) {
        switch self {
        case .square: return (1, 1)
        case .wide16_9: return (16, 9)
        case .tall9_16: return (9, 16)
        case .standard4_3: return (4, 3)
        case .portrait3_4: return (3, 4)
        case .ultraWide3_1: return (3, 1)
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
}
