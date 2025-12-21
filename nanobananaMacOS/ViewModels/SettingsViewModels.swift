// rule.mdを読むこと
import Foundation
import SwiftUI
import Combine

// MARK: - Face Sheet Settings ViewModel
/// 顔三面図設定ViewModel
/// ※スタイルはメイン画面で一元管理（各ステップでは設定しない）
@MainActor
final class FaceSheetSettingsViewModel: ObservableObject {
    @Published var characterName: String = ""
    @Published var referenceImagePath: String = ""
    @Published var appearanceDescription: String = ""

    var placeholderText: String {
        """
        例：
        ・ショートボブの茶髪
        ・大きな青い瞳
        ・元気な笑顔
        ・左頬にホクロ
        """
    }
}

// MARK: - Body Sheet Settings ViewModel
/// 素体三面図設定ViewModel
/// ※スタイルはメイン画面で一元管理（各ステップでは設定しない）
@MainActor
final class BodySheetSettingsViewModel: ObservableObject {
    @Published var faceSheetImagePath: String = ""
    @Published var bodyTypePreset: BodyTypePreset = .femalStandard
    @Published var bustFeature: BustFeature = .auto
    @Published var bodyRenderType: BodyRenderType = .whiteLeotard
    @Published var additionalDescription: String = ""
}

// MARK: - Outfit Settings ViewModel
/// 衣装設定ViewModel
/// ※スタイルはメイン画面で一元管理（各ステップでは設定しない）
@MainActor
final class OutfitSettingsViewModel: ObservableObject {
    @Published var bodySheetImagePath: String = ""
    @Published var useOutfitBuilder: Bool = true

    // プリセット衣装
    @Published var outfitCategory: OutfitCategory = .casual {
        didSet {
            // カテゴリ変更時に形状をリセット
            if !outfitCategory.shapes.contains(outfitShape) {
                outfitShape = "おまかせ"
            }
        }
    }
    @Published var outfitShape: String = "おまかせ"
    @Published var outfitColor: OutfitColor = .auto
    @Published var outfitPattern: OutfitPattern = .auto
    @Published var outfitStyle: OutfitFashionStyle = .auto

    // 参考画像から
    @Published var referenceOutfitImagePath: String = ""
    @Published var referenceDescription: String = ""
    @Published var fitMode: String = "素体優先"
    @Published var includeHeadwear: Bool = true

    // 追加説明
    @Published var additionalDescription: String = ""
}

// MARK: - Pose Settings ViewModel
/// ポーズ設定ViewModel（Python版準拠）
@MainActor
final class PoseSettingsViewModel: ObservableObject {
    // ポーズプリセット
    @Published var selectedPreset: PosePreset = .none {
        didSet {
            // プリセット選択時に動作説明と風効果を自動入力
            if selectedPreset != .none {
                actionDescription = selectedPreset.description
                windEffect = selectedPreset.defaultWindEffect
            }
        }
    }
    @Published var usePoseCapture: Bool = false
    @Published var poseReferenceImagePath: String = ""

    // 入力画像（衣装着用三面図）
    @Published var outfitSheetImagePath: String = ""
    // 注: 顔・衣装の同一性は常に保持（固定）

    // 向き・表情
    @Published var eyeLine: EyeLine = .front
    @Published var expression: PoseExpression = .neutral
    @Published var expressionDetail: String = ""

    // 動作説明
    @Published var actionDescription: String = ""

    // ビジュアル効果
    @Published var includeEffects: Bool = false
    @Published var transparentBackground: Bool = true
    @Published var windEffect: WindEffect = .none
}

// MARK: - Scene Builder Settings ViewModel
/// シーンビルダー設定ViewModel（Python版準拠）
@MainActor
final class SceneBuilderSettingsViewModel: ObservableObject {
    // シーンタイプ（デフォルト: ストーリーシーン）
    @Published var sceneType: SceneType = .story

    // === 共通: 背景設定 ===
    @Published var backgroundSourceType: BackgroundSourceType = .file
    @Published var backgroundImagePath: String = ""
    @Published var backgroundDescription: String = ""

    // === バトルシーン用 ===
    // 背景
    @Published var battleDimming: Double = 0.5

    // カットイン演出
    @Published var leftCutinEnabled: Bool = true
    @Published var leftCutinImagePath: String = ""
    @Published var leftCutinBlendMode: BlendMode = .add
    @Published var rightCutinEnabled: Bool = true
    @Published var rightCutinImagePath: String = ""
    @Published var rightCutinBlendMode: BlendMode = .add

    // 衝突設定
    @Published var collisionType: CollisionType = .centerClash
    @Published var dominantSide: DominantSide = .even
    @Published var borderVFX: BorderVFX = .sparksLightning

    // キャラクター配置（左）
    @Published var battleLeftCharImagePath: String = ""
    @Published var battleLeftCharScale: String = "1.2"
    @Published var battleLeftCharName: String = ""
    @Published var battleLeftCharTraits: String = ""

    // キャラクター配置（右）
    @Published var battleRightCharImagePath: String = ""
    @Published var battleRightCharScale: String = "1.2"
    @Published var battleRightCharName: String = ""
    @Published var battleRightCharTraits: String = ""

    // 画面効果
    @Published var screenShake: ScreenShake = .heavy
    @Published var showUI: Bool = true

    // === ストーリーシーン用 ===
    // 背景
    @Published var storyBlurAmount: Double = 10
    @Published var storyLightingMood: LightingMood = .morning
    @Published var storyCustomMood: String = ""

    // 配置設定
    @Published var storyLayout: StoryLayout = .sideBySide
    @Published var storyCustomLayout: String = ""
    @Published var storyDistance: StoryDistance = .close

    // キャラクター配置（動的、最大5人）
    @Published var storyCharacterCount: CharacterCount = .two
    @Published var storyCharacters: [StoryCharacter] = [
        StoryCharacter(),
        StoryCharacter(),
        StoryCharacter(),
        StoryCharacter(),
        StoryCharacter()
    ]

    // ダイアログ設定
    @Published var storyNarration: String = ""
    @Published var storyDialogues: [String] = ["", "", "", "", ""]

    // === ボスレイド用 ===
    // ボス設定
    @Published var bossImagePath: String = ""
    @Published var bossScale: String = "2.5"
    @Published var bossAllowCrop: Bool = true

    // パーティメンバー（3人）
    @Published var partyMembers: [PartyMember] = [
        PartyMember(),
        PartyMember(),
        PartyMember()
    ]
    @Published var partyBaseScale: String = "0.6"

    // 集中砲火エフェクト
    @Published var convergenceEnabled: Bool = true
    @Published var beamColor: String = "Blue & Pink Lasers"

    // === 共通: 装飾テキストオーバーレイ ===
    @Published var textOverlayItems: [TextOverlayItem] = []
    @Published var showTextOverlaySheet: Bool = false
}

/// ストーリーシーン用キャラクターデータ
struct StoryCharacter: Identifiable {
    let id = UUID()
    var imagePath: String = ""
    var expression: String = ""
    var traits: String = ""
}

/// ボスレイド用パーティメンバーデータ
struct PartyMember: Identifiable {
    let id = UUID()
    var imagePath: String = ""
    var action: String = ""
}

/// 装飾テキストオーバーレイアイテム（最大10個）
struct TextOverlayItem: Identifiable {
    let id = UUID()
    var imagePath: String = ""
    var position: String = "Center"
    var size: String = "100%"
    var layer: TextOverlayLayer = .frontmost
}

// MARK: - Background Settings ViewModel
/// 背景生成設定ViewModel（シンプル版）
/// - 参考画像なし: descriptionに生成したい背景を記述
/// - 参考画像あり: descriptionに変形指示（空欄→アニメ調変換）
@MainActor
final class BackgroundSettingsViewModel: ObservableObject {
    @Published var useReferenceImage: Bool = false
    @Published var referenceImagePath: String = ""
    @Published var removeCharacters: Bool = true
    @Published var description: String = ""
}

// MARK: - Decorative Text Settings ViewModel
/// 装飾テキスト設定ViewModel（Python版準拠）
@MainActor
final class DecorativeTextSettingsViewModel: ObservableObject {
    // 共通
    @Published var textType: DecorativeTextType = .skillName
    @Published var text: String = ""
    @Published var transparentBackground: Bool = true

    // 技名テロップ用
    @Published var titleFont: TitleFont = .heavyMincho
    @Published var titleSize: TitleSize = .veryLarge
    @Published var titleColor: GradientColor = .whiteToBlue
    @Published var titleOutline: OutlineColor = .gold
    @Published var titleGlow: GlowEffect = .blueLightning
    @Published var titleShadow: Bool = true

    // 決め台詞用
    @Published var calloutType: CalloutType = .comic
    @Published var calloutColor: CalloutColor = .redYellow
    @Published var calloutRotation: TextRotation = .left
    @Published var calloutDistortion: TextDistortion = .zoomIn

    // キャラ名プレート用
    @Published var nameTagDesign: NameTagDesign = .jagged
    @Published var nameTagRotation: TextRotation = .slightLeft

    // メッセージウィンドウ用
    @Published var messageMode: MessageWindowMode = .full
    @Published var speakerName: String = ""
    @Published var messageStyle: MessageWindowStyle = .sciFi
    @Published var messageFrameType: MessageFrameType = .cyberneticBlue
    @Published var messageOpacity: Double = 0.8
    @Published var faceIconPosition: FaceIconPosition = .leftInside
    @Published var faceIconImagePath: String = ""
}

// MARK: - Four Panel Manga Settings ViewModel
/// 4コマ漫画設定ViewModel（Python版準拠）
@MainActor
final class FourPanelSettingsViewModel: ObservableObject {
    // キャラクター1
    @Published var character1Name: String = ""
    @Published var character1Description: String = ""
    @Published var character1ImagePath: String = ""

    // キャラクター2（任意）
    @Published var character2Name: String = ""
    @Published var character2Description: String = ""
    @Published var character2ImagePath: String = ""

    // 4コマ分のパネルデータ
    @Published var panels: [MangaPanelData] = [
        MangaPanelData(),
        MangaPanelData(),
        MangaPanelData(),
        MangaPanelData()
    ]
}

/// 4コマ漫画の1コマ分のデータ
/// classにすることで、プロパティ変更時に配列全体の再発行を防ぐ
final class MangaPanelData: ObservableObject, Identifiable {
    let id = UUID()
    @Published var scene: String = ""           // シーン説明
    @Published var speech1Char: SpeechCharacter = .character1
    @Published var speech1Text: String = ""
    @Published var speech1Position: SpeechPosition = .left
    @Published var speech2Char: SpeechCharacter = .none
    @Published var speech2Text: String = ""
    @Published var speech2Position: SpeechPosition = .right
    @Published var narration: String = ""       // ナレーション
}

// MARK: - Style Transform Settings ViewModel
/// スタイル変換設定ViewModel
@MainActor
final class StyleTransformSettingsViewModel: ObservableObject {
    @Published var sourceImagePath: String = ""
    @Published var transformType: StyleTransformType = .chibi

    // ちびキャラ化用
    @Published var chibiStyle: ChibiStyle = .standard
    @Published var keepOutfit: Bool = true
    @Published var keepPose: Bool = true

    // ドットキャラ化用
    @Published var pixelStyle: PixelStyle = .bit16
    @Published var spriteSize: SpriteSize = .size64
    @Published var keepColors: Bool = true

    // 共通
    @Published var transparentBackground: Bool = true
}

// MARK: - Infographic Settings ViewModel
/// インフォグラフィック設定ViewModel
@MainActor
final class InfographicSettingsViewModel: ObservableObject {
    @Published var infographicStyle: InfographicStyle = .graphicRecording
    @Published var outputLanguage: InfographicLanguage = .japanese
    @Published var customLanguage: String = ""  // 「その他」選択時の手入力
    @Published var mainTitle: String = ""
    @Published var subtitle: String = ""
    @Published var mainCharacterImagePath: String = ""
    @Published var subCharacterImagePath: String = ""

    // セクション（最大8つ）
    @Published var sections: [InfographicSection] = (1...8).map { InfographicSection(position: $0) }
}

/// インフォグラフィックセクション
struct InfographicSection: Identifiable {
    let id = UUID()
    var title: String = ""
    var content: String = ""
    let position: Int // 固定位置（1-8）
}
