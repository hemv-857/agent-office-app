// AgentOfficeApp.swift
import SwiftUI

@main
struct AgentOfficeApp: App {
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .frame(minWidth: 900, minHeight: 600)
                .preferredColorScheme(store.theme == .dark ? .dark : store.theme == .light ? .light : nil)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .defaultSize(width: 1440, height: 900)
    }
}
