import Foundation

/// 衣装三面図YAML生成（Python版_generate_outfit_yaml準拠）
final class OutfitSheetYAMLGenerator {

    // MARK: - Outfit Prompt Data (Python版OUTFIT_DATAに準拠)

    /// カテゴリプロンプト
    private let categoryPrompts: [String: String] = [
        "おまかせ": "",
        "モデル用": "simple clothing for character model sheet",
        "スーツ": "business suit",
        "水着": "swimsuit",
        "カジュアル": "casual wear",
        "制服": "uniform",
        "ドレス/フォーマル": "formal wear",
        "スポーツ": "sportswear",
        "和服": "japanese traditional clothing",
        "作業着/職業服": "work uniform"
    ]

    /// 形状プロンプト（カテゴリ別）
    private let shapePrompts: [String: [String: String]] = [
        "モデル用": [
            "おまかせ": "",
            "白レオタード": "white leotard, simple, tight-fitting, full body visible",
            "グレーレオタード": "gray leotard, simple, tight-fitting, full body visible",
            "黒レオタード": "black leotard, simple, tight-fitting, full body visible",
            "白下着": "white underwear, simple bra and panties, minimal clothing",
            "Tシャツ+短パン": "simple gray t-shirt and shorts, casual, body shape visible",
            "タンクトップ+短パン": "white tank top and shorts, simple, body shape visible"
        ],
        "スーツ": [
            "おまかせ": "",
            "パンツスタイル": "pant suit, trousers",
            "タイトスカート": "pencil skirt",
            "プリーツスカート": "pleated skirt",
            "ミニスカート": "mini skirt suit",
            "スリーピース": "three-piece suit, vest",
            "ダブルスーツ": "double-breasted suit",
            "タキシード": "tuxedo, formal suit"
        ],
        "水着": [
            "おまかせ": "",
            "三角ビキニ": "triangle bikini",
            "ホルターネック": "halter neck bikini",
            "バンドゥ": "bandeau bikini",
            "ワンピース": "one-piece swimsuit",
            "ハイレグ": "high-leg swimsuit",
            "パレオ付き": "bikini with pareo",
            "サーフパンツ": "surf shorts, board shorts",
            "競泳パンツ": "racing briefs, speedo"
        ],
        "カジュアル": [
            "おまかせ": "",
            "Tシャツ+デニム": "t-shirt and denim jeans",
            "ワンピース": "casual dress",
            "ブラウス+スカート": "blouse and skirt",
            "パーカー": "hoodie",
            "カーディガン": "cardigan outfit",
            "シャツ+チノパン": "button-down shirt and chinos",
            "ポロシャツ": "polo shirt",
            "レザージャケット": "leather jacket"
        ],
        "制服": [
            "おまかせ": "",
            "セーラー服": "sailor uniform",
            "ブレザー": "blazer uniform",
            "メイド服": "maid uniform",
            "ナース服": "nurse uniform",
            "OL制服": "office lady uniform",
            "学ラン": "gakuran, japanese male school uniform",
            "詰襟": "standing collar uniform",
            "警察官": "police uniform",
            "軍服": "military uniform"
        ],
        "ドレス/フォーマル": [
            "おまかせ": "",
            "イブニングドレス": "evening gown",
            "カクテルドレス": "cocktail dress",
            "ウェディングドレス": "wedding dress",
            "チャイナドレス": "chinese dress, cheongsam",
            "サマードレス": "summer dress",
            "タキシード": "tuxedo",
            "モーニング": "morning coat, formal suit",
            "燕尾服": "tailcoat, white tie"
        ],
        "スポーツ": [
            "おまかせ": "",
            "テニスウェア": "tennis wear",
            "体操服": "gym uniform",
            "レオタード": "leotard",
            "ヨガウェア": "yoga wear",
            "競泳水着": "racing swimsuit",
            "サッカーユニフォーム": "soccer jersey, football kit",
            "野球ユニフォーム": "baseball uniform",
            "バスケユニフォーム": "basketball jersey",
            "柔道着": "judo gi, martial arts uniform"
        ],
        "和服": [
            "おまかせ": "",
            "着物": "kimono",
            "浴衣": "yukata",
            "振袖": "furisode",
            "巫女服": "miko outfit, shrine maiden",
            "袴": "hakama",
            "紋付袴": "montsuki hakama, formal male kimono",
            "羽織": "haori jacket",
            "甚平": "jinbei, japanese casual wear"
        ],
        "作業着/職業服": [
            "おまかせ": "",
            "白衣": "white lab coat, doctor coat",
            "作業着": "work overalls, coveralls",
            "シェフコート": "chef coat, chef uniform",
            "消防服": "firefighter uniform",
            "建設作業員": "construction worker outfit, hard hat"
        ]
    ]

    /// カラープロンプト
    private let colorPrompts: [String: String] = [
        "おまかせ": "",
        "黒": "black",
        "白": "white",
        "紺": "navy blue",
        "赤": "red",
        "ピンク": "pink",
        "青": "blue",
        "水色": "light blue",
        "緑": "green",
        "黄": "yellow",
        "オレンジ": "orange",
        "紫": "purple",
        "ベージュ": "beige",
        "グレー": "gray",
        "ゴールド": "gold",
        "シルバー": "silver"
    ]

    /// 柄プロンプト
    private let patternPrompts: [String: String] = [
        "おまかせ": "",
        "無地": "solid color, plain",
        "ストライプ": "striped",
        "チェック": "checkered, plaid",
        "花柄": "floral pattern",
        "ドット": "polka dot",
        "ボーダー": "horizontal stripes",
        "トロピカル": "tropical pattern, hibiscus",
        "レース": "lace",
        "迷彩": "camouflage",
        "アニマル柄": "animal print, leopard"
    ]

    /// スタイル（印象）プロンプト
    private let stylePrompts: [String: String] = [
        "おまかせ": "",
        "大人っぽい": "mature, sophisticated",
        "可愛い": "cute, kawaii",
        "セクシー": "sexy, alluring",
        "クール": "cool, stylish",
        "清楚": "elegant, modest",
        "スポーティ": "sporty, athletic",
        "ゴージャス": "gorgeous, glamorous",
        "ワイルド": "wild, rugged",
        "知的": "intellectual, smart",
        "ダンディ": "dandy, gentlemanly",
        "カジュアル": "casual, relaxed"
    ]

    // MARK: - Outfit Prompt Generation

    /// 衣装プロンプトを生成（Python版generate_outfit_prompt準拠）
    private func generateOutfitPrompt(
        category: String,
        shape: String,
        color: String,
        pattern: String,
        style: String
    ) -> String {
        if category == "おまかせ" {
            return ""
        }

        var parts: [String] = []

        // Color
        if color != "おまかせ", let colorPrompt = colorPrompts[color], !colorPrompt.isEmpty {
            parts.append(colorPrompt)
        }

        // Pattern
        if pattern != "おまかせ", let patternPrompt = patternPrompts[pattern], !patternPrompt.isEmpty {
            parts.append(patternPrompt)
        }

        // Shape
        if shape != "おまかせ",
           let categoryShapes = shapePrompts[category],
           let shapePrompt = categoryShapes[shape],
           !shapePrompt.isEmpty {
            parts.append(shapePrompt)
        } else if let categoryPrompt = categoryPrompts[category], !categoryPrompt.isEmpty {
            parts.append(categoryPrompt)
        }

        // Style
        if style != "おまかせ", let stylePrompt = stylePrompts[style], !stylePrompt.isEmpty {
            parts.append(stylePrompt)
        }

        return parts.joined(separator: ", ")
    }

    // MARK: - Generate

    /// 衣装三面図YAMLを生成
    @MainActor
    func generate(mainViewModel: MainViewModel, settings: OutfitSettingsViewModel) -> String {
        let title = mainViewModel.title.isEmpty ? "Outfit Reference Sheet" : mainViewModel.title
        let author = mainViewModel.authorName.isEmpty ? "Unknown" : mainViewModel.authorName

        // 素体三面図パス
        let bodySheetFileName = YAMLUtilities.getFileName(from: settings.bodySheetImagePath)
        let bodySheetValue = bodySheetFileName.isEmpty ? "REQUIRED" : bodySheetFileName

        // スタイル情報
        let styleInfo = YAMLUtilities.getCharacterStyleInfo(mainViewModel.selectedOutputStyle)
        let colorModeValue = YAMLUtilities.getColorModeValue(mainViewModel.selectedColorMode)

        // 追加説明
        let additionalDesc = YAMLUtilities.convertNewlinesToComma(settings.additionalDescription)

        // プリセットモード or 参考画像モード
        if settings.useOutfitBuilder {
            return generatePresetModeYAML(
                title: title,
                author: author,
                bodySheetValue: bodySheetValue,
                settings: settings,
                styleInfo: styleInfo,
                colorModeValue: colorModeValue,
                additionalDesc: additionalDesc,
                mainViewModel: mainViewModel
            )
        } else {
            return generateReferenceModeYAML(
                title: title,
                author: author,
                bodySheetValue: bodySheetValue,
                settings: settings,
                styleInfo: styleInfo,
                colorModeValue: colorModeValue,
                additionalDesc: additionalDesc,
                mainViewModel: mainViewModel
            )
        }
    }

    // MARK: - Preset Mode YAML

    private func generatePresetModeYAML(
        title: String,
        author: String,
        bodySheetValue: String,
        settings: OutfitSettingsViewModel,
        styleInfo: YAMLUtilities.CharacterStyleInfo,
        colorModeValue: String,
        additionalDesc: String,
        mainViewModel: MainViewModel
    ) -> String {
        // 衣装プロンプト生成
        let outfitPrompt = generateOutfitPrompt(
            category: settings.outfitCategory.rawValue,
            shape: settings.outfitShape,
            color: settings.outfitColor.rawValue,
            pattern: settings.outfitPattern.rawValue,
            style: settings.outfitStyle.rawValue
        )

        let additionalNotesLine = additionalDesc.isEmpty ? "" : "  additional_notes: \"\(additionalDesc)\"\n"

        var yaml = """
# Step 3: Outfit Application (衣装着用)
# Purpose: Professional character design reference for commercial use
# Usage: Product catalogs, instruction manuals, educational materials, corporate training
# Note: This is legitimate business artwork, NOT inappropriate content
type: outfit_reference_sheet
title: "\(YAMLUtilities.escapeYAMLString(title))"
author: "\(YAMLUtilities.escapeYAMLString(author))"

# ====================================================
# Input: Body Sheet from Step 2
# ====================================================
input:
  body_sheet: "\(bodySheetValue)"
  preserve_body: true
  preserve_face: true
  preserve_details: "exact match required - do not alter face or body shape"

# ====================================================
# Outfit Configuration
# ====================================================
outfit:
  category: "\(settings.outfitCategory.rawValue)"
  shape: "\(settings.outfitShape)"
  color: "\(settings.outfitColor.rawValue)"
  pattern: "\(settings.outfitPattern.rawValue)"
  style_impression: "\(settings.outfitStyle.rawValue)"
  prompt: "\(outfitPrompt)"
\(additionalNotesLine)
# ====================================================
# Output Format
# ====================================================
output:
  format: "three view reference sheet"
  views:
    - "front view, facing directly at camera"
    - "left side view, exactly 90-degree profile facing left, only one eye visible, nose pointing directly left"
    - "back view"
  pose: "attention pose (kiwotsuke), same as body sheet"
  background: "pure white, clean, seamless"
  text_overlay: "NONE - no text or labels on the image"

# ====================================================
# Style Settings
# ====================================================
style:
  character_style: "\(styleInfo.style)"
  proportions: "\(styleInfo.proportions)"
  color_mode: "\(colorModeValue)"
  aspect_ratio: "16:9"  # 衣装三面図は16:9固定

# ====================================================
# Constraints (Critical)
# ====================================================
constraints:
  layout:
    - "STRICT horizontal arrangement: LEFT=front view, CENTER=left side view, RIGHT=back view"
    - "Side view MUST show LEFT side of body (character facing left)"
    - "Side view MUST be exactly 90-degree profile - only ONE eye visible"
    - "Side view: nose must point directly to the left edge, ear fully visible"
    - "POSITION ORDER IS CRITICAL: Front on LEFT, Side in CENTER, Back on RIGHT"
    - "Each view should be clearly separated with white space"
  face_preservation:
    - "MUST use exact face from input body_sheet"
    - "Do NOT alter facial features, expression, or proportions"
    - "Maintain exact hair style and color from reference"
  body_preservation:
    - "MUST use exact body shape from input body_sheet"
    - "Do NOT alter body proportions or pose"
    - "Body should be visible through/under clothing naturally"
  outfit_application:
    - "Apply specified outfit to the body"
    - "Maintain clothing consistency across all three views"
    - "Show realistic fabric draping and fit"
  consistency:
    - "All three views must show the same character in same outfit"
    - "Maintain consistent proportions across views"
    - "Use clean linework suitable for reference"

anti_hallucination:
  - "Do NOT change the face from the body sheet reference"
  - "Do NOT alter body proportions"
  - "Do NOT add accessories not specified in outfit"
  - "Do NOT change hair style or color"
  - "Apply ONLY the specified outfit"
  - "Do NOT change the view order - ALWAYS front/side/back from left to right"
  - "Side view MUST NOT show both eyes - if both eyes are visible, it is NOT a correct 90-degree profile"

# ====================================================
# Output Cleanliness (CRITICAL)
# ====================================================
output_cleanliness:
  - "Output ONLY the character illustration - nothing else"
  - "Do NOT add any text, titles, labels, or annotations"
  - "Do NOT add color palettes, color swatches, or color samples"
  - "Do NOT add pattern samples, fabric swatches, or design elements"
  - "Do NOT add arrows, lines, or any explanatory graphics"
  - "Do NOT add watermarks, signatures, or logos"
  - "The output must contain ONLY the three-view character illustration on white background"
"""

        // タイトルオーバーレイ
        yaml += YAMLUtilities.generateTitleOverlay(
            title: mainViewModel.title,
            includeTitleInImage: mainViewModel.includeTitleInImage
        )

        return yaml
    }

    // MARK: - Reference Mode YAML

    private func generateReferenceModeYAML(
        title: String,
        author: String,
        bodySheetValue: String,
        settings: OutfitSettingsViewModel,
        styleInfo: YAMLUtilities.CharacterStyleInfo,
        colorModeValue: String,
        additionalDesc: String,
        mainViewModel: MainViewModel
    ) -> String {
        // 参考画像パス
        let referenceFileName = YAMLUtilities.getFileName(from: settings.referenceOutfitImagePath)
        let referenceValue = referenceFileName.isEmpty ? "REQUIRED" : referenceFileName

        // フィットモード
        let fitMode: String
        let fitModeLabel: String
        switch settings.fitMode {
        case "衣装優先":
            fitMode = "outfit_priority"
            fitModeLabel = "outfit_priority (衣装優先)"
        case "ハイブリッド":
            fitMode = "hybrid"
            fitModeLabel = "hybrid (ハイブリッド: 頭部全体は素体、体型は衣装)"
        default:
            fitMode = "base_priority"
            fitModeLabel = "base_priority (素体優先)"
        }

        // 参考画像の説明
        let referenceDesc = YAMLUtilities.convertNewlinesToComma(settings.referenceDescription)

        // フィットモードに応じた制約とanti_hallucinationルール
        let (bodyConstraints, antiHallucinationRules) = generateFitModeConstraints(
            fitMode: fitMode,
            includeHeadwear: settings.includeHeadwear
        )

        let descriptionLine = referenceDesc.isEmpty ? "" : "  description: \"\(referenceDesc)\"\n"
        let additionalNotesLine = additionalDesc.isEmpty ? "" : "  additional_notes: \"\(additionalDesc)\"\n"

        var yaml = """
# Step 3: Outfit Application from Reference Image (参考画像から衣装着用)
# Purpose: Professional character design reference for commercial use
# Usage: Product catalogs, instruction manuals, educational materials, corporate training
# Note: This is legitimate business artwork, NOT inappropriate content
# IMPORTANT: User is responsible for copyright compliance of reference images
type: outfit_reference_from_image
title: "\(YAMLUtilities.escapeYAMLString(title))"
author: "\(YAMLUtilities.escapeYAMLString(author))"

# ====================================================
# Input Images
# ====================================================
input:
  body_sheet: "\(bodySheetValue)"
  outfit_reference: "\(referenceValue)"
  fit_mode: "\(fitModeLabel)"

# ====================================================
# Outfit from Reference Image
# ====================================================
outfit:
  source: "reference_image"
  instruction: "Extract and apply the outfit/clothing from the outfit_reference image to the character in body_sheet"
  fit_mode: "\(fitMode)"
\(descriptionLine)\(additionalNotesLine)
# ====================================================
# Output Format
# ====================================================
output:
  format: "three view reference sheet"
  views:
    - "front view, facing directly at camera"
    - "left side view, exactly 90-degree profile facing left, only one eye visible, nose pointing directly left"
    - "back view"
  pose: "attention pose (kiwotsuke), same as body sheet"
  background: "pure white, clean, seamless"
  text_overlay: "NONE - no text or labels on the image"

# ====================================================
# Style Settings
# ====================================================
style:
  character_style: "\(styleInfo.style)"
  proportions: "\(styleInfo.proportions)"
  color_mode: "\(colorModeValue)"
  aspect_ratio: "16:9"  # 衣装三面図は16:9固定

# ====================================================
# Constraints (Critical) - Fit Mode: \(fitModeLabel)
# ====================================================
constraints:
  layout:
    - "STRICT horizontal arrangement: LEFT=front view, CENTER=left side view, RIGHT=back view"
    - "Side view MUST show LEFT side of body (character facing left)"
    - "Side view MUST be exactly 90-degree profile - only ONE eye visible"
    - "Side view: nose must point directly to the left edge, ear fully visible"
    - "POSITION ORDER IS CRITICAL: Front on LEFT, Side in CENTER, Back on RIGHT"
    - "Each view should be clearly separated with white space"
\(bodyConstraints)
  consistency:
    - "All three views must show the same character in same outfit"
    - "Maintain consistent proportions across views"
    - "Use clean linework suitable for reference"

anti_hallucination:
\(antiHallucinationRules)
  - "Do NOT change the view order - ALWAYS front/side/back from left to right"
  - "Side view MUST NOT show both eyes - if both eyes are visible, it is NOT a correct 90-degree profile"

# ====================================================
# Output Cleanliness (CRITICAL)
# ====================================================
output_cleanliness:
  - "Output ONLY the character illustration - nothing else"
  - "Do NOT add any text, titles, labels, or annotations"
  - "Do NOT add color palettes, color swatches, or color samples"
  - "Do NOT add pattern samples, fabric swatches, or design elements"
  - "Do NOT add arrows, lines, or any explanatory graphics"
  - "Do NOT add watermarks, signatures, or logos"
  - "The output must contain ONLY the three-view character illustration on white background"
"""

        // タイトルオーバーレイ
        yaml += YAMLUtilities.generateTitleOverlay(
            title: mainViewModel.title,
            includeTitleInImage: mainViewModel.includeTitleInImage
        )

        return yaml
    }

    // MARK: - Fit Mode Constraints

    private func generateFitModeConstraints(fitMode: String, includeHeadwear: Bool) -> (String, String) {
        switch fitMode {
        case "outfit_priority":
            return generateOutfitPriorityConstraints(includeHeadwear: includeHeadwear)
        case "hybrid":
            return generateHybridConstraints()
        default:
            return generateBasePriorityConstraints(includeHeadwear: includeHeadwear)
        }
    }

    private func generateBasePriorityConstraints(includeHeadwear: Bool) -> (String, String) {
        let headwearConstraint = includeHeadwear
            ? "    - \"Include headwear (hats, helmets, etc.) from outfit_reference if present\""
            : "    - \"EXCLUDE headwear (hats, helmets, caps, etc.) from outfit_reference\""

        let headwearAntiRule = includeHeadwear
            ? "  - \"Include headwear from outfit_reference - hats, helmets, caps should be applied\""
            : "  - \"Do NOT include any headwear from outfit_reference - no hats, helmets, or head accessories\""

        let bodyConstraints = """
  face_preservation:
    - "MUST use exact face from input body_sheet"
    - "Do NOT alter facial features, expression, or proportions"
    - "Maintain exact hair style and color from body_sheet reference"
  body_preservation:
    - "MUST use exact body shape from input body_sheet"
    - "Do NOT alter body proportions or pose"
    - "Body should be visible through/under clothing naturally"
  pose_preservation:
    - "MUST use the POSE from body_sheet (attention pose / kiwotsuke)"
    - "Do NOT copy the pose from outfit_reference image"
    - "Extract ONLY the clothing design, IGNORE the pose in reference"
  headwear:
\(headwearConstraint)
  outfit_extraction:
    - "Extract ONLY the clothing/outfit from the outfit_reference image"
    - "Do NOT copy the face or body from outfit_reference"
    - "Adapt the outfit to fit the body_sheet character's body shape"
    - "Maintain the style, color, and design of the reference outfit"
"""

        let antiRules = """
  - "Do NOT use face or body from outfit_reference image"
  - "Do NOT copy the POSE from outfit_reference - use body_sheet pose only"
  - "Do NOT alter body proportions from body_sheet"
  - "Do NOT add accessories not visible in outfit_reference"
  - "Do NOT change hair style or color from body_sheet"
  - "Apply ONLY the outfit visible in outfit_reference image"
\(headwearAntiRule)
"""

        return (bodyConstraints, antiRules)
    }

    private func generateOutfitPriorityConstraints(includeHeadwear: Bool) -> (String, String) {
        let headwearConstraint = includeHeadwear
            ? "    - \"Include headwear (hats, helmets, etc.) from outfit_reference if present\""
            : "    - \"EXCLUDE headwear (hats, helmets, caps, etc.) from outfit_reference\""

        let headwearAntiRule = includeHeadwear
            ? "  - \"Include headwear from outfit_reference - hats, helmets, caps should be applied\""
            : "  - \"Do NOT include any headwear from outfit_reference - no hats, helmets, or head accessories\""

        let bodyConstraints = """
  body_adaptation:
    - "Adapt body proportions to match the outfit_reference image"
    - "Maintain the silhouette and shape of the outfit from reference"
    - "Keep protectors, padding, and bulky elements at their original size"
    - "Body shape should fit the outfit, not the other way around"
  face_preservation:
    - "MUST use exact face from input body_sheet"
    - "Do NOT alter facial features, expression, or proportions"
    - "Maintain exact hair style and color from body_sheet reference"
  pose_preservation:
    - "MUST use the POSE from body_sheet (attention pose / kiwotsuke)"
    - "Do NOT copy the pose from outfit_reference image"
    - "Extract ONLY the clothing design, IGNORE the pose in reference"
  headwear:
\(headwearConstraint)
  outfit_extraction:
    - "Extract ONLY the clothing/outfit from the outfit_reference image"
    - "KEEP the body proportions that fit the outfit from reference"
    - "Maintain the style, color, design, and SHAPE of the reference outfit"
    - "Do NOT shrink or resize outfit to fit body_sheet body"
"""

        let antiRules = """
  - "Do NOT use face from outfit_reference image"
  - "Do NOT copy the POSE from outfit_reference - use body_sheet pose only"
  - "Do NOT shrink or compress outfit elements (like protectors)"
  - "ALLOW body proportions to change to match outfit reference"
  - "Do NOT add accessories not visible in outfit_reference"
  - "Do NOT change hair style or color from body_sheet"
  - "Apply the outfit with its ORIGINAL proportions from reference image"
\(headwearAntiRule)
"""

        return (bodyConstraints, antiRules)
    }

    private func generateHybridConstraints() -> (String, String) {
        let bodyConstraints = """
  hybrid_mode:
    - "HEAD (face, hair, headwear) ONLY from body_sheet"
    - "Body proportions from outfit_reference"
    - "This creates a hybrid: original head on a body that fits the outfit"
  head_preservation:
    - "MUST use ENTIRE HEAD from input body_sheet (face + hair + any accessories)"
    - "Do NOT alter facial features, expression, or proportions"
    - "Maintain exact hair style and color from body_sheet reference"
    - "Do NOT apply any headwear (hats, helmets, etc.) from outfit_reference"
    - "Head should look exactly like body_sheet - NO changes from reference"
  pose_preservation:
    - "MUST use the POSE from body_sheet (attention pose / kiwotsuke)"
    - "Do NOT copy the pose from outfit_reference image"
    - "Extract ONLY the clothing design, IGNORE the pose in reference"
  body_adaptation:
    - "Adapt body proportions to match the outfit_reference image"
    - "Keep protectors, padding, and bulky elements at their original size"
    - "Body shape should fit the outfit naturally"
  outfit_extraction:
    - "Extract ONLY the clothing/outfit (body parts only) from the outfit_reference image"
    - "EXCLUDE any headwear (hats, helmets, caps) from outfit_reference"
    - "KEEP the body proportions that fit the outfit from reference"
    - "Maintain the style, color, design, and SHAPE of the reference outfit"
"""

        let antiRules = """
  - "Do NOT use face from outfit_reference image - ONLY use body_sheet face"
  - "Do NOT use hair style from outfit_reference - ONLY use body_sheet hair"
  - "Do NOT apply headwear (hats, helmets, caps) from outfit_reference - head must match body_sheet exactly"
  - "Do NOT copy the POSE from outfit_reference - use body_sheet pose only"
  - "Do NOT shrink or compress outfit elements (like protectors)"
  - "ALLOW body proportions to change to match outfit reference"
  - "Do NOT add accessories not visible in outfit_reference"
  - "Apply the outfit with its ORIGINAL proportions from reference image"
  - "HEAD must be IDENTICAL to body_sheet - no changes from reference allowed"
"""

        return (bodyConstraints, antiRules)
    }
}
