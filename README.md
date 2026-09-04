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
│   └── AgentMemoryManager.swift  # Per-agent memory persistence
└── Views/
    ├── ContentView.swift         # HSplitView layout, sheet bindings, keyboard shortcuts
    ├── SidebarView.swift         # Agent list, search, filters, favorites, groups/presets
    ├── OfficeGridView.swift      # 4x2 desk grid with drag-and-drop
    ├── HeaderView.swift          # Title, workflow progress, run/stop, provider badge
    ├── PromptBarView.swift       # Template picker, history, voice input, workflow mode
    ├── ResultsPanelView.swift    # Results with rating, bookmark, compare mode
    ├── StatusBarView.swift       # Context window, budget, cost breakdown
    ├── ToastView.swift           # Success/error/info/warning notifications
    ├── SettingsView.swift        # Tabbed settings (General, Provider, Budget, Advanced)
    ├── HelpView.swift            # Tabbed shortcuts/about
    ├── CommandPaletteView.swift  # Searchable command list (⌘K)
    ├── OnboardingView.swift      # 7-step wizard with provider setup
    ├── AgentDetailView.swift     # Agent info, seat/remove, copy prompt
    ├── ChatView.swift            # Chat with agent messages
    ├── CostTrackerView.swift     # Cost by agent, summary cards
    ├── LeaderboardView.swift     # Ranked agent list
    ├── PipelineVisualizerView.swift  # Step-by-step pipeline view
    ├── SessionNotesView.swift    # Notes with tag filter
    ├── ActivityLogView.swift     # Filtered activity log
    ├── ExportView.swift          # All/selected/bookmarked, MD/JSON
    ├── AgentMemoryView.swift     # Memory entries with confidence
    ├── CustomAgentView.swift     # Create custom agents
    ├── ProjectBuilderView.swift  # Project scaffolding prompt builder
    ├── SessionReplayView.swift   # Timeline scrubbing, play/pause
    ├── WorkflowLogView.swift     # Real-time activity log
    ├── WorkflowStepsView.swift   # Custom workflow steps with drag-reorder
    └── KeyboardShortcutsHelpView.swift  # Organized shortcut sections
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

### Persistence
All data stored in UserDefaults:
- Settings, API keys, provider selection
- Desk assignments, groups, presets
- Agent favorites, prompt history
- Chat history, session notes
- Cost history, activity log
- Agent memory (per-agent, 100-entry limit)

### Keyboard Shortcuts
- `⌘K` — Command palette
- `⌘1-8` — Select desk
- `⌘↑/↓` — Prompt history
- `⌘L` — Clear prompt
- `⌘E` — Export results
- `?` — Help

## Development

```bash
cd macOS/AgentOffice

# Build
swift build

# Run
swift run

# Clean
swift package clean
```

## Features

- **Streaming LLM Support:** Real-time token streaming via SSE for all providers
- **Voice Input:** Speech-to-text via Speech framework
- **Drag & Drop:** Drag agents to desks, reorder workflow steps
- **Agent Favorites:** Star agents for quick access
- **Template Auto-Seating:** Templates automatically seat required agents
- **Context Window Tracking:** Visual utilization bar with backpressure
- **Budget Management:** Daily budget with cost tracking and alerts
- **Compare Mode:** Side-by-side response comparison
- **Session Replay:** Timeline scrubbing through past sessions
- **Export:** Markdown/JSON export of results, notes, and chat history
- **Custom Agents:** Create and manage custom AI personas
- **Git Integration:** Branch, diff, commit, push operations
- **Activity Log:** Real-time workflow activity tracking
- **App Icon:** Custom icon in Assets.xcassets

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

## Security

- API keys stored in UserDefaults (encrypted at rest on macOS)
- No telemetry, no external connections except LLM APIs
- All inputs validated at trust boundaries

## License

MIT — Copyright 2026 Hemang
