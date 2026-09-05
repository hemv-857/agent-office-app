// BadgeView.swift
import SwiftUI

struct BadgeView: View {
    let count: Int
    var color: Color = .red

    var body: some View {
        if count > 0 {
            Text("\(min(count, 99))")
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(color, in: Capsule())
                .frame(minWidth: 16)
        }
    }
}

// MARK: - View Extension for Badges
extension View {
    func withBadge(_ count: Int, color: Color = .red) -> some View {
        overlay(
            VStack {
                HStack {
                    Spacer()
                    BadgeView(count: count, color: color)
                        .offset(x: 4, y: -4)
                }
                Spacer()
            }
        )
    }
}
