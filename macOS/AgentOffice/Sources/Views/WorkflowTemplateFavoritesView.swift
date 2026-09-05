// WorkflowTemplateFavoritesView.swift
import SwiftUI

struct WorkflowTemplateFavoritesView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var favoriteIds: Set<String> = []

    private var favorites: [WorkflowTemplate] {
        WorkflowTemplates.all.filter { favoriteIds.contains($0.id) }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Favorite Templates").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            if favorites.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "star")
                        .font(.system(size: 32))
                        .foregroundStyle(.yellow)
                    Text("No favorites yet")
                        .font(.system(size: 12))
                    Text("Star templates to add them here")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(favorites) { template in
                            FavoriteTemplateRow(template: template)
                        }
                    }
                    .padding()
                }
            }

            Divider()

            HStack {
                Text("\(favorites.count) favorites")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 420, height: 400)
    }
}

// MARK: - Favorite Template Row
struct FavoriteTemplateRow: View {
    let template: WorkflowTemplate

    var body: some View {
        HStack(spacing: 10) {
            Text(template.icon).font(.system(size: 16))
            VStack(alignment: .leading) {
                Text(template.label).font(.system(size: 11, weight: .medium))
                Text(template.description)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            Text(template.workflowMode.rawValue.capitalized)
                .font(.system(size: 9))
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(.blue.opacity(0.1), in: Capsule())
                .foregroundStyle(.blue)
        }
        .padding(8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
    }
}
