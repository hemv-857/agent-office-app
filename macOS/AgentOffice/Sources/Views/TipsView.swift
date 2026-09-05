// TipsView.swift
import SwiftUI

struct TipsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var selectedCategory: TipsManager.TipCategory? = nil
    @State private var tips: [TipsManager.Tip] = []

    var filteredTips: [TipsManager.Tip] {
        if let category = selectedCategory {
            return tips.filter { $0.category == category }
        }
        return tips
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Tips & Tricks").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Category picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    FilterPill(title: "All", isSelected: selectedCategory == nil) {
                        selectedCategory = nil
                    }
                    ForEach(TipsManager.TipCategory.allCases, id: \.self) { category in
                        FilterPill(title: category.rawValue, isSelected: selectedCategory == category) {
                            selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }

            Divider()

            // Tips list
            if filteredTips.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "lightbulb").font(.largeTitle).foregroundStyle(.secondary)
                    Text("No tips available").foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredTips) { tip in
                            TipCard(tip: tip) {
                                dismissTip(tip.id)
                            }
                        }
                    }
                    .padding()
                }
            }

            Divider()

            // Actions
            HStack {
                Button("Dismiss All") {
                    TipsManager.shared.dismissAllTips()
                    dismiss()
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 450, height: 500)
        .onAppear {
            tips = TipsManager.shared.getTipsByCategory(.gettingStarted) +
                   TipsManager.shared.getTipsByCategory(.workflow) +
                   TipsManager.shared.getTipsByCategory(.shortcut) +
                   TipsManager.shared.getTipsByCategory(.agent) +
                   TipsManager.shared.getTipsByCategory(.advanced)
        }
    }

    func dismissTip(_ tipId: String) {
        TipsManager.shared.dismissTip(tipId)
        tips.removeAll { $0.id == tipId }
    }
}

// MARK: - Tip Card
struct TipCard: View {
    let tip: TipsManager.Tip
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(tip.title)
                    .font(.system(size: 12, weight: .semibold))
                Spacer()
                Text(tip.category.rawValue)
                    .font(.system(size: 9))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.blue.opacity(0.1), in: Capsule())
                    .foregroundStyle(.blue)
            }

            Text(tip.message)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)

            HStack {
                Spacer()
                Button("Dismiss") { onDismiss() }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
            }
        }
        .padding(12)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}
