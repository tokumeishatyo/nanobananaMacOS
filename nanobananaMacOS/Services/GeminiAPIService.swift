// rule.mdを読むこと
import Foundation
import AppKit

// MARK: - Gemini API Service

/// Gemini APIを使用した画像生成サービス
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

        // リクエストの構築
        let requestBody: ImageGenerationRequest
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

        // URLの構築（:generateContent エンドポイント）
        let urlString = "\(baseURL)/\(model):generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            return .failure(.unknownError("無効なURL"))
        }

        // HTTPリクエストの構築
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(requestBody)

            // デバッグ用：リクエストボディを出力
            if let jsonString = String(data: request.httpBody!, encoding: .utf8) {
                print("[GeminiAPIService] Request body (first 1000 chars): \(jsonString.prefix(1000))")
            }
        } catch {
            return .failure(.unknownError("リクエストのエンコードに失敗: \(error.localizedDescription)"))
        }

        // API呼び出し
        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            // HTTPステータスコードの確認
            if let httpResponse = response as? HTTPURLResponse {
                print("[GeminiAPIService] Status code: \(httpResponse.statusCode)")

                switch httpResponse.statusCode {
                case 200:
                    break  // 成功
                case 400:
                    let errorDetail = String(data: data, encoding: .utf8) ?? ""
                    print("[GeminiAPIService] 400 Error: \(errorDetail)")
                    return .failure(.unknownError("リクエストが不正です (400): \(errorDetail.prefix(300))"))
                case 401, 403:
                    return .failure(.invalidAPIKey)
                case 429:
                    return .failure(.rateLimited)
                case 500...599:
                    return .failure(.unknownError("サーバーエラー (\(httpResponse.statusCode))"))
                default:
                    let errorDetail = String(data: data, encoding: .utf8) ?? ""
                    return .failure(.unknownError("HTTPエラー: \(httpResponse.statusCode) - \(errorDetail.prefix(300))"))
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

    /// リクエストボディの構築（:generateContent エンドポイント用）
    private func buildRequestBody(
        prompt: String,
        characterImages: [NSImage],
        compositionImage: NSImage?,
        resolution: Resolution,
        aspectRatio: String,
        mode: APIMode
    ) throws -> ImageGenerationRequest {

        var parts: [ImageGenerationRequest.Part] = []

        // モードに応じたプロンプト構築
        let formattedPrompt = buildPrompt(
            basePrompt: prompt,
            resolution: resolution,
            aspectRatio: aspectRatio,
            mode: mode,
            hasCompositionImage: compositionImage != nil
        )
        parts.append(ImageGenerationRequest.Part(text: formattedPrompt))

        // 構図参照画像の追加（清書/シンプルモード）
        if let compositionImage = compositionImage {
            guard let base64 = encodeImage(compositionImage) else {
                throw APIError.imageEncodingFailed
            }
            parts.append(ImageGenerationRequest.Part(imageData: base64))
        }

        // キャラクター参照画像の追加
        for characterImage in characterImages {
            guard let base64 = encodeImage(characterImage) else {
                throw APIError.imageEncodingFailed
            }
            parts.append(ImageGenerationRequest.Part(imageData: base64))
        }

        let content = ImageGenerationRequest.Content(parts: parts)
        let config = ImageGenerationRequest.GenerationConfig(aspectRatio: aspectRatio)

        return ImageGenerationRequest(contents: [content], generationConfig: config)
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
            return """
            ## IMAGE GENERATION REQUEST

            Generate an image based on the following instructions.

            ## OUTPUT SPECIFICATIONS:
            - Resolution: \(resolution.promptDescription)
            - Aspect Ratio: \(aspectRatio)

            ## REFERENCE IMAGE:
            The attached image is a reference. Use it as inspiration for style, composition, or elements as appropriate to the prompt below.

            ## IMPORTANT - WATERMARK REMOVAL:
            If the reference image contains any watermarks, logos, or signatures (such as "Gemini" watermark in the corner), DO NOT reproduce them in the output. The output image must be clean without any watermarks.

            ## PROMPT:
            \(basePrompt)
            """
        } else {
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

    /// 画像をBase64エンコード
    private func encodeImage(_ image: NSImage) -> String? {
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            return nil
        }
        return pngData.base64EncodedString()
    }

    /// レスポンスの処理（:generateContent エンドポイント用）
    private func processResponse(_ data: Data) -> ImageGenerationResult {

        // デバッグ用：レスポンスを出力
        if let rawString = String(data: data, encoding: .utf8) {
            print("[GeminiAPIService] Raw response (first 500 chars): \(rawString.prefix(500))")
        }

        let decoder = JSONDecoder()
        let response: ImageGenerationResponse

        do {
            response = try decoder.decode(ImageGenerationResponse.self, from: data)
        } catch {
            print("[GeminiAPIService] Decode error: \(error)")
            return .failure(.invalidResponse)
        }

        // エラーレスポンスの確認
        if let errorInfo = response.error {
            let message = errorInfo.message ?? "Unknown error"
            print("[GeminiAPIService] API Error: \(message)")
            return .failure(.unknownError(message))
        }

        // candidatesの確認
        guard let candidates = response.candidates, !candidates.isEmpty else {
            // ブロック理由の確認
            if let blockReason = response.promptFeedback?.blockReason {
                return .failure(.safetyBlock(blockReason))
            }
            return .failure(.noImageGenerated(nil))
        }

        let candidate = candidates[0]

        // finish_reasonの確認
        if let finishReason = candidate.finishReason?.uppercased() {
            if finishReason.contains("SAFETY") {
                return .failure(.safetyBlock(nil))
            }
            if finishReason.contains("RECITATION") {
                return .failure(.recitationBlock)
            }
        }

        // パーツの確認
        guard let parts = candidate.content?.parts, !parts.isEmpty else {
            return .failure(.noImageGenerated(nil))
        }

        // 画像データの抽出
        var textResponse: String?
        for part in parts {
            if let inlineData = part.inlineData {
                // Base64デコード
                guard let imageData = Data(base64Encoded: inlineData.data) else {
                    return .failure(.imageDecodingFailed)
                }
                guard let image = NSImage(data: imageData) else {
                    return .failure(.imageDecodingFailed)
                }
                return .success(image)
            }
            if let text = part.text {
                textResponse = text
            }
        }

        // 画像が見つからない場合
        let preview = textResponse.map { String($0.prefix(200)) }
        return .failure(.noImageGenerated(preview))
    }
}
