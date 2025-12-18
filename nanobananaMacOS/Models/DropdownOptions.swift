import Foundation

// ============================================================
// プルダウン選択肢定義
// 各設定画面のPickerで使用する選択肢を集約
// ============================================================

// MARK: - ===========================================
// MARK: - メイン画面関連
// MARK: - ===========================================

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

// MARK: - Character Style
/// キャラクタースタイル
enum CharacterStyle: String, CaseIterable, Identifiable {
    case standardAnime = "標準アニメ"
    case pixelArt = "ドット絵"
    case chibi = "ちびキャラ"

    var id: String { rawValue }
}

// MARK: - ===========================================
// MARK: - 素体三面図（Step2）関連
// MARK: - ===========================================

// MARK: - Body Type Preset
/// 体型プリセット
enum BodyTypePreset: String, CaseIterable, Identifiable {
    case femalStandard = "標準体型（女性）"
    case maleStandard = "標準体型（男性）"
    case slim = "スリム体型"
    case muscular = "筋肉質"
    case chubby = "ぽっちゃり"
    case petite = "幼児体型"
    case tall = "高身長"
    case short = "低身長"

    var id: String { rawValue }
}

// MARK: - Body Render Type
/// 素体表現タイプ
enum BodyRenderType: String, CaseIterable, Identifiable {
    case silhouette = "シルエット"
    case whiteLeotard = "素体（白レオタード）"
    case whiteUnderwear = "素体（白下着）"
    case anatomical = "解剖学的"

    var id: String { rawValue }
}

// MARK: - Bust Feature
/// バスト特徴
enum BustFeature: String, CaseIterable, Identifiable {
    case auto = "おまかせ"
    case small = "控えめ"
    case normal = "標準"
    case large = "豊か"

    var id: String { rawValue }
}

// MARK: - ===========================================
// MARK: - 衣装着用（Step3）関連
// MARK: - ===========================================

// MARK: - Outfit Category
/// 服装カテゴリ
enum OutfitCategory: String, CaseIterable, Identifiable {
    case auto = "おまかせ"
    case model = "モデル用"
    case suit = "スーツ"
    case swimsuit = "水着"
    case casual = "カジュアル"
    case uniform = "制服"
    case formal = "ドレス/フォーマル"
    case sports = "スポーツ"
    case japanese = "和服"
    case workwear = "作業着/職業服"

    var id: String { rawValue }

    /// カテゴリに対応する形状リスト
    var shapes: [String] {
        switch self {
        case .auto:
            return ["おまかせ"]
        case .model:
            return ["おまかせ", "白レオタード", "グレーレオタード", "黒レオタード",
                    "白下着", "Tシャツ+短パン", "タンクトップ+短パン"]
        case .suit:
            return ["おまかせ", "パンツスタイル", "タイトスカート", "プリーツスカート",
                    "ミニスカート", "スリーピース", "ダブルスーツ", "タキシード"]
        case .swimsuit:
            return ["おまかせ", "三角ビキニ", "ホルターネック", "バンドゥ",
                    "ワンピース", "ハイレグ", "パレオ付き", "サーフパンツ", "競泳パンツ"]
        case .casual:
            return ["おまかせ", "Tシャツ+デニム", "ワンピース", "ブラウス+スカート",
                    "パーカー", "カーディガン", "シャツ+チノパン", "ポロシャツ", "レザージャケット"]
        case .uniform:
            return ["おまかせ", "セーラー服", "ブレザー", "メイド服", "ナース服",
                    "OL制服", "学ラン", "詰襟", "警察官", "軍服"]
        case .formal:
            return ["おまかせ", "イブニングドレス", "カクテルドレス", "ウェディングドレス",
                    "チャイナドレス", "サマードレス", "タキシード", "モーニング", "燕尾服"]
        case .sports:
            return ["おまかせ", "テニスウェア", "体操服", "レオタード", "ヨガウェア",
                    "競泳水着", "サッカーユニフォーム", "野球ユニフォーム", "バスケユニフォーム", "柔道着"]
        case .japanese:
            return ["おまかせ", "着物", "浴衣", "振袖", "巫女服",
                    "袴", "紋付袴", "羽織", "甚平"]
        case .workwear:
            return ["おまかせ", "白衣", "作業着", "シェフコート", "消防服", "建設作業員"]
        }
    }
}

// MARK: - Outfit Color
/// 服装カラー
enum OutfitColor: String, CaseIterable, Identifiable {
    case auto = "おまかせ"
    case black = "黒"
    case white = "白"
    case navy = "紺"
    case red = "赤"
    case pink = "ピンク"
    case blue = "青"
    case lightBlue = "水色"
    case green = "緑"
    case yellow = "黄"
    case orange = "オレンジ"
    case purple = "紫"
    case beige = "ベージュ"
    case gray = "グレー"
    case gold = "ゴールド"
    case silver = "シルバー"

    var id: String { rawValue }
}

// MARK: - Outfit Pattern
/// 服装柄
enum OutfitPattern: String, CaseIterable, Identifiable {
    case auto = "おまかせ"
    case solid = "無地"
    case stripe = "ストライプ"
    case check = "チェック"
    case floral = "花柄"
    case dot = "ドット"
    case border = "ボーダー"
    case tropical = "トロピカル"
    case lace = "レース"
    case camouflage = "迷彩"
    case animal = "アニマル柄"

    var id: String { rawValue }
}

// MARK: - Outfit Style
/// 服装スタイル（印象）
enum OutfitFashionStyle: String, CaseIterable, Identifiable {
    case auto = "おまかせ"
    case mature = "大人っぽい"
    case cute = "可愛い"
    case sexy = "セクシー"
    case cool = "クール"
    case modest = "清楚"
    case sporty = "スポーティ"
    case gorgeous = "ゴージャス"
    case wild = "ワイルド"
    case intellectual = "知的"
    case dandy = "ダンディ"
    case casual = "カジュアル"

    var id: String { rawValue }
}

// MARK: - ===========================================
// MARK: - ポーズ（Step4）関連
// MARK: - ===========================================

// MARK: - Pose Preset
/// ポーズプリセット
enum PosePreset: String, CaseIterable, Identifiable {
    case none = "（プリセットなし）"
    case hadouken = "波動拳（かめはめ波）"
    case speciumRay = "スペシウム光線"
    case riderKick = "ライダーキック"
    case fingerBeam = "指先ビーム"
    case meditation = "坐禅（瞑想）"

    var id: String { rawValue }

    /// プリセットに対応する動作説明
    var description: String {
        switch self {
        case .none: return ""
        case .hadouken: return "Thrusting both palms forward at waist level, knees slightly bent, focusing energy between hands"
        case .speciumRay: return "Crossing arms in a plus sign shape (+) in front of chest, right hand vertical, left hand horizontal"
        case .riderKick: return "Mid-air dynamic flying kick, one leg extended forward, body angled downward, floating in the air"
        case .fingerBeam: return "Pointing index finger forward, arm fully extended, other fingers closed, cool and composed expression"
        case .meditation: return "Sitting cross-legged in lotus position, hands resting on knees, eyes closed, meditative posture"
        }
    }

    /// プリセットに対応するデフォルト風効果
    var defaultWindEffect: WindEffect {
        switch self {
        case .none, .fingerBeam, .meditation: return .none
        case .hadouken, .speciumRay, .riderKick: return .fromFront
        }
    }
}

// MARK: - Eye Line
/// 目線方向
enum EyeLine: String, CaseIterable, Identifiable {
    case front = "前を見る"
    case up = "上を見る"
    case down = "下を見る"

    var id: String { rawValue }
}

// MARK: - Pose Expression
/// ポーズ用表情（Python版準拠）
enum PoseExpression: String, CaseIterable, Identifiable {
    case neutral = "無表情"
    case smile = "笑顔"
    case angry = "怒り"
    case crying = "泣き"
    case shy = "恥じらい"

    var id: String { rawValue }

    var prompt: String {
        switch self {
        case .neutral: return "neutral expression, calm face, no emotion"
        case .smile: return "smiling, happy expression, cheerful face"
        case .angry: return "angry expression, furious face, frowning"
        case .crying: return "crying, tearful expression, sad face with tears"
        case .shy: return "shy expression, blushing, embarrassed face"
        }
    }
}

// MARK: - Wind Effect
/// 風の影響
enum WindEffect: String, CaseIterable, Identifiable {
    case none = "なし"
    case fromFront = "前からの風"
    case fromBehind = "後ろからの風"
    case fromSide = "横からの風"

    var id: String { rawValue }

    var prompt: String {
        switch self {
        case .none: return ""
        case .fromFront: return "Strong Wind from Front"
        case .fromBehind: return "Wind from Behind"
        case .fromSide: return "Side Wind"
        }
    }
}

// MARK: - Character Pose
/// キャラクターポーズ（シーンビルダー等で使用）
enum CharacterPose: String, CaseIterable, Identifiable {
    // バトル系
    case attack = "攻撃"
    case defense = "防御"
    case damage = "ダメージ"
    case victory = "勝利"
    case stance = "構え"
    case charging = "必殺技チャージ"
    // 基本動作
    case standing = "立ち"
    case sitting = "座り"
    case crouching = "しゃがみ"
    case jumping = "ジャンプ"
    case running = "走り"
    case walking = "歩き"
    // 静的ポーズ
    case meditation = "瞑想"
    case prayer = "祈り"
    case armsCrossed = "腕組み"

    var id: String { rawValue }
}

// MARK: - Character Facing
/// キャラクター向き
enum CharacterFacing: String, CaseIterable, Identifiable {
    case front = "正面"
    case right = "→右向き"
    case left = "←左向き"
    case rightDiagonal = "↗斜め右"
    case leftDiagonal = "↖斜め左"
    case back = "背面"

    var id: String { rawValue }
}

// MARK: - Character Expression
/// キャラクター表情
enum CharacterExpression: String, CaseIterable, Identifiable {
    case neutral = "無表情"
    case smile = "笑顔"
    case angry = "怒り"
    case sad = "悲しみ"
    case surprised = "驚き"
    case shy = "照れ"
    case serious = "真剣"
    case confident = "自信"

    var id: String { rawValue }
}

// MARK: - Effect Type
/// エフェクトタイプ
enum EffectType: String, CaseIterable, Identifiable {
    case none = "なし"
    case beam = "ビーム"
    case wave = "波動"
    case fire = "炎"
    case lightning = "雷"
    case ice = "氷"
    case dark = "闇"
    case light = "光"
    case aura = "オーラ"

    var id: String { rawValue }
}

// MARK: - Effect Color
/// エフェクトカラー
enum EffectColor: String, CaseIterable, Identifiable {
    case auto = "おまかせ"
    case blue = "青"
    case red = "赤"
    case yellow = "黄"
    case green = "緑"
    case purple = "紫"
    case white = "白"
    case rainbow = "虹色"
    case gold = "金色"
    case black = "黒"

    var id: String { rawValue }
}

// MARK: - Zoom Level
/// ズームレベル（角度変更用）
enum ZoomLevel: String, CaseIterable, Identifiable {
    case fullBody = "全身"
    case upperBody = "上半身"
    case bustUp = "バストアップ"
    case faceUp = "顔アップ"

    var id: String { rawValue }
}

// MARK: - Camera Angle
/// カメラアングル
enum CameraAngle: String, CaseIterable, Identifiable {
    case front = "正面"
    case leftProfile = "←左向き"
    case rightProfile = "→右向き"
    case leftDiagonal = "↖左斜め前"
    case rightDiagonal = "↗右斜め前"
    case back = "背面"
    case highAngle = "↑上から見下ろす"
    case lowAngle = "↓下から見上げる"

    var id: String { rawValue }
}

// MARK: - ===========================================
// MARK: - シーンビルダー関連
// MARK: - ===========================================

// MARK: - Scene Type
/// シーンタイプ
enum SceneType: String, CaseIterable, Identifiable {
    case battle = "バトルシーン"
    case story = "ストーリーシーン"
    case bossRaid = "ボスレイド"

    var id: String { rawValue }
}

// MARK: - ===========================================
// MARK: - 背景生成関連
// MARK: - ===========================================

// MARK: - Background Preset
/// 背景プリセット
enum BackgroundPreset: String, CaseIterable, Identifiable {
    case custom = "カスタム"
    case classroomDay = "教室（昼）"
    case classroomNight = "教室（夜）"
    case corridor = "廊下"
    case rooftop = "屋上"
    case park = "公園"
    case street = "街中"
    case beach = "海辺"
    case forest = "森"
    case castle = "城"
    case dungeon = "ダンジョン"

    var id: String { rawValue }
}

// MARK: - ===========================================
// MARK: - 装飾テキスト関連
// MARK: - ===========================================

// MARK: - Decorative Text Type
/// 装飾テキストタイプ
enum DecorativeTextType: String, CaseIterable, Identifiable {
    case skillName = "技名テロップ"
    case catchphrase = "決め台詞"
    case namePlate = "キャラ名プレート"
    case messageWindow = "メッセージウィンドウ"

    var id: String { rawValue }
}

// MARK: - ===========================================
// MARK: - スタイル変換関連
// MARK: - ===========================================

// MARK: - Style Transform Type
/// スタイル変換タイプ
enum StyleTransformType: String, CaseIterable, Identifiable {
    case chibi = "ちびキャラ化"
    case pixel = "ドットキャラ化"

    var id: String { rawValue }
}

// MARK: - ===========================================
// MARK: - インフォグラフィック関連
// MARK: - ===========================================

// MARK: - Infographic Style
/// インフォグラフィックスタイル
enum InfographicStyle: String, CaseIterable, Identifiable {
    case graphicRecording = "グラレコ風"
    case notebook = "ノート風"
    case sketch = "ポンチ絵"
    case mindMap = "マインドマップ風"
    case whiteboard = "ホワイトボード風"

    var id: String { rawValue }
}
