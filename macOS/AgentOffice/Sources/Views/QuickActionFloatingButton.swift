// QuickActionFloatingButton.swift
import SwiftUI

struct QuickActionFloatingButton: View {
    @EnvironmentObject var store: AppStore
    @State private var isExpanded = false

    private let actions: [(String, String, () -> Void)] = [
        ("play.fill", "Run All", {}),
        ("plus.circle", "New Agent", {}),
        ("command", "Command Palette", {}),
        ("gearshape", "Settings", {}),
    ]

    var body: some View {
        VStack(spacing: 8) {
            if isExpanded {
                ForEach(Array(actions.enumerated()), id: \.offset) { index, action in
                    Button(action: {
                        isExpanded = false
                        action.2()
                    }) {
                        Image(systemName: action.0)
                            .font(.system(size: 14))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.accentColor, in: Circle())
                            .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                    }
                    .buttonStyle(.plain)
                    .transition(.scale.combined(with: .opacity))
                }
            }

            Button(action: {
                withAnimation(.spring(response: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                Image(systemName: isExpanded ? "xmark" : "plus")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(Color.accentColor, in: Circle())
                    .shadow(color: .black.opacity(0.3), radius: 6, y: 3)
            }
            .buttonStyle(.plain)
        }
        .padding()
    }
}
