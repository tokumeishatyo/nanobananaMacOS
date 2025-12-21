// rule.mdを読むこと
import SwiftUI
import AppKit

/// 設定ウィンドウを管理するユーティリティ
/// .sheet()の代わりに移動可能なウィンドウとして表示
final class WindowManager {
    static let shared = WindowManager()

    private var openWindows: [String: NSWindow] = [:]

    private init() {}

    /// 設定ウィンドウを開く
    /// - Parameters:
    ///   - id: ウィンドウの識別子（同じIDのウィンドウは1つのみ）
    ///   - title: ウィンドウタイトル
    ///   - size: ウィンドウサイズ
    ///   - content: 表示するSwiftUI View
    func openWindow<Content: View>(
        id: String,
        title: String,
        size: NSSize,
        @ViewBuilder content: @escaping () -> Content
    ) {
        // 既に同じIDのウィンドウが開いている場合は前面に
        if let existingWindow = openWindows[id], existingWindow.isVisible {
            existingWindow.makeKeyAndOrderFront(nil)
            return
        }

        // 新しいウィンドウを作成
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: size.width, height: size.height),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        window.title = title
        window.center()
        window.isReleasedWhenClosed = false

        // dismissを処理するラッパーでコンテンツを包む
        let wrappedContent = WindowContentWrapper(windowId: id) {
            content()
        }

        // SwiftUIのViewをホスト
        let hostingView = NSHostingView(rootView: wrappedContent)
        window.contentView = hostingView

        // サイズを固定（設定ウィンドウはリサイズ不要）
        window.setContentSize(size)

        // ウィンドウを表示
        window.makeKeyAndOrderFront(nil)

        // 管理対象に追加
        openWindows[id] = window

        // ウィンドウが閉じられたときのクリーンアップ
        NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: window,
            queue: .main
        ) { [weak self] _ in
            self?.openWindows.removeValue(forKey: id)
        }
    }

    /// 指定したIDのウィンドウを閉じる
    func closeWindow(id: String) {
        if let window = openWindows[id] {
            window.close()
            openWindows.removeValue(forKey: id)
        }
    }

    /// 全ての設定ウィンドウを閉じる
    func closeAllWindows() {
        for (_, window) in openWindows {
            window.close()
        }
        openWindows.removeAll()
    }
}

// MARK: - Window Content Wrapper

/// @Environment(\.dismiss)をNSWindowの閉じる動作に変換するラッパー
private struct WindowContentWrapper<Content: View>: View {
    let windowId: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .environment(\.windowDismiss, WindowDismissAction(windowId: windowId))
    }
}

// MARK: - Custom Dismiss Environment

/// カスタムdismissアクション
struct WindowDismissAction {
    let windowId: String

    func callAsFunction() {
        WindowManager.shared.closeWindow(id: windowId)
    }
}

/// Environment key for window dismiss
private struct WindowDismissKey: EnvironmentKey {
    static let defaultValue: WindowDismissAction? = nil
}

extension EnvironmentValues {
    var windowDismiss: WindowDismissAction? {
        get { self[WindowDismissKey.self] }
        set { self[WindowDismissKey.self] = newValue }
    }
}

// MARK: - Settings View Helper

/// 設定ウィンドウで使用するdismissヘルパー
/// windowDismissがあればそれを使い、なければ標準のdismissを使う
struct SettingsDismissHelper {
    let windowDismiss: WindowDismissAction?
    let standardDismiss: DismissAction

    func callAsFunction() {
        if let windowDismiss = windowDismiss {
            windowDismiss()
        } else {
            standardDismiss()
        }
    }
}
