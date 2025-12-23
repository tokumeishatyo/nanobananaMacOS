// rule.mdを読むこと
import Foundation
@preconcurrency import Vision
import AppKit
import CoreImage
import CoreImage.CIFilterBuiltins

/// 背景透過処理サービス
/// 対応OS: macOS 14.0以降
@available(macOS 14.0, *)
final class BackgroundRemovalService {

    // MARK: - Error Types

    enum RemovalError: LocalizedError {
        case invalidImage
        case cgImageConversionFailed
        case noMaskGenerated
        case processingFailed(String)

        var errorDescription: String? {
            switch self {
            case .invalidImage:
                return "画像を読み込めませんでした"
            case .cgImageConversionFailed:
                return "画像の変換に失敗しました"
            case .noMaskGenerated:
                return "被写体を検出できませんでした"
            case .processingFailed(let message):
                return "処理中にエラーが発生しました: \(message)"
            }
        }
    }

    // MARK: - Public Methods

    /// 背景を透過した画像を生成
    /// - Parameter image: 入力画像
    /// - Returns: 背景透過済み画像（アルファチャンネル付き）
    static func removeBackground(from image: NSImage) async throws -> NSImage {
        // 1. CGImageに変換
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw RemovalError.cgImageConversionFailed
        }

        // 2. マスクを生成
        let mask = try await generateForegroundMask(for: cgImage)

        // 3. マスクを適用して透過画像を生成
        guard let resultCGImage = applyMask(mask, to: cgImage) else {
            throw RemovalError.processingFailed("マスクの適用に失敗しました")
        }

        // 4. NSImageとして返却
        let resultImage = NSImage(cgImage: resultCGImage, size: image.size)
        return resultImage
    }

    // MARK: - Private Methods

    /// VNGenerateForegroundInstanceMaskRequestを使用してマスクを生成
    private static func generateForegroundMask(for cgImage: CGImage) async throws -> CVPixelBuffer {
        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        // 同期処理をasync/awaitでラップ
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])

                    guard let result = request.results?.first else {
                        continuation.resume(throwing: RemovalError.noMaskGenerated)
                        return
                    }

                    // 全インスタンスを統合したマスクを取得
                    do {
                        let mask = try result.generateScaledMaskForImage(
                            forInstances: result.allInstances,
                            from: handler
                        )
                        continuation.resume(returning: mask)
                    } catch {
                        continuation.resume(throwing: RemovalError.processingFailed(error.localizedDescription))
                    }
                } catch {
                    continuation.resume(throwing: RemovalError.processingFailed(error.localizedDescription))
                }
            }
        }
    }

    /// マスクを元画像に適用して透過画像を生成
    private static func applyMask(_ mask: CVPixelBuffer, to image: CGImage) -> CGImage? {
        // CIImageに変換
        let ciImage = CIImage(cgImage: image)
        let maskImage = CIImage(cvPixelBuffer: mask)

        // マスクを元画像サイズにリサイズ
        let scaleX = CGFloat(image.width) / maskImage.extent.width
        let scaleY = CGFloat(image.height) / maskImage.extent.height
        let scaledMask = maskImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        // CIBlendWithMaskフィルタで合成
        let filter = CIFilter.blendWithMask()
        filter.inputImage = ciImage
        filter.maskImage = scaledMask
        filter.backgroundImage = CIImage.empty()  // 透明背景

        guard let outputImage = filter.outputImage else { return nil }

        // CGImageに変換して返却
        let context = CIContext()
        return context.createCGImage(outputImage, from: outputImage.extent)
    }
}
