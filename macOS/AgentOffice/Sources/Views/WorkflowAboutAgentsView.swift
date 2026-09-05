// WorkflowAboutAgentsView.swift
import SwiftUI

struct WorkflowAboutAgentsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("About Agents").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 12) {
                    // Agent count
                    VStack(spacing: 8) {
                        Text("\(store.allAgents.count)")
                            .font(.system(size: 32, weight: .bold))
                        Text("Total Agents")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }

                    // Divisions
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Divisions").font(.system(size: 12, weight: .semibold))
                        let divisions = Set(store.allAgents.map(\.division))
                        ForEach(Array(divisions).sorted(), id: \.self) { division in
                            HStack {
                                Text(division)
                                    .font(.system(size: 11))
                                Spacer()
                                Text("\(store.allAgents.filter { $0.division == division }.count)")
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))

                    // Roles
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Roles").font(.system(size: 12, weight: .semibold))
                        let roles = Set(store.allAgents.map(\.officeRole))
                        ForEach(Array(roles).sorted().prefix(5), id: \.self) { role in
                            HStack {
                                Text(role)
                                    .font(.system(size: 11))
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
                }
                .padding()
            }

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 400, height: 450)
    }
}
