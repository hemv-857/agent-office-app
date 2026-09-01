# Agent Office

A Tauri desktop app that manages a multi-agent AI workspace. Seat specialized AI personas in an office layout, send prompts to selected agents, stream LLM responses, and orchestrate multi-agent workflows.

## Stack

- **Frontend:** React 19 + TypeScript + Vite
- **Backend:** Rust + Tauri 2
- **LLM Providers:** Anthropic Claude, OpenAI GPT-4o (extensible provider registry)

## Quick Start

```bash
npm install
npm run tauri dev
```

## Architecture

```
src/
├── App.tsx                     # Thin shell — layout + wiring (~400 lines)
├── App.css                     # All styles (dark/light themes, 1700+ lines)
├── types.ts                    # Shared TypeScript interfaces
├── utils/
│   ├── constants.ts            # Roles, colors, templates, storage keys
│   ├── storage.ts              # Typed localStorage helpers
│   └── export.ts               # Markdown/JSON export + download
├── hooks/
│   ├── useToast.ts             # Toast notifications
│   ├── useAgentCatalog.ts      # Agent list, custom agents, detail view
│   ├── useAgentSelection.ts    # Search, filter, favorites, selection
│   ├── useOffice.ts            # Desk layout, drag/drop, groups, presets
│   ├── useStreaming.ts         # SSE stream events, results, bookmarks, ratings
│   ├── useOrchestration.ts     # Run, suggest, pipeline, queue, activity log
│   ├── useWorkflows.ts         # 5 workflow modes (parallel, pipeline, synthesis, review, debate)
│   ├── useChat.ts              # 1:1 agent chat
│   ├── useSessionHistory.ts    # Session save/load/search/delete
│   └── useKeyboardShortcuts.ts # Global shortcuts (⌘K, ?, ⌘⇧Space)
└── components/
    ├── Sidebar.tsx             # Agent list, search, filters, groups, presets
    ├── OfficeGrid.tsx          # 8-desk role grid with drag/drop
    ├── ResultsPanel.tsx        # Results list, compare mode, bulk actions, analysis
    ├── PromptBar.tsx           # Prompt input, history, templates, suggestions
    ├── StatusBar.tsx           # Bottom status bar
    ├── ActivityLog.tsx         # Activity feed
    └── Modals.tsx              # Settings, help, agent detail, chat, perf, etc.

src-tauri/src/
├── main.rs                     # Tauri commands + session cancellation
├── lib.rs                      # Module declarations
├── agent/mod.rs                # Agent struct + registry
├── error.rs                    # Structured AppError with thiserror
├── llm/
│   ├── mod.rs                  # Provider trait + LLMRequest/Response types
│   ├── registry.rs             # ProviderRegistry with retry + fallback
│   ├── anthropic.rs            # Anthropic streaming implementation
│   └── openai.rs               # OpenAI streaming implementation
└── orchestration/mod.rs        # Orchestrator + task request types
```

### Data Flow

```
User Prompt → useOrchestration → Tauri execute_task
    → ProviderRegistry.execute_with_fallback
        → Provider.execute (with retry/backoff)
            → LLM API (Anthropic/OpenAI)
                → StreamEvent → Frontend via Tauri events
                    → useStreaming → ResultsPanel
```

## Key Concepts

### Office Roles
8 fixed desks: `dev`, `qa`, `ops`, `arch`, `pm`, `res`, `gate`, `designer`. Drag agents from the sidebar to seat them.

### Orchestration Modes
- **Parallel:** All selected agents receive the same prompt simultaneously
- **Pipeline:** Each agent receives the previous agent's output as context
- **Synthesis:** Run agents in parallel, then synthesize a combined response
- **Review:** Agents review each other's outputs
- **Debate:** Agents argue different sides of a topic
- **Head Agent (✨):** LLM-powered agent recommendation based on your prompt

### Persistence
Settings, seats, groups, presets, favorites, prompt history, and sessions are stored in localStorage. Export/import layouts as JSON.

### Comparison Mode
Click the `⟺` button in Results header to enter compare mode:
- Side-by-side agent responses
- Summary stats: agents, avg tokens, fastest/slowest, total cost
- **Shared themes:** Keywords appearing in >50% of responses
- **Response length bars:** Visual comparison of response sizes

## Development

```bash
npm run dev          # Vite dev server
npm run build        # TypeScript + Vite production build
npm run tauri dev    # Full Tauri dev (Rust + React hot reload)
npm run tauri build  # Production Tauri bundle

# Frontend tests
npm test             # Vitest (48 tests)
npm run test:watch   # Watch mode

# Rust tests
cd src-tauri && cargo test
```

## Extending

### Adding a new agent
Edit `public/agents.json` — add an object with `id`, `name`, `division`, `description`, `systemPrompt`, `officeRole`, `emoji`, `tags`.

### Adding a new LLM provider
1. Create a new file in `src-tauri/src/llm/` implementing the `Provider` trait
2. Add it to `ProviderRegistry::new()` in `registry.rs`
3. Add provider option in Settings modal

### Adding a new workflow mode
Add mode logic in `src/hooks/useWorkflows.ts`, add UI toggle in `PromptBar.tsx`.

## Security

- API keys stored in memory only (not persisted to disk)
- Key format validation: `sk-ant-` for Anthropic, `sk-` for OpenAI
- No telemetry, no external connections except LLM APIs

## License

MIT
