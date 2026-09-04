// ProjectBuilderView.swift
import SwiftUI

struct ProjectBuilderView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var projectName = ""
    @State private var projectType = "iOS App"
    @State private var description = ""
    @State private var includeTests = true
    @State private var includeCI = false

    let projectTypes = ["iOS App", "macOS App", "Swift Package", "CLI Tool", "Web API", "Library"]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Project Builder").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            Form {
                TextField("Project Name", text: $projectName)
                Picker("Type", selection: $projectType) {
                    ForEach(projectTypes, id: \.self) { Text($0) }
                }
                TextField("Description", text: $description)
                Toggle("Include Tests", isOn: $includeTests)
                Toggle("Include CI/CD", isOn: $includeCI)
            }
            .formStyle(.grouped)

            Divider()

            HStack {
                Spacer()
                Button("Cancel") { dismiss() }.buttonStyle(.bordered)
                Button("Build Plan") {
                    let prompt = buildPrompt()
                    store.promptText = prompt
                    store.workflowMode = .pipeline
                    dismiss()
                    store.showToast("Build plan queued", type: .info)
                }
                .buttonStyle(.borderedProminent)
                .disabled(projectName.isEmpty)
            }
            .padding()
        }
        .frame(width: 450, height: 400)
    }

    func buildPrompt() -> String {
        var parts = ["Create a \(projectType) called '\(projectName)'."]
        if !description.isEmpty { parts.append("Description: \(description)") }
        if includeTests { parts.append("Include a test suite with 80%+ coverage.") }
        if includeCI { parts.append("Include GitHub Actions CI/CD pipeline.") }
        parts.append("Scaffold the full project structure with all necessary files.")
        return parts.joined(separator: " ")
    }
}
