// rule.mdを読むこと
import Foundation

// MARK: - Translation Service
/// Gemini APIを使用したバッチ翻訳サービス
/// gemini-1.5-flashを使用して日本語→英語の翻訳を行う
final class TranslationService {

    // MARK: - Constants

    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models"
    private let model = "gemini-2.5-flash"

    // MARK: - Singleton

    static let shared = TranslationService()

    private init() {}

    // MARK: - Error Types

    enum TranslationError: Error, LocalizedError {
        case apiKeyNotSet
        case invalidAPIKey
        case networkError(Error)
        case invalidResponse
        case translationFailed(String)
        case noTextsToTranslate

        var errorDescription: String? {
            switch self {
            case .apiKeyNotSet:
                return "APIキーが設定されていません。中央カラムでAPIキーを入力してください。"
            case .invalidAPIKey:
                return "APIキーが無効です。"
            case .networkError(let error):
                return "ネットワークエラー: \(error.localizedDescription)"
            case .invalidResponse:
                return "APIからの応答が不正です。"
            case .translationFailed(let message):
                return "翻訳に失敗しました: \(message)"
            case .noTextsToTranslate:
                return "翻訳対象のテキストがありません。"
            }
        }
    }

    // MARK: - Translation Result

    typealias TranslationResult = Result<[String: String], TranslationError>

    // MARK: - Public Methods

    /// バッチ翻訳を実行
    /// - Parameters:
    ///   - apiKey: Google AI API Key
    ///   - texts: 翻訳対象のテキスト（key -> 日本語テキスト）
    /// - Returns: 翻訳結果（key -> 英語テキスト）
    func translateBatch(
        apiKey: String,
        texts: [String: String]
    ) async -> TranslationResult {

        // APIキーの検証
        guard !apiKey.isEmpty else {
            return .failure(.apiKeyNotSet)
        }

        guard apiKey.count >= 10 else {
            return .failure(.invalidAPIKey)
        }

        // 翻訳対象がない場合
        guard !texts.isEmpty else {
            return .failure(.noTextsToTranslate)
        }

        // 空でないテキストのみ抽出
        let nonEmptyTexts = texts.filter { !$0.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

        if nonEmptyTexts.isEmpty {
            // 翻訳対象がなければ空の辞書を返す（エラーではない）
            return .success([:])
        }

        // URLの構築
        let urlString = "\(baseURL)/\(model):generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            return .failure(.invalidResponse)
        }

        // プロンプトの構築
        let prompt = buildTranslationPrompt(texts: nonEmptyTexts)

        // リクエストボディの構築
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ],
            "generationConfig": [
                "responseMimeType": "application/json"
            ]
        ]

        // HTTPリクエストの構築
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60  // 翻訳は画像生成より早いが余裕を持って60秒

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

            #if DEBUG
            print("[TranslationService] Sending \(nonEmptyTexts.count) texts for translation")
            #endif
        } catch {
            return .failure(.translationFailed("リクエストのシリアライズに失敗: \(error.localizedDescription)"))
        }

        // API呼び出し
        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            // HTTPステータスコードの確認
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.invalidResponse)
            }

            #if DEBUG
            print("[TranslationService] Status code: \(httpResponse.statusCode)")
            #endif

            if !(200...299).contains(httpResponse.statusCode) {
                let errorJson = (try? JSONSerialization.jsonObject(with: data) as? [String: Any]) ?? [:]
                let errorMessage = (errorJson["error"] as? [String: Any])?["message"] as? String ?? "Unknown error"

                #if DEBUG
                print("[TranslationService] Error: Status \(httpResponse.statusCode), Message: \(errorMessage)")
                #endif

                switch httpResponse.statusCode {
                case 400:
                    return .failure(.translationFailed("リクエストが不正です: \(errorMessage)"))
                case 401, 403:
                    return .failure(.invalidAPIKey)
                case 429:
                    return .failure(.translationFailed("APIの利用制限に達しました。しばらくしてから再試行してください。"))
                default:
                    return .failure(.translationFailed("HTTPエラー \(httpResponse.statusCode): \(errorMessage)"))
                }
            }

            // レスポンスの解析
            return parseTranslationResponse(data, expectedKeys: Array(nonEmptyTexts.keys))

        } catch {
            return .failure(.networkError(error))
        }
    }

    // MARK: - Private Methods

    /// 翻訳プロンプトの構築
    private func buildTranslationPrompt(texts: [String: String]) -> String {
        // JSON形式でテキストを構築
        var jsonObject: [String: String] = [:]
        for (key, value) in texts {
            jsonObject[key] = value
        }

        let jsonData = (try? JSONSerialization.data(withJSONObject: jsonObject, options: .sortedKeys)) ?? Data()
        let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"

        return """
        You are a professional Japanese to English translator for manga/comic production.

        ## Task
        Translate all the Japanese text values in the following JSON to English.
        Keep the keys exactly the same, only translate the values.

        ## Important Guidelines
        1. These are descriptions for AI image generation, so translate naturally and descriptively
        2. Keep proper nouns (character names, place names) as-is or romanize them
        3. Translate emotions, actions, and scenes vividly
        4. Output ONLY valid JSON with the same keys and translated values
        5. Do not add any explanation or comments

        ## Input JSON
        \(jsonString)

        ## Output
        Return a JSON object with the same keys and English translations as values.
        """
    }

    /// レスポンスの解析
    private func parseTranslationResponse(_ data: Data, expectedKeys: [String]) -> TranslationResult {

        #if DEBUG
        if let rawString = String(data: data, encoding: .utf8) {
            print("[TranslationService] Raw response (first 500 chars): \(rawString.prefix(500))")
        }
        #endif

        // JSONパース
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return .failure(.invalidResponse)
        }

        // エラーチェック
        if let error = json["error"] as? [String: Any],
           let message = error["message"] as? String {
            return .failure(.translationFailed(message))
        }

        // candidatesの確認
        guard let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let textResponse = firstPart["text"] as? String else {
            return .failure(.invalidResponse)
        }

        #if DEBUG
        print("[TranslationService] Text response: \(textResponse)")
        #endif

        // JSONレスポンスの解析
        // ```json ... ``` で囲まれている場合があるので取り除く
        var cleanedResponse = textResponse.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanedResponse.hasPrefix("```json") {
            cleanedResponse = String(cleanedResponse.dropFirst(7))
        } else if cleanedResponse.hasPrefix("```") {
            cleanedResponse = String(cleanedResponse.dropFirst(3))
        }
        if cleanedResponse.hasSuffix("```") {
            cleanedResponse = String(cleanedResponse.dropLast(3))
        }
        cleanedResponse = cleanedResponse.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let responseData = cleanedResponse.data(using: .utf8),
              let translations = try? JSONSerialization.jsonObject(with: responseData) as? [String: String] else {
            return .failure(.translationFailed("翻訳結果のパースに失敗しました"))
        }

        #if DEBUG
        print("[TranslationService] Parsed translations: \(translations)")
        #endif

        return .success(translations)
    }
}
