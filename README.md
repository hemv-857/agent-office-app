# Agent Office

A native macOS SwiftUI app that manages a multi-agent AI workspace. Seat specialized AI personas in an office layout, send prompts to selected agents, stream LLM responses, and orchestrate multi-agent workflows.

## Stack

- **Platform:** macOS 14+ (Sonoma)
- **Language:** Swift 5.9+
- **UI:** SwiftUI
- **LLM Providers:** Anthropic Claude, OpenAI GPT-4o, Ollama (local)

## Quick Start

```bash
cd macOS/AgentOffice
swift build
swift run
```

Or open `macOS/AgentOffice` in Xcode and hit Run.

**Requirements:**
- macOS 14+ (Sonoma)
- Swift 5.9+
- Xcode 15+ (for IDE support)

## Architecture

```
macOS/AgentOffice/Sources/
├── AgentOfficeApp.swift          # @main App, NSApplicationDelegate, menu commands
├── Models/
│   └── Models.swift              # All types: Agent, Desk, WorkflowMode, etc.
├── Services/
│   ├── AppStore.swift            # Central state management (@MainActor ObservableObject)
│   ├── LLMService.swift          # Anthropic/OpenAI/Ollama with streaming SSE
│   ├── GitService.swift          # Actor-based git operations
│   ├── VoiceService.swift        # SFSpeechRecognizer integration
│   ├── WorkflowTemplates.swift   # 15 hardcoded workflow templates
│   ├── AgentMemoryManager.swift  # Per-agent memory persistence
│   ├── AgentSkillTracker.swift   # Agent skill tracking and ratings
│   ├── AgentCollaborationMatrix.swift  # Agent collaboration tracking
│   ├── AgentAvailabilityTracker.swift  # Agent availability and queues
│   ├── WorkflowOptimizer.swift   # Workflow optimization suggestions
│   ├── WorkflowScheduler.swift   # Scheduled workflow execution
│   ├── WorkflowChainBuilder.swift # Complex multi-step workflows
│   ├── WorkflowAnalyticsService.swift  # Workflow analytics and trends
│   ├── NotificationService.swift # System notifications
│   ├── ThemeManager.swift        # App theming
│   ├── PerformanceMonitor.swift  # Performance metrics
│   ├── CacheManager.swift        # In-memory caching
│   ├── DataExportService.swift   # Data export
│   ├── DataImportService.swift   # Data import
│   ├── BackupManager.swift       # Backup management
│   ├── PluginManager.swift       # Plugin system
│   ├── CommandRegistry.swift     # Custom commands
│   └── WebhookService.swift      # Webhook integrations
├── Views/
│   └── ... (35+ view files)
├── Tests/
│   └── AgentOfficeTests.swift    # Comprehensive test suite
├── Assets.xcassets/              # App icon (128/256/512/1024px)
└── agents.json                   # Agent catalog (~290 entries)
```

### Data Flow

```
User Prompt → AppStore.executeWorkflow()
    → LLMService.execute() / stream()
        → Anthropic/OpenAI/Ollama API
            → Streaming tokens → AppStore
                → ResultsPanel / ChatView
```

## Key Concepts

### Office Roles
8 fixed desks: `dev`, `qa`, `ops`, `arch`, `pm`, `res`, `gate`, `designer`. Drag agents from the sidebar to seat them, or use keyboard shortcuts ⌘1-8.

### Workflow Modes
- **Parallel:** All seated agents receive the same prompt simultaneously
- **Pipeline:** Each agent receives the previous agent's output as context
- **Synthesis:** Run agents in parallel, then synthesize a combined response
- **Review:** Agents review each other's outputs
- **Debate:** Agents argue different sides of a topic
- **Quality Gate:** Sequential review with approval gates
- **Pipeline Approval:** Pipeline with human approval between steps
- **Conditional:** Branch based on agent responses
- **Collab:** Collaborative editing across agents
- **Builder:** Step-by-step construction workflow

### Workflow Templates
15 pre-built templates for common tasks:
- Code review, feature implementation, bug investigation
- API design, database design, security audit
- Performance optimization, documentation, testing
- Architecture review, refactoring, migration planning
- UI/UX design, DevOps setup, project planning

### Agent System
- **Skill Tracking:** Track agent performance, ratings, and specializations
- **Collaboration Matrix:** Track which agents work well together
- **Availability:** Manage agent availability and task queues
- **Optimization:** Get suggestions for improving workflow efficiency

### Workflow Engine
- **Scheduling:** Schedule workflows with daily/weekly/monthly recurrence
- **Chains:** Build complex multi-step workflows with conditions
- **Analytics:** Track workflow performance and trends
- **History:** View complete workflow execution history

### Persistence
All data stored in UserDefaults:
- Settings, API keys, provider selection
- Desk assignments, groups, presets
- Agent favorites, prompt history
- Chat history, session notes
- Cost history, activity log
- Agent memory (per-agent, 100-entry limit)
- Workflow history, analytics
- Backups, webhooks, plugins

### Keyboard Shortcuts
- `⌘K` — Command palette
- `⌘1-8` — Select desk
- `⌘↑/↓` — Prompt history
- `⌘L` — Clear prompt
- `⌘E` — Export results
- `?` — Help

## Features

### Core
- **Streaming LLM Support:** Real-time token streaming via SSE for all providers
- **Voice Input:** Speech-to-text via Speech framework
- **Drag & Drop:** Drag agents to desks, reorder workflow steps
- **Agent Favorites:** Star agents for quick access
- **Template Auto-Seating:** Templates automatically seat required agents

### Agent Management
- **Skill Tracking:** Track agent performance and ratings
- **Collaboration Matrix:** See which agents work well together
- **Availability:** Manage agent availability and queues
- **Performance Metrics:** View agent usage and efficiency

### Workflow Engine
- **10 Workflow Modes:** Parallel, pipeline, synthesis, review, debate, and more
- **15 Templates:** Pre-built templates for common tasks
- **Scheduling:** Schedule workflows with recurrence
- **Chains:** Build complex multi-step workflows
- **History:** View complete workflow execution history

### Data & Export
- **Export:** Markdown/JSON export of results, notes, and chat history
- **Import:** Import data from JSON files
- **Backups:** Create, restore, and manage backups
- **Webhooks:** Integrate with external services

### UI/UX
- **Themes:** Multiple app themes (auto, light, dark, ocean, forest, sunset)
- **Animations:** Smooth animations and transitions
- **Skeleton Loading:** Skeleton loading placeholders
- **Context Window:** Visual utilization bar with backpressure
- **Budget Management:** Daily budget with cost tracking and alerts
- **Compare Mode:** Side-by-side response comparison

### Advanced
- **Plugin System:** Register and manage plugins
- **Custom Commands:** Create custom commands with triggers
- **Performance Monitoring:** Track memory, CPU, and API metrics
- **Caching:** In-memory cache with size limits

## Development

```bash
cd macOS/AgentOffice

# Build
swift build

# Run
swift run

# Clean
swift package clean

# Test
swift test
```

## Extending

### Adding a new agent
Edit `Sources/agents.json` — add an object with `id`, `name`, `division`, `description`, `systemPrompt`, `officeRole`.

### Adding a new LLM provider
1. Add case to `LLMProvider` enum in `Models.swift`
2. Implement `execute()` and `stream()` methods in `LLMService.swift`
3. Add provider option in Settings

### Adding a new workflow mode
1. Add case to `WorkflowMode` enum in `Models.swift`
2. Implement mode logic in `AppStore.swift` `executeWorkflow()`
3. Add UI toggle in `PromptBarView.swift`

### Adding a new workflow template
Add template to `WorkflowTemplates.swift` with name, description, prompt, workflow mode, and agent roles.

### Adding a plugin
1. Create a plugin class implementing the Plugin protocol
2. Register with `PluginManager.shared.registerPlugin()`
3. Add hooks for desired events

## Security

- API keys stored in UserDefaults (encrypted at rest on macOS)
- No telemetry, no external connections except LLM APIs
- All inputs validated at trust boundaries
- Webhook authentication via Bearer tokens

## Troubleshooting

**Build fails with "missing module"**
```bash
cd macOS/AgentOffice
swift package resolve
swift build
```

**App crashes on launch**
- Check Console.app for crash logs
- Ensure macOS 14+ is installed
- Verify `agents.json` is accessible

**LLM connection issues**
- Verify API key in Settings > Provider
- Check network connectivity
- For Ollama: ensure `ollama serve` is running

**Voice input not working**
- Grant microphone permission in System Settings > Privacy & Security
- Ensure Speech Recognition is enabled

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

MIT — Copyright 2026 Hemang
