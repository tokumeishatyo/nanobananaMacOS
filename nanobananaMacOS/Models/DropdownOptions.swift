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

    /// YAML出力用の値
    var yamlValue: String {
        switch self {
        case .square: return "1:1"
        case .wide16_9: return "16:9"
        case .tall9_16: return "9:16"
        case .standard4_3: return "4:3"
        case .portrait3_4: return "3:4"
        case .ultraWide3_1: return "3:1"
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

    /// プリセットに対応する追加プロンプト（Python版POSE_PRESETS準拠）
    var additionalPrompt: String {
        switch self {
        case .none: return ""
        case .hadouken: return "energy blast stance, power stance"
        case .speciumRay: return "cross beam pose, heroic stance"
        case .riderKick: return "aerial attack, no shadow on ground to emphasize floating"
        case .fingerBeam: return "precision attack, finger gun pose"
        case .meditation: return "meditation, zazen, static still pose"
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
/// シーンタイプ（Python版準拠）
enum SceneType: String, CaseIterable, Identifiable {
    case story = "ストーリーシーン"
    case battle = "バトルシーン"
    case bossRaid = "ボスレイド"

    var id: String { rawValue }
}

// MARK: - Background Source Type
/// 背景ソースタイプ
enum BackgroundSourceType: String, CaseIterable, Identifiable {
    case file = "ファイル指定"
    case prompt = "情景説明で生成"

    var id: String { rawValue }
}

// MARK: - Collision Type (Battle)
/// 衝突タイプ（バトルシーン用）
enum CollisionType: String, CaseIterable, Identifiable {
    case centerClash = "中央衝突"
    case splitScreen = "画面分割"
    case mergeBlend = "グラデーション融合"

    var id: String { rawValue }

    var englishValue: String {
        switch self {
        case .centerClash: return "Center Clash"
        case .splitScreen: return "Split Screen"
        case .mergeBlend: return "Merge/Blend"
        }
    }
}

// MARK: - Dominant Side (Battle)
/// 優勢側（バトルシーン用）
enum DominantSide: String, CaseIterable, Identifiable {
    case even = "互角"
    case left = "左側有利"
    case right = "右側有利"

    var id: String { rawValue }

    var englishValue: String {
        switch self {
        case .even: return "None (Even)"
        case .left: return "Left"
        case .right: return "Right"
        }
    }
}

// MARK: - Border VFX (Battle)
/// 境界エフェクト（バトルシーン用）
enum BorderVFX: String, CaseIterable, Identifiable {
    case sparksLightning = "火花と稲妻"
    case simpleGlow = "シンプル"
    case none = "なし"

    var id: String { rawValue }

    var englishValue: String {
        switch self {
        case .sparksLightning: return "Intense Sparks & Lightning"
        case .simpleGlow: return "Simple Glow"
        case .none: return "None"
        }
    }
}

// MARK: - Screen Shake (Battle)
/// 画面揺れ（バトルシーン用）
enum ScreenShake: String, CaseIterable, Identifiable {
    case none = "なし"
    case mild = "軽め"
    case moderate = "普通"
    case heavy = "激しい"

    var id: String { rawValue }

    var englishValue: String {
        switch self {
        case .none: return "None"
        case .mild: return "Mild"
        case .moderate: return "Moderate"
        case .heavy: return "Heavy"
        }
    }
}

// MARK: - Blend Mode
/// 合成モード
enum BlendMode: String, CaseIterable, Identifiable {
    case add = "発光（加算）"
    case screen = "スクリーン"
    case normal = "通常"

    var id: String { rawValue }

    var englishValue: String {
        switch self {
        case .add: return "Add"
        case .screen: return "Screen"
        case .normal: return "Normal"
        }
    }
}

// MARK: - Story Layout
/// 配置パターン（ストーリーシーン用）
enum StoryLayout: String, CaseIterable, Identifiable {
    case sideBySide = "並んで歩く"
    case faceToFace = "向かい合う（テーブル）"
    case centerListener = "中央で話す"
    case custom = "カスタム"

    var id: String { rawValue }

    var englishValue: String {
        switch self {
        case .sideBySide: return "Side by Side (Walking)"
        case .faceToFace: return "Face to Face (Table)"
        case .centerListener: return "Center & Listener"
        case .custom: return "custom"
        }
    }
}

// MARK: - Story Distance
/// 距離感（ストーリーシーン用）
enum StoryDistance: String, CaseIterable, Identifiable {
    case close = "親しい"
    case normal = "普通"
    case distant = "遠い"

    var id: String { rawValue }

    var englishValue: String {
        switch self {
        case .close: return "Close Friends"
        case .normal: return "Normal"
        case .distant: return "Distant"
        }
    }
}

// MARK: - Lighting Mood
/// 雰囲気（ストーリーシーン用）
enum LightingMood: String, CaseIterable, Identifiable {
    case morning = "朝の光"
    case sunset = "夕焼け"
    case summerNoon = "夏の正午"
    case night = "夜"
    case custom = "カスタム"

    var id: String { rawValue }

    var englishValue: String {
        switch self {
        case .morning: return "Morning Sunlight"
        case .sunset: return "Sunset"
        case .summerNoon: return "Summer Noon"
        case .night: return "Night"
        case .custom: return "custom"
        }
    }
}

// MARK: - Character Count (Story)
/// キャラクター人数（ストーリーシーン用）
enum CharacterCount: String, CaseIterable, Identifiable {
    case one = "1人"
    case two = "2人"
    case three = "3人"
    case four = "4人"
    case five = "5人"

    var id: String { rawValue }

    var intValue: Int {
        switch self {
        case .one: return 1
        case .two: return 2
        case .three: return 3
        case .four: return 4
        case .five: return 5
        }
    }
}

// MARK: - Text Overlay Layer
/// 装飾テキストレイヤー
enum TextOverlayLayer: String, CaseIterable, Identifiable {
    case frontmost = "最前面"
    case behindCharacters = "キャラの後ろ"
    case aboveBackground = "背景の前"

    var id: String { rawValue }

    var englishValue: String {
        switch self {
        case .frontmost: return "Frontmost (Above Characters)"
        case .behindCharacters: return "Behind Characters"
        case .aboveBackground: return "Above Background Only"
        }
    }
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

    var description: String {
        switch self {
        case .skillName: return "画面にドンと出る技名・必殺技名"
        case .catchphrase: return "キャラの横に出る派手なセリフ・掛け声"
        case .namePlate: return "キャラクターの名前表示プレート"
        case .messageWindow: return "画面下部のセリフウィンドウ（RPG/ADV風）"
        }
    }

    var placeholder: String {
        switch self {
        case .skillName: return "真空ビーム"
        case .catchphrase: return "もらったー！"
        case .namePlate: return "篠宮りん"
        case .messageWindow: return "「もらったー」"
        }
    }
}

// MARK: - 技名テロップ用
/// 技名フォント
enum TitleFont: String, CaseIterable, Identifiable {
    case heavyMincho = "極太明朝"
    case brush = "筆文字"
    case gothic = "ゴシック"

    var id: String { rawValue }
}

/// 技名サイズ
enum TitleSize: String, CaseIterable, Identifiable {
    case veryLarge = "特大"
    case large = "大"
    case medium = "中"

    var id: String { rawValue }
}

/// グラデーション色
enum GradientColor: String, CaseIterable, Identifiable {
    case whiteToBlue = "白→青"
    case whiteToRed = "白→赤"
    case goldToOrange = "金→オレンジ"
    case whiteToPurple = "白→紫"
    case solidWhite = "単色白"
    case solidGold = "単色金"

    var id: String { rawValue }
}

/// 縁取り色
enum OutlineColor: String, CaseIterable, Identifiable {
    case gold = "金"
    case black = "黒"
    case red = "赤"
    case blue = "青"
    case none = "なし"

    var id: String { rawValue }
}

/// 発光エフェクト
enum GlowEffect: String, CaseIterable, Identifiable {
    case none = "なし"
    case blueLightning = "青い稲妻"
    case fire = "炎"
    case electric = "電撃"
    case aura = "オーラ"

    var id: String { rawValue }
}

// MARK: - 決め台詞用
/// 決め台詞タイプ
enum CalloutType: String, CaseIterable, Identifiable {
    case comic = "書き文字風"
    case verticalShout = "縦書き叫び"
    case pop = "ポップ体"

    var id: String { rawValue }
}

/// 決め台詞配色
enum CalloutColor: String, CaseIterable, Identifiable {
    case redYellow = "赤＋黄縁"
    case whiteBlack = "白＋黒縁"
    case blueWhite = "青＋白縁"
    case yellowRed = "黄＋赤縁"

    var id: String { rawValue }
}

/// 回転角度（決め台詞・キャラ名共通）
enum TextRotation: String, CaseIterable, Identifiable {
    case none = "なし"
    case slightLeft = "少し左傾き"
    case left = "左傾き"
    case slightRight = "少し右傾き"
    case right = "右傾き"

    var id: String { rawValue }
}

/// 変形効果
enum TextDistortion: String, CaseIterable, Identifiable {
    case none = "なし"
    case zoomIn = "飛び出し"
    case zoomOut = "縮小"
    case wave = "波打ち"

    var id: String { rawValue }
}

// MARK: - キャラ名プレート用
/// キャラ名プレートデザイン
enum NameTagDesign: String, CaseIterable, Identifiable {
    case jagged = "ギザギザステッカー"
    case simple = "シンプル枠"
    case ribbon = "リボン"

    var id: String { rawValue }
}

// MARK: - メッセージウィンドウ用
/// メッセージウィンドウモード
enum MessageWindowMode: String, CaseIterable, Identifiable {
    case full = "フルスペック"
    case faceOnly = "顔アイコンのみ"
    case textOnly = "セリフのみ"

    var id: String { rawValue }
}

/// メッセージウィンドウスタイル
enum MessageWindowStyle: String, CaseIterable, Identifiable {
    case sciFi = "SF・ロボット風"
    case retroRPG = "レトロRPG風"
    case visualNovel = "ビジュアルノベル風"

    var id: String { rawValue }
}

/// メッセージウィンドウ枠デザイン
enum MessageFrameType: String, CaseIterable, Identifiable {
    case cyberneticBlue = "サイバネティック青"
    case classicBlack = "クラシック黒"
    case translucentWhite = "半透明白"
    case goldOrnate = "ゴールド装飾"

    var id: String { rawValue }
}

/// 顔アイコン位置
enum FaceIconPosition: String, CaseIterable, Identifiable {
    case leftInside = "左内側"
    case rightInside = "右内側"
    case leftOutside = "左外側"
    case none = "なし"

    var id: String { rawValue }
}

// MARK: - ===========================================
// MARK: - 4コマ漫画関連
// MARK: - ===========================================

// MARK: - Speech Character
/// セリフを言うキャラクター
enum SpeechCharacter: String, CaseIterable, Identifiable {
    case character1 = "キャラ1"
    case character2 = "キャラ2"
    case none = "（なし）"

    var id: String { rawValue }
}

// MARK: - Speech Position
/// セリフの位置
enum SpeechPosition: String, CaseIterable, Identifiable {
    case left = "左"
    case right = "右"

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

// MARK: - Chibi Style
/// ちびキャラスタイル（Python版準拠）
enum ChibiStyle: String, CaseIterable, Identifiable {
    case standard = "スタンダード（2頭身）"
    case deformed = "デフォルメ（1.5頭身）"
    case miniChara = "ミニキャラ（3頭身）"
    case puchi = "ぷちキャラ（まるっこい）"

    var id: String { rawValue }

    /// YAML用プロンプト
    var prompt: String {
        switch self {
        case .standard:
            return "2-head-tall chibi style, super deformed, cute big head, small body"
        case .deformed:
            return "1.5-head-tall extreme chibi, very large head, tiny body, maximum cute"
        case .miniChara:
            return "3-head-tall mini character style, moderately deformed, cute proportions"
        case .puchi:
            return "puchi chara style, round soft shapes, blob-like cute, simplified features"
        }
    }

    /// 頭身比
    var headRatio: String {
        switch self {
        case .standard: return "2:1"
        case .deformed: return "1.5:1"
        case .miniChara: return "3:1"
        case .puchi: return "2:1"
        }
    }
}

// MARK: - Pixel Style
/// ドットスタイル（Python版準拠）
enum PixelStyle: String, CaseIterable, Identifiable {
    case bit8 = "8bit風（ファミコン）"
    case bit16 = "16bit風（スーファミ）"
    case bit32 = "32bit風（PS1/SS）"
    case gba = "GBA風"
    case modern = "モダンピクセル"

    var id: String { rawValue }

    /// YAML用プロンプト
    var prompt: String {
        switch self {
        case .bit8:
            return "8-bit pixel art style, NES/Famicom era, limited color palette, chunky pixels"
        case .bit16:
            return "16-bit pixel art style, SNES/Super Famicom era, vibrant colors, detailed sprites"
        case .bit32:
            return "32-bit pixel art style, PlayStation/Saturn era, high detail sprites, rich colors"
        case .gba:
            return "GBA pixel art style, Game Boy Advance era, portable game aesthetic"
        case .modern:
            return "modern pixel art style, indie game aesthetic, clean sharp pixels, contemporary"
        }
    }

    /// 解像度
    var resolution: String {
        switch self {
        case .bit8: return "low"
        case .bit16: return "medium"
        case .bit32: return "high"
        case .gba: return "medium"
        case .modern: return "high"
        }
    }

    /// 色数
    var colors: String {
        switch self {
        case .bit8: return "16"
        case .bit16: return "256"
        case .bit32: return "full"
        case .gba: return "256"
        case .modern: return "full"
        }
    }
}

// MARK: - Sprite Size
/// スプライトサイズ（Python版準拠）
enum SpriteSize: String, CaseIterable, Identifiable {
    case size16 = "16x16"
    case size32 = "32x32"
    case size64 = "64x64"
    case size128 = "128x128"
    case size256 = "256x256"

    var id: String { rawValue }

    /// YAML用プロンプト
    var prompt: String {
        switch self {
        case .size16:
            return "16x16 pixel sprite, very small, icon-sized"
        case .size32:
            return "32x32 pixel sprite, small game sprite size"
        case .size64:
            return "64x64 pixel sprite, medium detailed sprite"
        case .size128:
            return "128x128 pixel sprite, large detailed sprite"
        case .size256:
            return "256x256 pixel sprite, high detail sprite art"
        }
    }
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

// MARK: - Infographic Language
/// インフォグラフィック出力言語（Python版準拠 + その他）
enum InfographicLanguage: String, CaseIterable, Identifiable {
    case japanese = "日本語"
    case english = "English"
    case chineseSimplified = "中文（简体）"
    case chineseTraditional = "中文（繁體）"
    case korean = "한국어"
    case spanish = "Español"
    case french = "Français"
    case german = "Deutsch"
    case other = "その他"

    var id: String { rawValue }
}
