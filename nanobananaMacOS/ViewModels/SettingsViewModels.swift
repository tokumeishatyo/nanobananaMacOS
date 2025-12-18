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
/// シーンビルダー設定ViewModel
@MainActor
final class SceneBuilderSettingsViewModel: ObservableObject {
    @Published var sceneType: SceneType = .battle
    @Published var backgroundImagePath: String = ""
    @Published var backgroundDescription: String = ""

    // バトルシーン用
    @Published var leftCharacterImagePath: String = ""
    @Published var leftCharacterName: String = ""
    @Published var rightCharacterImagePath: String = ""
    @Published var rightCharacterName: String = ""
    @Published var battleAdvantage: String = "互角"

    // ストーリーシーン用
    @Published var character1ImagePath: String = ""
    @Published var character1Expression: CharacterExpression = .neutral
    @Published var character2ImagePath: String = ""
    @Published var character2Expression: CharacterExpression = .neutral
    @Published var character3ImagePath: String = ""
    @Published var character3Expression: CharacterExpression = .neutral
    @Published var layoutStyle: String = "並んで歩く"
    @Published var dialogues: [String] = ["", "", ""]
}

// MARK: - Background Settings ViewModel
/// 背景生成設定ViewModel
@MainActor
final class BackgroundSettingsViewModel: ObservableObject {
    @Published var backgroundPreset: BackgroundPreset = .custom
    @Published var customDescription: String = ""
    @Published var useReferenceImage: Bool = false
    @Published var referenceImagePath: String = ""
    @Published var transformInstruction: String = ""
    @Published var removeCharacters: Bool = true
}

// MARK: - Decorative Text Settings ViewModel
/// 装飾テキスト設定ViewModel
@MainActor
final class DecorativeTextSettingsViewModel: ObservableObject {
    @Published var textType: DecorativeTextType = .skillName
    @Published var mainText: String = ""
    @Published var subText: String = ""

    // 技名テロップ用
    @Published var fontStyle: String = "極太明朝"
    @Published var fontSize: String = "特大"
    @Published var gradientStyle: String = "白→青"
    @Published var borderStyle: String = "金"
    @Published var glowEffect: String = "青い稲妻"

    // メッセージウィンドウ用
    @Published var characterName: String = ""
    @Published var faceIconImagePath: String = ""
    @Published var windowStyle: String = "フルスペック"
}

// MARK: - Four Panel Manga Settings ViewModel
/// 4コマ漫画設定ViewModel
@MainActor
final class FourPanelSettingsViewModel: ObservableObject {
    @Published var character1Name: String = ""
    @Published var character1Description: String = ""
    @Published var character1ImagePath: String = ""

    @Published var character2Name: String = ""
    @Published var character2Description: String = ""
    @Published var character2ImagePath: String = ""

    // 各コマの内容
    @Published var panel1Content: String = ""
    @Published var panel2Content: String = ""
    @Published var panel3Content: String = ""
    @Published var panel4Content: String = ""

    // 各コマのセリフ
    @Published var panel1Dialogue: String = ""
    @Published var panel2Dialogue: String = ""
    @Published var panel3Dialogue: String = ""
    @Published var panel4Dialogue: String = ""
}

// MARK: - Style Transform Settings ViewModel
/// スタイル変換設定ViewModel
@MainActor
final class StyleTransformSettingsViewModel: ObservableObject {
    @Published var sourceImagePath: String = ""
    @Published var transformType: StyleTransformType = .chibi

    // ちびキャラ化用
    @Published var chibiStyle: String = "スタンダード(2頭身)"
    @Published var keepOutfit: Bool = true
    @Published var keepPose: Bool = true

    // ドットキャラ化用
    @Published var pixelStyle: String = "16bit風"
    @Published var spriteSize: String = "64x64"
    @Published var keepColors: Bool = true
}

// MARK: - Infographic Settings ViewModel
/// インフォグラフィック設定ViewModel
@MainActor
final class InfographicSettingsViewModel: ObservableObject {
    @Published var infographicStyle: InfographicStyle = .graphicRecording
    @Published var mainTitle: String = ""
    @Published var subtitle: String = ""
    @Published var mainCharacterImagePath: String = ""
    @Published var subCharacterImagePath: String = ""
    @Published var outputLanguage: String = "日本語"

    // セクション（最大8つ）
    @Published var sections: [InfographicSection] = [
        InfographicSection(),
        InfographicSection(),
        InfographicSection()
    ]
}

/// インフォグラフィックセクション
struct InfographicSection: Identifiable {
    let id = UUID()
    var title: String = ""
    var content: String = ""
    var position: Int = 0 // 0 = おまかせ
}
