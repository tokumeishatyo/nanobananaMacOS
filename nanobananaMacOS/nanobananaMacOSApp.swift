// rule.mdを読むこと
//
//  nanobananaMacOSApp.swift
//  nanobananaMacOS
//
//  Created by 川﨑 伸之 on 2025/12/17.
//

import SwiftUI

@main
struct nanobananaMacOSApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.automatic)
        .defaultSize(width: 1400, height: 800)
        .commands {
            // メニューバーのカスタマイズ（必要に応じて追加）
        }
    }
}
