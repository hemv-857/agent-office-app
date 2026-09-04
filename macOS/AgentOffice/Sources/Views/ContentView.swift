// ContentView.swift
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        HSplitView {
            if store.showSidebar {
                SidebarView()
                    .frame(minWidth: 260, idealWidth: 280, maxWidth: 320)
            }

            VStack(spacing: 0) {
                HeaderView()
                OfficeGridView()
                PromptBarView()
                StatusBarView()
            }

            if store.showResultsPanel {
                ResultsPanelView()
                    .frame(minWidth: 360, idealWidth: 400, maxWidth: 500)
            }
        }
        .overlay(alignment: .top) {
            if let toast = store.toast {
                ToastView(toast: toast)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 8)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: store.toast?.id)
    }
}
