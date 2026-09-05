// WorkflowQuickActionsMenu.swift
import SwiftUI

struct WorkflowQuickActionsMenu: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let actions: [(String, String, () -> Void)] = [
        ("Run Workflow", "play.fill", { }),
        ("Clear Office", "xmark.circle", { }),
        ("Save Session", "square.and.arrow.down", { }),
        ("Export Results", "square.and.arrow.up", { }),
        ("Show Settings", "gear", { }),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Quick Actions").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            VStack(spacing: 4) {
                ForEach(actions.indices, id: \.self) { index in
                    Button(action: {
                        actions[index].2()
                        dismiss()
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: actions[index].1)
                                .font(.system(size: 12))
                                .foregroundStyle(.blue)
                                .frame(width: 16)
                            Text(actions[index].0)
                                .font(.system(size: 11))
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 8)

            Spacer()
        }
        .frame(width: 250, height: 280)
    }
}
