// CustomAgentView.swift
import SwiftUI

struct CustomAgentView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var division = ""
    @State private var role = ""
    @State private var description = ""
    @State private var systemPrompt = ""

    var isValid: Bool {
        !name.isEmpty && !division.isEmpty && !systemPrompt.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Create Custom Agent").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            Form {
                TextField("Name", text: $name)
                TextField("Division", text: $division)
                TextField("Office Role (e.g. Architect)", text: $role)
                TextField("Description", text: $description)

                VStack(alignment: .leading, spacing: 4) {
                    Text("System Prompt *").font(.caption).foregroundStyle(.secondary)
                    TextEditor(text: $systemPrompt)
                        .font(.system(size: 12, design: .monospaced))
                        .frame(minHeight: 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.secondary.opacity(0.2))
                        )
                }
            }
            .formStyle(.grouped)

            Divider()

            HStack {
                Spacer()
                Button("Cancel") { dismiss() }.buttonStyle(.bordered)
                Button("Create Agent") {
                    let agent = Agent(
                        id: "custom-\(UUID().uuidString.prefix(8))",
                        name: name,
                        description: description.isEmpty ? "Custom agent" : description,
                        division: division,
                        officeRole: role.isEmpty ? "Specialist" : role,
                        systemPrompt: systemPrompt,
                        emoji: "",
                        color: "#6366f1",
                        domain: "Custom",
                        isCustom: true
                    )
                    store.allAgents.append(agent)
                    store.showToast("Created \(agent.name)", type: .success)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isValid)
            }
            .padding()
        }
        .frame(width: 450, height: 500)
    }
}
