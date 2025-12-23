// rule.mdを読むこと
import Foundation
import AppKit

// MARK: - API Mode

/// APIモード
enum APIMode: String, CaseIterable, Identifiable {
    case normal = "通常"
    case redraw = "清書"
    case simple = "シンプル"

    var id: String { rawValue }

    /// API呼び出し時の内部識別子
    var internalValue: String {
        switch self {
        case .normal: return "normal"
        case .redraw: return "redraw"
        case .simple: return "simple"
        }
    }
}

// MARK: - Resolution Extension

extension Resolution {
    /// API設定値
    var apiValue: String { rawValue }

    /// プロンプト用の説明
    var promptDescription: String {
        switch self {
        case .oneK:
            return "approximately 1024x1024 pixels (1K resolution)"
        case .twoK:
            return "approximately 2048x2048 pixels (2K resolution, high quality)"
        case .fourK:
            return "approximately 4096x4096 pixels (4K resolution, ultra high quality)"
        }
    }
}

// MARK: - APISubMode Extension

extension APISubMode {
    /// APIMode への変換
    var toAPIMode: APIMode {
        switch self {
        case .normal: return .normal
        case .redraw: return .redraw
        case .simple: return .simple
        }
    }
}

// MARK: - API Request Models (:generateContent エンドポイント用)

/// 画像生成リクエスト（Gemini :generateContent エンドポイント用）
struct ImageGenerationRequest: Codable {
    let contents: [Content]
    let generationConfig: GenerationConfig

    struct Content: Codable {
        let parts: [Part]
    }

    struct Part: Codable {
        let text: String?
        let inlineData: InlineData?
        // REST APIではキャメルケース（inlineData）が正しい
        // CodingKeysを省略するとプロパティ名がそのまま使われる

        init(text: String) {
            self.text = text
            self.inlineData = nil
        }

        init(imageData: String, mimeType: String = "image/png") {
            self.text = nil
            self.inlineData = InlineData(mimeType: mimeType, data: imageData)
        }
    }

    struct InlineData: Codable {
        let mimeType: String
        let data: String  // Base64エンコード
        // REST APIではキャメルケース（mimeType）が正しい
        // CodingKeysを省略するとプロパティ名がそのまま使われる
    }

    struct GenerationConfig: Codable {
        let responseModalities: [String]
        let imageConfig: ImageConfig?

        enum CodingKeys: String, CodingKey {
            case responseModalities
            case imageConfig  // キャメルケース（REST APIではこれが正しい）
        }

        init(aspectRatio: String? = nil) {
            // Gemini 3 Pro Imageは思考プロセス(TEXT)と画像(IMAGE)の両方を出力
            self.responseModalities = ["TEXT", "IMAGE"]
            if let aspectRatio = aspectRatio {
                self.imageConfig = ImageConfig(aspectRatio: aspectRatio)
            } else {
                self.imageConfig = nil
            }
        }
    }

    struct ImageConfig: Codable {
        let aspectRatio: String

        // REST APIではキャメルケース（aspectRatio）が正しい
        // CodingKeysを省略するとプロパティ名がそのまま使われる
    }
}

// MARK: - API Response Models (:generateContent エンドポイント用)

/// 画像生成レスポンス（Gemini :generateContent エンドポイント用）
struct ImageGenerationResponse: Codable {
    let candidates: [Candidate]?
    let promptFeedback: PromptFeedback?
    let error: ErrorInfo?

    enum CodingKeys: String, CodingKey {
        case candidates
        case promptFeedback
        case error
    }

    struct Candidate: Codable {
        let content: ResponseContent?
        let finishReason: String?
    }

    struct ResponseContent: Codable {
        let parts: [ResponsePart]?
    }

    struct ResponsePart: Codable {
        let text: String?
        let inlineData: InlineData?
        // REST APIではキャメルケース（inlineData）が正しい
        // CodingKeysを省略するとプロパティ名がそのまま使われる
    }

    struct InlineData: Codable {
        let mimeType: String?
        let data: String  // Base64エンコード
        // REST APIではキャメルケース（mimeType）が正しい
        // CodingKeysを省略するとプロパティ名がそのまま使われる
    }

    struct PromptFeedback: Codable {
        let blockReason: String?
    }

    struct ErrorInfo: Codable {
        let code: Int?
        let message: String?
        let status: String?
    }
}

// MARK: - API Error

/// APIエラー
enum APIError: LocalizedError {
    case invalidAPIKey
    case networkError(Error)
    case invalidResponse
    case safetyBlock(String?)
    case recitationBlock
    case malformedFunctionCall(String?)
    case rateLimited
    case noImageGenerated(String?)
    case imageEncodingFailed
    case imageDecodingFailed
    case unknownError(String)

    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "無効なAPIキーです。APIキーを確認してください。"
        case .networkError(let error):
            return "ネットワークエラー: \(error.localizedDescription)"
        case .invalidResponse:
            return "APIからのレスポンスが不正です。"
        case .safetyBlock(let reason):
            if let reason = reason {
                return "安全性フィルターによりブロックされました。理由: \(reason)"
            }
            return "安全性フィルターによりブロックされました。プロンプトや参照画像を変更してお試しください。"
        case .recitationBlock:
            return "著作権関連の問題でコンテンツがブロックされました。"
        case .malformedFunctionCall(let message):
            if let message = message {
                return "画像編集リクエストの処理に失敗しました。\n\n詳細: \(message)\n\nより単純なプロンプトでお試しください。"
            }
            return "画像編集リクエストの処理に失敗しました。プロンプトを変更してお試しください。\n\n（例: 「モノクロに変更」「セピア調に変換」など単純な指示が成功しやすいです）"
        case .rateLimited:
            return "API呼び出し制限に達しました。しばらく待ってから再試行してください。"
        case .noImageGenerated(let message):
            if let message = message {
                return "画像が生成されませんでした。\n\nAPIからのメッセージ:\n\(message)"
            }
            return "画像が生成されませんでした。プロンプトを変更してお試しください。"
        case .imageEncodingFailed:
            return "画像のエンコードに失敗しました。"
        case .imageDecodingFailed:
            return "生成された画像のデコードに失敗しました。"
        case .unknownError(let message):
            return "エラー: \(message)"
        }
    }
}

// MARK: - Image Generation Result

/// 画像生成結果
struct ImageGenerationResult {
    let success: Bool
    let image: NSImage?
    let error: APIError?

    static func success(_ image: NSImage) -> ImageGenerationResult {
        ImageGenerationResult(success: true, image: image, error: nil)
    }

    static func failure(_ error: APIError) -> ImageGenerationResult {
        ImageGenerationResult(success: false, image: nil, error: error)
    }
}
