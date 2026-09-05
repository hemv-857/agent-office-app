// CommandHistoryView.swift
import SwiftUI

struct CommandHistoryView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @StateObject private var historyManager = CommandHistoryManager.shared
    @State private var searchText = ""
    @State private var selectedTab = "history"
    @State private var showingCreateMacro = false
    @State private var newMacroName = ""

    private var filteredHistory: [CommandHistoryManager.CommandEntry] {
        if searchText.isEmpty { return historyManager.history }
        return historyManager.history.filter {
            $0.command.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Command History").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Tab picker
            Picker("", selection: $selectedTab) {
                Text("History").tag("history")
                Text("Macros").tag("macros")
                Text("Stats").tag("stats")
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 8)

            // Search (only in history tab)
            if selectedTab == "history" {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                    TextField("Search commands...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(8)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal)
                .padding(.vertical, 8)
            }

            // Content
            switch selectedTab {
            case "history":
                historyList
            case "macros":
                macrosList
            case "stats":
                statsView
            default:
                historyList
            }

            Divider()

            HStack {
                Text("\(historyManager.history.count) commands")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                if selectedTab == "macros" {
                    Button("New Macro") { showingCreateMacro = true }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                }
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 500, height: 450)
        .sheet(isPresented: $showingCreateMacro) {
            CreateMacroView(name: $newMacroName, onSave: createMacro)
        }
    }

    // MARK: - History List
    var historyList: some View {
        if filteredHistory.isEmpty {
            return AnyView(
                VStack(spacing: 12) {
                    Image(systemName: "clock.arrow.circlepath").font(.largeTitle).foregroundStyle(.secondary)
                    Text("No command history").foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
        } else {
            return AnyView(
                List {
                    ForEach(filteredHistory) { entry in
                        HistoryRow(entry: entry)
                    }
                }
            )
        }
    }

    // MARK: - Macros List
    var macrosList: some View {
        if historyManager.macros.isEmpty {
            return AnyView(
                VStack(spacing: 12) {
                    Image(systemName: "command").font(.largeTitle).foregroundStyle(.secondary)
                    Text("No macros saved").foregroundStyle(.secondary)
                    Text("Create macros to automate repetitive tasks")
                        .font(.caption).foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
        } else {
            return AnyView(
                List {
                    ForEach(historyManager.macros) { macro in
                        MacroRow(macro: macro) {
                            historyManager.runMacro(macro)
                            store.showToast("Macro '\(macro.name)' executed", type: .success)
                        } onDelete: {
                            historyManager.deleteMacro(macro)
                        }
                    }
                }
            )
        }
    }

    // MARK: - Stats View
    var statsView: some View {
        let counts = historyManager.getCommandCounts()
        let sorted = counts.sorted { $0.value > $1.value }

        return AnyView(
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Most Used Commands").font(.system(size: 12, weight: .semibold))
                    ForEach(Array(sorted.prefix(10)), id: \.key) { item in
                        HStack {
                            Text(item.key)
                                .font(.system(size: 11))
                            Spacer()
                            Text("\(item.value) times")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundStyle(.secondary)
                            ProgressView(value: Double(item.value), total: Double(sorted.first?.value ?? 1))
                                .frame(width: 80)
                        }
                    }
                }
                .padding()
            }
        )
    }

    func createMacro() {
        let recentCommands = historyManager.getRecentCommands(5)
        historyManager.createMacro(name: newMacroName, commands: recentCommands)
        newMacroName = ""
        showingCreateMacro = false
    }
}

// MARK: - History Row
struct HistoryRow: View {
    let entry: CommandHistoryManager.CommandEntry

    var body: some View {
        HStack {
            Image(systemName: entry.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(entry.success ? .green : .red)
                .font(.system(size: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.command)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                if !entry.arguments.isEmpty {
                    Text(entry.arguments.joined(separator: " "))
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(entry.timestamp, style: .time)
                    .font(.system(size: 9))
                    .foregroundStyle(.tertiary)
                if let duration = entry.duration {
                    Text(String(format: "%.2fs", duration))
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Macro Row
struct MacroRow: View {
    let macro: CommandHistoryManager.Macro
    let onRun: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(macro.name).font(.system(size: 12, weight: .medium))
                    Text("\(macro.commands.count) commands")
                        .font(.system(size: 9))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 3))
                    Text("Run \(macro.runCount)x")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                Text(macro.commands.joined(separator: " → "))
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            HStack(spacing: 4) {
                Button(action: onRun) {
                    Image(systemName: "play.fill")
                }
                .buttonStyle(.bordered)
                .controlSize(.mini)

                Button(action: onDelete) {
                    Image(systemName: "trash")
                }
                .buttonStyle(.bordered)
                .controlSize(.mini)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Create Macro View
struct CreateMacroView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var name: String
    let onSave: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Create Macro").font(.headline)

            TextField("Macro Name", text: $name)
                .textFieldStyle(.roundedBorder)

            Text("Will save last 5 commands as a macro")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                Button("Cancel") { dismiss() }.buttonStyle(.bordered)
                Button("Create") { onSave() }
                    .buttonStyle(.borderedProminent)
                    .disabled(name.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 350)
    }
}
