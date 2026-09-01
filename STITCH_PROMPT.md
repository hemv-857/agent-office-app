# Stitch UI Redesign Prompt — Agent Office

## What This App Is

**Agent Office** is a Tauri desktop app (macOS/Windows/Linux) for orchestrating multiple AI agents. Users drag-and-drop AI personas into an "office" with 8 role desks, type a prompt, and all agents respond simultaneously. Think of it as a command center for running multiple LLM agents in parallel.

**Core metaphor:** You are a manager in an open-plan office. Each desk has a specialist (agent). You give instructions and watch them work.

---

## Current Layout (What Exists)

The app uses a **2-column layout** at full viewport (no scrolling):

```
┌──────────────────────────────────────────────────────────┐
│ [SIDEBAR 300px] │ [MAIN AREA]                            │
│                  │ ┌─────────────────────────────────────┐│
│ Search ──────────│─│ HEADER (50px)                       ││
│ [Filter pills]   │ │ Agent Office · 3/8 seated · ▶▶ ✕ ⚙ ││
│                  │ ├──────────────────────┬──────────────┤│
│ ── Groups ────── │ │                      │ RESULTS      ││
│ · Frontend Team  │ │   OFFICE GRID        │ PANEL        ││
│ · Backend Team   │ │   (4×2 desks)       │ (420px wide) ││
│                  │ │                      │              ││
│ ── Presets ──────│ │   ┌───┬───┬───┬───┐ │ ┌──────────┐ ││
│ · Morning Standup│ │   │PM │UX │DV│QA│ │ │ AgentName│ ││
│                  │ │   ├───┼───┼───┼───┤ │ │ response │ ││
│ ── Agents ──────│ │   │BE │DW │TS│  │ │ │ meta...  │ ││
│ [Agent list with │ │   └───┴───┴───┴───┘ │ └──────────┘ ││
│  emoji, name,    │ │                      │              ││
│  role, checkbox] │ │                      │              ││
│                  │ ├──────────────────────┴──────────────┤│
│                  │ │ PROMPT BAR                          ││
│                  │ │ [history] [templates] [textarea]    ││
│                  │ │ [suggest] [workflow] [▶] [+Q]      ││
│                  │ └─────────────────────────────────────┘│
│                  │ ┌─────────────────────────────────────┐│
│                  │ │ STATUS BAR (24px)                   ││
│                  │ │ 48 agents · 3/8 seated · $0.0042   ││
│                  │ └─────────────────────────────────────┘│
└──────────────────────────────────────────────────────────┘
```

### Current Color System (Dark Theme)
- Background layers: `#0f0f11` → `#18181b` → `#1e1e22` → `#27272a` → `#2e2e33`
- Accent: `#6391ff` (blue), green: `#34d399`, red: `#f87171`, yellow: `#fbbf24`
- Text: `#fafafa` (primary), `#a1a1aa` (secondary), `#71717a` (tertiary)
- Borders: `rgba(255,255,255,0.06)` subtle, `0.12` strong
- Light theme available with inverted values
- Font: Inter (400, 500, 600, 700)
- Border radius: 6px (sm), 10px (md), 14px (lg)

### Current Components

**1. Sidebar (left, 300px fixed)**
- Search bar with magnifying glass icon
- Filter pills: All, Architect, Builder, PM, Researcher, QA, Support, Custom
- Collapsible sections: Groups, Presets, Agents
- Agent list items: emoji (34px avatar), name, role, checkbox, favorite star
- Bottom toolbar: select all/deselect all, theme toggle, import/export, add agent/group/preset

**2. Header (top of main area, 50px)**
- Left: gradient icon (blue→purple), "Agent Office" title, seated count badge, running badge
- Right: provider badge (🟣 Anthropic / 🟢 OpenAI), run all button (▶▶), cancel (✕), results toggle (◀/▶), performance (📊), help (?), settings (⚙), compact toggle (🔼/🔽)

**3. Office Grid (center workspace)**
- 4×2 grid of desk slots, each 110px+ tall
- Empty desk: role label + faded "+" icon
- Occupied desk: role label, agent emoji (28px), agent name, status pill (idle/working/done/blocked)
- Desks have drag-over glow effect (blue border + scale 1.03)
- Occupied desks: blue border + blue-tinted background
- Click desk to remove agent, drag to swap

**4. Results Panel (right, 420px, togglable)**
- Header with search, compare toggle, select all, export buttons
- Result cards: agent emoji + name, status (completed/error), time, cost, expand/collapse
- Expanded card shows full response text
- Compare mode: keyword analysis, response length bars
- Actions per card: bookmark, thumbs up/down, copy, export, chat with agent

**5. Prompt Bar (bottom, above status bar)**
- Queue bar (if items queued): truncated prompts with × to remove, clear, run all
- Suggestions bar (if head agent suggested): agent tags, reasoning, dismiss
- Main row: history dropdown, templates dropdown, textarea (auto-resize), suggest button (✨), workflow mode selector (dropdown), submit (▶), add to queue (+Q)

**6. Status Bar (very bottom, 24px)**
- Left: agent count, seated count, provider, cost, tokens, running indicator
- Right: activity count (click to clear), version string

**7. Modals**
- Settings: API key inputs, provider selector, budget slider
- Help: keyboard shortcuts reference
- Agent Detail: full agent info with system prompt
- Chat: message thread with agent, input field
- Performance: per-agent stats table
- Group Save / Preset Save / Custom Agent forms

**8. Toast Notifications**
- Top-center, auto-dismiss 3s
- Types: success (green), error (red), info

**9. Activity Log**
- Slide-in panel from right edge
- Timestamped entries with type color coding

---

## Design Brief: What to Redesign

Create a **modern, polished, production-grade UI** for this agent orchestration desktop app. Keep the core metaphor (office with desks) but elevate the visual design significantly.

### Design Direction
- **Premium SaaS aesthetic** — think Linear, Vercel Dashboard, Raycast, Arc Browser
- **Glass morphism** where appropriate (subtle frosted glass on panels, modals)
- **Micro-interactions** — hover states, transitions, loading animations
- **Dense but breathable** — maximize information density without clutter
- **Professional but personality** — the agent emoji system is fun, keep it, but frame it in a more refined UI

### Key Redesign Opportunities

1. **Sidebar** — Could benefit from a more polished agent list with better visual hierarchy. Consider a command-palette style search (⌘K feel). Agent cards could show more context (last used, success rate).

2. **Office Grid** — The 4×2 desk grid is functional but feels basic. Explore:
   - Isometric or 3D desk visualization
   - Desk state animations (typing animation when working, checkmark when done)
   - Better empty state (ghost outline inviting drag)
   - Agent "presence" indicators (green dot, activity ring)

3. **Results Panel** — The right panel could feel more like a conversation thread or a document viewer. Explore:
   - Streaming text animation with cursor
   - Syntax highlighting for code blocks in responses
   - Side-by-side comparison view (not just keyword analysis)
   - Agent response "confidence" or quality indicators

4. **Prompt Bar** — Could feel more like a command bar. Explore:
   - Spotlight/Raycast-style command input
   - Inline agent mentions (@agent-name)
   - Rich workflow mode visualization (not just dropdown)
   - Prompt templates as visual chips

5. **Header** — Could be more minimal or more informative. Explore:
   - Collapsible to just icon + provider badge
   - Live cost/token counter with sparkline
   - Running agents progress visualization

6. **Modals** — Should feel native and polished. Explore:
   - Slide-over panels instead of centered modals
   - Nested views within modals
   - Form validation with inline feedback

7. **Overall Layout** — Explore alternatives to the rigid 2-column:
   - Resizable panels
   - Collapsible sidebar (icon-only mode)
   - Full-width workspace mode (hide sidebar + results)
   - Tab system for multiple office layouts

### Must Keep
- Dark/Light theme toggle
- 8 role desks with drag-and-drop
- Agent search + filter by role
- 5 workflow modes (parallel, pipeline, synthesis, review, debate)
- Real-time streaming responses
- Compare/analysis mode
- Session history
- Keyboard shortcuts

### Visual Style Notes
- Use the existing CSS variable system as a starting point but feel free to extend it
- Keep Inter font family (or suggest a better alternative for a developer tool)
- The gradient icon (blue→purple) is a nice brand element, carry it through
- Agent emojis are a core UX element — they add personality and should be prominent
- Consider adding subtle noise/grain texture for depth
- Motion: use 150-200ms ease-out for most transitions, 300ms for modals

### Screen Sizes
- Primary: 1440×900 (macBook Pro 14")
- Must work at: 1280×720 minimum
- The app is desktop-only, no responsive design needed

---

## Deliverables

1. **Full app screenshot/mockup** at 1440×900 showing the main state (agents seated, results visible)
2. **Component breakdown** of key UI elements with spacing, colors, typography
3. **Dark theme as primary** (this is a dev tool, dark is expected)
4. **Light theme variant** showing the same layout
5. **Interactive states** for at least: empty state, agents working, results displayed, modal open
