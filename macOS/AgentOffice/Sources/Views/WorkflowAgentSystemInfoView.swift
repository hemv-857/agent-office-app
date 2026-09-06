// WorkflowAgentSystemInfoView.swift
import SwiftUI

struct WorkflowAgentSystemInfoView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let info: [(String, String)] = [
        ("App Name", "Agent Office"),
        ("Version", "1.0.0"),
        ("Build", "341"),
        ("Platform", "macOS"),
        ("Swift Version", "5.9"),
        ("Min OS", "macOS 14.0"),
        ("Bundle ID", "com.agent-office.app"),
        ("Total Views", "280"),
        ("Total Services", "36"),
        ("Total Commands", "179+"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("System Info").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 4) {
                    ForEach(info.indices, id: \.self) { i in
                        HStack {
                            Text(info[i].0)
                                .font(.system(size: 11, weight: .medium))
                                .frame(width: 100, alignment: .leading)
                            Spacer()
                            Text(info[i].1)
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 400, height: 400)
    }
}
