// CommandRegistryView.swift
import SwiftUI

struct CommandRegistryView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var commands: [CommandRegistry.CustomCommand] = []
    @State private var showingAddCommand = false
    @State private var newCommandName = ""
    @State private var newCommandTrigger = ""
    @State private var newCommandDescription = ""
    @State private var selectedCategory: CommandRegistry.CommandCategory = .workflow

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Custom Commands").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Command list
            if commands.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "command").font(.largeTitle).foregroundStyle(.secondary)
                    Text("No custom commands").foregroundStyle(.secondary)
                    Text("Create commands to speed up your workflow")
                        .font(.caption).foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(commands) { command in
                        CommandRow(command: command) {
                            toggleCommand(command)
                        } onDelete: {
                            deleteCommand(command)
                        }
                    }
                }
            }

            Divider()

            // Actions
            HStack {
                Button("Add Command") { showingAddCommand = true }
                    .buttonStyle(.borderedProminent)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 500, height: 400)
        .sheet(isPresented: $showingAddCommand) {
            AddCommandView(
                name: $newCommandName,
                trigger: $newCommandTrigger,
                description: $newCommandDescription,
                category: $selectedCategory,
                onSave: addCommand
            )
        }
        .onAppear {
            commands = CommandRegistry.shared.commands
        }
    }

    func addCommand() {
        let command = CommandRegistry.CustomCommand(
            id: UUID().uuidString,
            name: newCommandName,
            description: newCommandDescription,
            trigger: newCommandTrigger,
            action: .runWorkflow(mode: .parallel, prompt: ""),
            category: selectedCategory,
            isActive: true
        )
        CommandRegistry.shared.registerCommand(command)
        commands = CommandRegistry.shared.commands
        newCommandName = ""
        newCommandTrigger = ""
        newCommandDescription = ""
        showingAddCommand = false
    }

    func toggleCommand(_ command: CommandRegistry.CustomCommand) {
        CommandRegistry.shared.toggleCommand(id: command.id)
        commands = CommandRegistry.shared.commands
    }

    func deleteCommand(_ command: CommandRegistry.CustomCommand) {
        CommandRegistry.shared.unregisterCommand(id: command.id)
        commands = CommandRegistry.shared.commands
    }
}

// MARK: - Command Row
struct CommandRow: View {
    let command: CommandRegistry.CustomCommand
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(command.name).font(.system(size: 12, weight: .medium))
                    Text(command.trigger)
                        .font(.system(size: 10, design: .monospaced))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 3))
                        .foregroundStyle(.blue)
                    Text(command.category.rawValue)
                        .font(.system(size: 9))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 3))
                }
                Text(command.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 8) {
                Toggle("", isOn: Binding(
                    get: { command.isActive },
                    set: { _ in onToggle() }
                ))
                .toggleStyle(.switch)
                .controlSize(.small)

                Button(action: onDelete) {
                    Image(systemName: "trash")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add Command View
struct AddCommandView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var name: String
    @Binding var trigger: String
    @Binding var description: String
    @Binding var category: CommandRegistry.CommandCategory
    let onSave: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Add Command").font(.headline)

            TextField("Command Name", text: $name)
                .textFieldStyle(.roundedBorder)

            TextField("Trigger (e.g., /mycommand)", text: $trigger)
                .textFieldStyle(.roundedBorder)

            TextField("Description", text: $description)
                .textFieldStyle(.roundedBorder)

            Picker("Category", selection: $category) {
                ForEach(CommandRegistry.CommandCategory.allCases, id: \.self) { cat in
                    Text(cat.rawValue).tag(cat)
                }
            }

            HStack {
                Button("Cancel") { dismiss() }.buttonStyle(.bordered)
                Button("Add") { onSave() }
                    .buttonStyle(.borderedProminent)
                    .disabled(name.isEmpty || trigger.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 380)
    }
}
