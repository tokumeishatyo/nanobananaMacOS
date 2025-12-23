// rule.mdを読むこと
import Foundation
import AppKit

// MARK: - Gemini API Service

/// Gemini APIを使用した画像生成サービス
/// 参考: 参考文献/重要_Gemini3Pro連携仕様.md
final class GeminiAPIService {

    // MARK: - Constants

    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models"
    private let model = "gemini-3-pro-image-preview"

    // MARK: - Singleton

    static let shared = GeminiAPIService()

    private init() {}

    // MARK: - Public Methods

    /// 画像を生成
    /// - Parameters:
    ///   - apiKey: Google AI API Key
    ///   - prompt: YAMLプロンプト（通常/清書モード）またはテキストプロンプト（シンプルモード）
    ///   - characterImages: キャラクター参照画像のリスト
    ///   - compositionImage: 構図参照画像（清書/シンプルモードで使用）
    ///   - resolution: 解像度
    ///   - aspectRatio: アスペクト比
    ///   - mode: APIモード
    /// - Returns: 画像生成結果
    func generateImage(
        apiKey: String,
        prompt: String,
        characterImages: [NSImage] = [],
        compositionImage: NSImage? = nil,
        resolution: Resolution = .twoK,
        aspectRatio: String = "1:1",
        mode: APIMode = .normal
    ) async -> ImageGenerationResult {

        // APIキーの検証
        guard validateAPIKey(apiKey) else {
            return .failure(.invalidAPIKey)
        }

        // URLの構築
        let urlString = "\(baseURL)/\(model):generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            return .failure(.unknownError("無効なURL"))
        }

        // リクエストボディの構築
        let requestBody: [String: Any]
        do {
            requestBody = try buildRequestBody(
                prompt: prompt,
                characterImages: characterImages,
                compositionImage: compositionImage,
                resolution: resolution,
                aspectRatio: aspectRatio,
                mode: mode
            )
        } catch let error as APIError {
            return .failure(error)
        } catch {
            return .failure(.unknownError(error.localizedDescription))
        }

        // HTTPリクエストの構築
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 180  // 画像生成は時間がかかるため3分に設定

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

            #if DEBUG
            // デバッグ用：リクエスト構造を出力（base64データは省略）
            debugPrintRequestStructure(requestBody)
            #endif
        } catch {
            return .failure(.unknownError("リクエストのシリアライズに失敗: \(error.localizedDescription)"))
        }

        // API呼び出し
        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            // HTTPステータスコードの確認
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.invalidResponse)
            }

            #if DEBUG
            print("[GeminiAPIService] Status code: \(httpResponse.statusCode)")
            #endif

            if !(200...299).contains(httpResponse.statusCode) {
                // エラーレスポンスの解析
                let errorJson = (try? JSONSerialization.jsonObject(with: data) as? [String: Any]) ?? [:]
                let errorMessage = (errorJson["error"] as? [String: Any])?["message"] as? String ?? "Unknown error"
                #if DEBUG
                print("[GeminiAPIService] Error: Status \(httpResponse.statusCode), Message: \(errorMessage)")
                #endif

                switch httpResponse.statusCode {
                case 400:
                    return .failure(.unknownError("リクエストが不正です (400): \(errorMessage)"))
                case 401, 403:
                    return .failure(.invalidAPIKey)
                case 429:
                    return .failure(.rateLimited)
                case 500...599:
                    return .failure(.unknownError("サーバーエラー (\(httpResponse.statusCode)): \(errorMessage)"))
                default:
                    return .failure(.unknownError("HTTPエラー \(httpResponse.statusCode): \(errorMessage)"))
                }
            }

            // レスポンスの解析
            return processResponse(data)

        } catch {
            return .failure(.networkError(error))
        }
    }

    // MARK: - Private Methods

    /// APIキーの検証
    private func validateAPIKey(_ apiKey: String) -> Bool {
        guard !apiKey.isEmpty else { return false }
        guard apiKey.count >= 10 else { return false }
        return true
    }

    /// リクエストボディの構築（JSONSerialization用）
    private func buildRequestBody(
        prompt: String,
        characterImages: [NSImage],
        compositionImage: NSImage?,
        resolution: Resolution,
        aspectRatio: String,
        mode: APIMode
    ) throws -> [String: Any] {

        var parts: [[String: Any]] = []

        // モードに応じたプロンプト構築
        let formattedPrompt = buildPrompt(
            basePrompt: prompt,
            resolution: resolution,
            aspectRatio: aspectRatio,
            mode: mode,
            hasCompositionImage: compositionImage != nil
        )
        parts.append(["text": formattedPrompt])

        // 構図参照画像の追加（清書/シンプルモード）
        if let compositionImage = compositionImage {
            guard let imageData = compositionImage.pngData else {
                throw APIError.imageEncodingFailed
            }
            let base64Image = imageData.base64EncodedString()
            parts.append([
                "inlineData": [
                    "mimeType": "image/png",
                    "data": base64Image
                ]
            ])
        }

        // キャラクター参照画像の追加
        for characterImage in characterImages {
            guard let imageData = characterImage.pngData else {
                throw APIError.imageEncodingFailed
            }
            let base64Image = imageData.base64EncodedString()
            parts.append([
                "inlineData": [
                    "mimeType": "image/png",
                    "data": base64Image
                ]
            ])
        }

        // リクエストボディの構築
        // 重要: responseMimeType は指定しない（400エラーの原因）
        // 重要: responseModalities は ["TEXT", "IMAGE"] の両方が必須
        // 参考: https://ai.google.dev/gemini-api/docs/image-generation?hl=ja
        let requestBody: [String: Any] = [
            "contents": [
                ["parts": parts]
            ],
            "generationConfig": [
                "responseModalities": ["TEXT", "IMAGE"],
                "imageConfig": [
                    "aspectRatio": aspectRatio,
                    "imageSize": resolution.rawValue
                ]
            ]
        ]

        return requestBody
    }

    /// モードに応じたプロンプト構築
    private func buildPrompt(
        basePrompt: String,
        resolution: Resolution,
        aspectRatio: String,
        mode: APIMode,
        hasCompositionImage: Bool
    ) -> String {

        switch mode {
        case .normal:
            return buildNormalModePrompt(basePrompt: basePrompt, resolution: resolution)

        case .redraw:
            return buildRedrawModePrompt(basePrompt: basePrompt, resolution: resolution)

        case .simple:
            return buildSimpleModePrompt(
                basePrompt: basePrompt,
                resolution: resolution,
                aspectRatio: aspectRatio,
                hasReference: hasCompositionImage
            )
        }
    }

    /// 通常モードのプロンプト
    private func buildNormalModePrompt(basePrompt: String, resolution: Resolution) -> String {
        """
        ## OUTPUT RESOLUTION:
        Generate the image at \(resolution.promptDescription).

        ---
        \(basePrompt)
        """
    }

    /// 清書モードのプロンプト
    private func buildRedrawModePrompt(basePrompt: String, resolution: Resolution) -> String {
        """
        【HIGH-QUALITY REDRAW MODE】

        You are performing a high-quality redraw task.
        Use the YAML instructions below AND the attached reference image together.

        ## OUTPUT RESOLUTION:
        Generate the image at \(resolution.promptDescription).
        This is critical - output must be high resolution.

        ## CRITICAL RULES:
        1. Follow the YAML prompt instructions for content and style
        2. Use the reference image as a guide for:
           - Exact composition and layout
           - Character positions and poses
           - Speech bubble placements (if any)
           - Scene framing and camera angle
        3. Generate a MORE DETAILED, higher quality version
        4. Improve: line art clarity, shading details, background details, facial features
        5. Maintain the same scene but with professional-level quality

        ## IMPORTANT - WATERMARK REMOVAL:
        If the reference image contains any watermarks, logos, or signatures (such as "Gemini" watermark in the corner), DO NOT reproduce them in the output. The output image must be clean without any watermarks.

        ## IMPORTANT:
        - The reference image shows the desired composition - MATCH IT
        - The YAML provides detailed instructions - FOLLOW THEM
        - Output should look like a polished, professional version of the reference

        ---
        YAML Instructions:
        \(basePrompt)
        """
    }

    /// シンプルモードのプロンプト
    private func buildSimpleModePrompt(
        basePrompt: String,
        resolution: Resolution,
        aspectRatio: String,
        hasReference: Bool
    ) -> String {

        if hasReference {
            // 参照画像ありの場合: 画像編集モード
            // Googleのアドバイス: Role + Task + Constraints の構造化プロンプト
            return """
            # Role
            You are an expert image editing AI.

            # Task
            Generate a NEW image based on the provided input image (Input Image), following the user's instruction (Instruction) to modify specific parts.

            # Instruction
            \(basePrompt)

            # Constraints
            - Strictly maintain the composition, poses, art style, lighting, and aspect ratio of the input image.
            - Only modify the parts specified in the instruction.
            - Do NOT change anything that is not explicitly mentioned.
            - Output image only, no text explanation.

            # Output Specifications
            - Resolution: \(resolution.promptDescription)
            - Aspect Ratio: \(aspectRatio)

            # Important
            - If the input image contains any watermarks, logos, or signatures (such as "Gemini" watermark), DO NOT reproduce them in the output.
            - The output image must be clean without any watermarks.
            """
        } else {
            // 参照画像なしの場合: 新規生成モード
            return """
            ## IMAGE GENERATION REQUEST

            Generate an image based on the following instructions.

            ## OUTPUT SPECIFICATIONS:
            - Resolution: \(resolution.promptDescription)
            - Aspect Ratio: \(aspectRatio)

            ## PROMPT:
            \(basePrompt)
            """
        }
    }

    /// レスポンスの処理（JSONSerialization版）
    private func processResponse(_ data: Data) -> ImageGenerationResult {

        #if DEBUG
        // デバッグ用：レスポンスを出力
        if let rawString = String(data: data, encoding: .utf8) {
            print("[GeminiAPIService] Raw response (first 500 chars): \(rawString.prefix(500))")
        }
        #endif

        // JSONパース
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            #if DEBUG
            print("[GeminiAPIService] Failed to parse JSON")
            #endif
            return .failure(.invalidResponse)
        }

        // エラーチェック
        if let error = json["error"] as? [String: Any],
           let message = error["message"] as? String {
            #if DEBUG
            print("[GeminiAPIService] API Error: \(message)")
            #endif
            return .failure(.unknownError(message))
        }

        // candidatesの確認
        guard let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first else {
            // ブロック理由の確認
            if let promptFeedback = json["promptFeedback"] as? [String: Any],
               let blockReason = promptFeedback["blockReason"] as? String {
                return .failure(.safetyBlock(blockReason))
            }
            return .failure(.noImageGenerated(nil))
        }

        // finish_reasonの確認
        if let finishReason = (firstCandidate["finishReason"] as? String)?.uppercased() {
            if finishReason.contains("SAFETY") {
                return .failure(.safetyBlock(nil))
            }
            if finishReason.contains("RECITATION") {
                return .failure(.recitationBlock)
            }
            if finishReason.contains("MALFORMED_FUNCTION_CALL") {
                // finishMessageから詳細を取得
                let finishMessage = firstCandidate["finishMessage"] as? String
                #if DEBUG
                print("[GeminiAPIService] MALFORMED_FUNCTION_CALL: \(finishMessage ?? "no details")")
                #endif
                return .failure(.malformedFunctionCall(finishMessage))
            }
        }

        // contentの確認
        guard let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]] else {
            return .failure(.noImageGenerated(nil))
        }

        // 画像データの抽出（inlineData と inline_data の両方に対応）
        var textResponse: String?
        for part in parts {
            // inlineData (CamelCase) または inline_data (SnakeCase) を探す
            if let inlineData = part["inlineData"] as? [String: Any] ?? part["inline_data"] as? [String: Any],
               let base64Data = inlineData["data"] as? String,
               let imageData = Data(base64Encoded: base64Data),
               let image = NSImage(data: imageData) {
                return .success(image)
            }
            if let text = part["text"] as? String {
                textResponse = text
            }
        }

        // 画像が見つからない場合
        let preview = textResponse.map { String($0.prefix(200)) }
        return .failure(.noImageGenerated(preview))
    }

    #if DEBUG
    /// デバッグ用：リクエスト構造を出力（base64データは省略）
    private func debugPrintRequestStructure(_ requestBody: [String: Any]) {
        print("[GeminiAPIService] ===== Request Structure =====")

        // generationConfigの確認
        if let genConfig = requestBody["generationConfig"] as? [String: Any] {
            print("[GeminiAPIService] generationConfig: \(genConfig)")
        } else {
            print("[GeminiAPIService] WARNING: generationConfig is missing!")
        }

        // contentsの確認
        if let contents = requestBody["contents"] as? [[String: Any]] {
            for (i, content) in contents.enumerated() {
                if let parts = content["parts"] as? [[String: Any]] {
                    print("[GeminiAPIService] contents[\(i)].parts count: \(parts.count)")
                    for (j, part) in parts.enumerated() {
                        if let text = part["text"] as? String {
                            print("[GeminiAPIService]   part[\(j)]: text (length: \(text.count))")
                        }
                        if let inlineData = part["inlineData"] {
                            // inlineDataの型と構造を詳細に出力
                            print("[GeminiAPIService]   part[\(j)]: inlineData type: \(type(of: inlineData))")
                            if let dataDict = inlineData as? [String: Any] {
                                let keys = dataDict.keys.sorted()
                                print("[GeminiAPIService]   part[\(j)]: inlineData keys: \(keys)")
                                if let mimeType = dataDict["mimeType"] {
                                    print("[GeminiAPIService]   part[\(j)]: mimeType = \(mimeType)")
                                } else {
                                    print("[GeminiAPIService]   part[\(j)]: WARNING: mimeType is MISSING!")
                                }
                                if let data = dataDict["data"] as? String {
                                    print("[GeminiAPIService]   part[\(j)]: data length = \(data.count) chars")
                                }
                            } else {
                                print("[GeminiAPIService]   part[\(j)]: WARNING: inlineData is not a dictionary!")
                            }
                        }
                    }
                }
            }
        } else {
            print("[GeminiAPIService] WARNING: contents is missing or invalid!")
        }

        print("[GeminiAPIService] =============================")
    }
    #endif
}

// MARK: - NSImage Extension

extension NSImage {
    /// PNG形式のData
    var pngData: Data? {
        guard let tiffRepresentation = tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImage.representation(using: .png, properties: [:])
    }
}
