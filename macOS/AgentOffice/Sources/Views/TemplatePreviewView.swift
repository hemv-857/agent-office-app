// TemplatePreviewView.swift
import SwiftUI

struct TemplatePreviewView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    let template: WorkflowTemplate

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.label).font(.headline)
                    Text(template.workflowMode.rawValue.capitalized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Description
                    GroupBox("Description") {
                        Text(template.description)
                            .font(.system(size: 12))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Workflow mode
                    GroupBox("Workflow Mode") {
                        HStack {
                            Image(systemName: workflowModeIcon)
                                .foregroundStyle(.blue)
                            Text(template.workflowMode.rawValue.capitalized)
                                .font(.system(size: 12, weight: .medium))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Required agents
                    GroupBox("Required Agents") {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(template.agentRoles, id: \.self) { role in
                                HStack {
                                    Image(systemName: "person.circle")
                                        .foregroundStyle(.secondary)
                                    Text(role.capitalized)
                                        .font(.system(size: 12))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Prompt preview
                    GroupBox("Prompt") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            Text(template.prompt)
                                .font(.system(size: 11, design: .monospaced))
                                .textSelection(.enabled)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
            }

            Divider()

            // Actions
            HStack {
                Button("Cancel") { dismiss() }
                    .buttonStyle(.bordered)
                Spacer()
                Button(action: applyTemplate) {
                    Label("Apply Template", systemImage: "checkmark")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 450, height: 500)
    }

    var workflowModeIcon: String {
        switch template.workflowMode {
        case .parallel: return "square.stack"
        case .pipeline: return "arrow.right"
        case .synthesis: return "sparkles"
        case .review: return "magnifyingglass"
        case .debate: return "bubble.left.and.bubble.right"
        case .qualityGate: return "checkmark.shield"
        case .pipelineApproval: return "hand.thumbsup"
        case .conditional: return "arrow.triangle.branch"
        case .collab: return "person.2.wave.2"
        case .builder: return "hammer"
        }
    }

    func applyTemplate() {
        store.promptText = template.prompt
        store.workflowMode = template.workflowMode
        // Auto-seat agents
        autoSeatAgents(for: template)
        dismiss()
    }

    func autoSeatAgents(for template: WorkflowTemplate) {
        store.clearOffice()

        let roleMap: [String: AgentRole] = [
            "pm": .pm, "ux": .ux, "dev": .dev, "qa": .qa,
            "be": .be, "data": .data, "ts": .ts, "support": .support,
            "arch": .arch, "res": .res, "designer": .designer, "ops": .ops
        ]

        let divisionMap: [String: String] = [
            "pm": "PM", "ux": "Researcher", "dev": "Builder", "qa": "QA",
            "be": "Builder", "data": "Researcher", "ts": "Builder", "support": "Support",
            "arch": "Architect", "res": "Researcher", "designer": "Researcher", "ops": "Support"
        ]

        for roleStr in template.agentRoles {
            guard let role = roleMap[roleStr] else { continue }
            guard let desk = store.desks.first(where: { $0.role == role && !$0.isOccupied }) else { continue }

            let division = divisionMap[roleStr] ?? "Builder"
            if let agent = store.allAgents.first(where: { $0.division == division }) {
                store.seatAgent(agent, at: role)
            }
        }
    }
}
