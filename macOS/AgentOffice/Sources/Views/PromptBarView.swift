// PromptBarView.swift
import SwiftUI

struct PromptBarView: View {
    @EnvironmentObject var store: AppStore
    @FocusState private var isInputFocused: Bool
    @State private var showTemplates = false
    @StateObject private var voiceService = VoiceService()
    @State private var historyIndex = -1

    var body: some View {
        VStack(spacing: 0) {
            Divider()

            HStack(spacing: 10) {
                // Template picker
                Button(action: { showTemplates = true }) {
                    Image(systemName: "square.grid.2x2")
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .help("Workflow Templates")

                // Prompt history
                if !store.promptHistory.isEmpty {
                    Menu {
                        ForEach(Array(store.promptHistory.prefix(20).enumerated()), id: \.offset) { idx, prompt in
                            Button(action: { store.promptText = prompt }) {
                                Text(prompt.prefix(60) + (prompt.count > 60 ? "..." : ""))
                                    .font(.system(size: 11))
                            }
                        }
                        Divider()
                        Button(action: { store.promptHistory.removeAll() }) {
                            Label("Clear History", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 12))
                    }
                    .menuStyle(.borderlessButton)
                    .frame(width: 20)
                    .help("Prompt History")
                }

                // Workflow mode picker
                Picker("", selection: $store.workflowMode) {
                    ForEach(WorkflowMode.allCases, id: \.self) { mode in
                        Text(mode.label).tag(mode)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 140)

                // Text input
                TextField("Enter your prompt...", text: $store.promptText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(1...5)
                    .focused($isInputFocused)
                    .onSubmit { store.runAll() }

                // Voice input
                Button(action: toggleVoice) {
                    Image(systemName: voiceService.isRecording ? "waveform" : "mic")
                        .font(.system(size: 12))
                        .foregroundStyle(voiceService.isRecording ? .red : .secondary)
                        .frame(width: 24, height: 24)
                        .background(voiceService.isRecording ? .red.opacity(0.1) : Color.clear, in: RoundedRectangle(cornerRadius: 5))
                }
                .buttonStyle(.plain)
                .help(voiceService.isRecording ? "Stop recording" : "Voice input")
                .onChange(of: voiceService.recognizedText) { _, text in
                    if !text.isEmpty {
                        if store.promptText.isEmpty {
                            store.promptText = text
                        } else {
                            store.promptText += " " + text
                        }
                        voiceService.recognizedText = ""
                    }
                }

                // Run button
                Button(action: store.runAll) {
                    Image(systemName: store.isRunning ? "stop.fill" : "play.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 30, height: 30)
                        .background(store.isRunning ? .red : .green, in: RoundedRectangle(cornerRadius: 7))
                }
                .buttonStyle(.plain)
                .disabled(store.promptText.isEmpty && !store.isRunning)
                .keyboardShortcut(.return, modifiers: .command)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
        .background(.background)
        .sheet(isPresented: $showTemplates) { TemplatePickerView() }
        .onAppear {
            NotificationCenter.default.addObserver(forName: .promptHistoryUp, object: nil, queue: .main) { _ in
                guard !store.promptHistory.isEmpty else { return }
                historyIndex = min(historyIndex + 1, store.promptHistory.count - 1)
                store.promptText = store.promptHistory[historyIndex]
            }
            NotificationCenter.default.addObserver(forName: .promptHistoryDown, object: nil, queue: .main) { _ in
                historyIndex = max(historyIndex - 1, -1)
                store.promptText = historyIndex >= 0 ? store.promptHistory[historyIndex] : ""
            }
            NotificationCenter.default.addObserver(forName: .clearPrompt, object: nil, queue: .main) { _ in
                store.promptText = ""
                historyIndex = -1
            }
        }
    }

    func toggleVoice() {
        if voiceService.isRecording {
            voiceService.stopRecording()
        } else {
            voiceService.startRecording()
        }
    }
}

// MARK: - Template Picker
struct TemplatePickerView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var previewTemplate: WorkflowTemplate?

    var filtered: [WorkflowTemplate] {
        if searchText.isEmpty { return WorkflowTemplates.all }
        return WorkflowTemplates.all.filter {
            $0.label.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Workflow Templates").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            // Search
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass").font(.system(size: 10)).foregroundStyle(.secondary)
                TextField("Search templates...", text: $searchText).textFieldStyle(.plain)
            }
            .padding(6)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 5))
            .padding(.horizontal, 12)
            .padding(.bottom, 8)

            Divider()

            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10),
                ], spacing: 10) {
                ForEach(filtered) { template in
                    TemplateCard(template: template, onPreview: {
                        previewTemplate = template
                    }, onApply: {
                        store.promptText = template.prompt
                        store.workflowMode = template.workflowMode
                        autoSeatAgents(for: template)
                        dismiss()
                    })
                }
                }
                .padding()
            }
        }
        .frame(width: 620, height: 520)
        .sheet(item: $previewTemplate) { template in
            TemplatePreviewView(template: template)
        }
    }

    func autoSeatAgents(for template: WorkflowTemplate) {
        // Clear current office
        store.clearOffice()

        // Map role names to AgentRole
        let roleMap: [String: AgentRole] = [
            "pm": .pm, "ux": .ux, "dev": .dev, "qa": .qa,
            "be": .be, "data": .data, "ts": .ts, "support": .support,
            "arch": .arch, "res": .res, "designer": .designer, "ops": .ops
        ]

        // Seat agents for each role in template
        for roleStr in template.agentRoles {
            guard let role = roleMap[roleStr] else { continue }
            guard let desk = store.desks.first(where: { $0.role == role && !$0.isOccupied }) else { continue }

            // Find first agent matching this division/role
            let divisionMap: [String: String] = [
                "pm": "PM", "ux": "Researcher", "dev": "Builder", "qa": "QA",
                "be": "Builder", "data": "Researcher", "ts": "Builder", "support": "Support",
                "arch": "Architect", "res": "Researcher", "designer": "Researcher", "ops": "Support"
            ]
            let division = divisionMap[roleStr] ?? "Builder"
            if let agent = store.allAgents.first(where: { $0.division == division }) {
                store.seatAgent(agent, at: role)
            }
        }
    }
}

struct TemplateCard: View {
    let template: WorkflowTemplate
    let onPreview: () -> Void
    let onApply: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: template.icon)
                    .font(.system(size: 16))
                    .foregroundStyle(.blue)
                Spacer()
                Text(template.workflowMode.label)
                    .font(.system(size: 9, weight: .medium))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.blue.opacity(0.1), in: Capsule())
                    .foregroundStyle(.blue)
            }

            Text(template.label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.primary)

            Text(template.description)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack(spacing: 4) {
                ForEach(template.agentRoles, id: \.self) { role in
                    Text(role.uppercased())
                        .font(.system(size: 8, weight: .medium))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 3))
                }
            }

            HStack(spacing: 8) {
                Button(action: onPreview) {
                    Text("Preview")
                        .font(.system(size: 10))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Button(action: onApply) {
                    Text("Apply")
                        .font(.system(size: 10))
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
        )
    }
}
