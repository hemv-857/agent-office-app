import { useState } from 'react';
import { invoke } from '@tauri-apps/api/core';
import './App.css';
import { exportLayout, exportResultAsMarkdown } from './utils/export';
import { useAppStore } from './store/useAppStore';
import { useAgentCatalog } from './hooks/useAgentCatalog';
import { useAgentSelection } from './hooks/useAgentSelection';
import { useOffice } from './hooks/useOffice';
import { useStreaming } from './hooks/useStreaming';
import { useOrchestration } from './hooks/useOrchestration';
import { useChat } from './hooks/useChat';
import { useWorkflows } from './hooks/useWorkflows';
import { useKeyboardShortcuts } from './hooks/useKeyboardShortcuts';
import { useSessionHistory } from './hooks/useSessionHistory';
import { useOvernight } from './hooks/useOvernight';
import { useTaskDecomposition } from './hooks/useTaskDecomposition';
import { useAgentMemory } from './hooks/useAgentMemory';
import { useMcpTools } from './hooks/useMcpTools';
import { useCostTracker } from './hooks/useCostTracker';
import { useVoiceInput } from './hooks/useVoiceInput';
import { useAgentLeaderboard } from './hooks/useAgentLeaderboard';
import { useOffline } from './hooks/useOffline';
import { useSessionNotes } from './hooks/useSessionNotes';
import { usePipelineVisualizer } from './hooks/usePipelineVisualizer';
import { useAgentHealth } from './hooks/useAgentHealth';
import { WORKFLOW_TEMPLATES } from './utils/constants';
import { Sidebar } from './components/Sidebar';
import { OfficeGrid } from './components/OfficeGrid';
import { ResultsPanel } from './components/ResultsPanel';
import { PromptBar } from './components/PromptBar';
import { ActivityLog } from './components/ActivityLog';
import { StatusBar } from './components/StatusBar';
import { SessionHistory } from './components/SessionHistory';
import { ErrorBoundary } from './components/ErrorBoundary';
import { CommandPalette } from './components/CommandPalette';
import { Onboarding } from './components/Onboarding';
import { ShortcutOverlay } from './components/ShortcutOverlay';
import { SessionNotesModal } from './components/SessionNotesModal';
import { PipelineVisualizer } from './components/PipelineVisualizer';
import { AgentHealthIndicator } from './components/AgentHealthIndicator';
import type { CommandItem } from './components/CommandPalette';
import {
  SettingsModal,
  HelpModal,
  AgentDetailModal,
  GroupSaveModal,
  PresetSaveModal,
  CustomAgentModal,
  ChatModal,
  PerformanceModal,
  ApprovalModal,
  OvernightPanel,
  ExitSummaryModal,
  McpToolsModal,
  AgentMemoryPanel,
  CostTrackerModal,
  LeaderboardModal,
} from './components/Modals';

function App() {
  const {
    theme, provider, costBudget, sidebarSections, compactOffice,
    officeAgents, groupName, presetName,
    showGroupSave, showPresetSave, showSettings, showHelp,
    showResultsPanel, showPerfDashboard, toast, activityLog,
    toggleTheme, setProvider, setCostBudget, setSidebarSections,
    setCompactOffice, setOfficeAgents, removeFromDesk,
    clearOffice, deleteGroup, loadOfficePreset, deleteOfficePreset,
    setGroupName, setPresetName, setShowGroupSave, setShowPresetSave,
    setShowSettings, setShowHelp, setShowResultsPanel, setShowPerfDashboard,
    showToast, dismissToast, logActivity, clearActivityLog,
  } = useAppStore();

  const catalog = useAgentCatalog();
  const selection = useAgentSelection(catalog.allAgents);
  const office = useOffice();
  const streaming = useStreaming();
  const chat = useChat(provider);
  const sessionHistory = useSessionHistory();
  const sessionNotes = useSessionNotes();
  const pipeline = usePipelineVisualizer();
  const agentHealth = useAgentHealth();

  const [prompt, setPrompt] = useState('');
  const [isRunning, setIsRunning] = useState(false);
  const [showCommandPalette, setShowCommandPalette] = useState(false);
  const [, setShowOnboarding] = useState(true);
  const [showShortcuts, setShowShortcuts] = useState(false);
  const [showSessionNotes, setShowSessionNotes] = useState(false);

  const seatedCount = officeAgents.length;

  const orchestration = useOrchestration({
    prompt,
    setPrompt,
    selectedAgents: selection.selectedAgents,
    setSelectedAgents: selection.setSelectedAgents,
    isRunning,
    setIsRunning,
    provider,
    allAgents: catalog.allAgents,
    showToast,
  });

  const workflows = useWorkflows({ provider, showToast });
  const overnight = useOvernight();
  const taskDecomp = useTaskDecomposition({ provider, showToast });
  const agentMemory = useAgentMemory();
  const mcpTools = useMcpTools();
  const costTracker = useCostTracker();
  const leaderboard = useAgentLeaderboard();

  const [showMcpTools, setShowMcpTools] = useState(false);
  const [showAgentMemory, setShowAgentMemory] = useState(false);
  const [showCostTracker, setShowCostTracker] = useState(false);
  const [showLeaderboard, setShowLeaderboard] = useState(false);

  const offline = useOffline();

  const voiceInput = useVoiceInput({
    onTranscript: (text) => setPrompt(prev => prev ? prev + ' ' + text : text),
    onError: (msg) => showToast(msg, 'error'),
  });

  const commands: CommandItem[] = [
    { id: 'run-all', label: 'Run All Agents', description: 'Execute all seated agents', icon: '▶', group: 'Actions', shortcut: '⌘↵', action: handleRunAll },
    { id: 'suggest', label: 'Suggest Agents', description: 'AI picks best agents for prompt', icon: '🤖', group: 'Actions', action: orchestration.handleSuggest },
    { id: 'decompose', label: 'Decompose Task', description: 'Break into subtasks', icon: '📋', group: 'Actions', shortcut: '⌘D', action: () => taskDecomp.decompose(prompt) },
    { id: 'export-layout', label: 'Export Layout', description: 'Download office config', icon: '📤', group: 'Actions', action: handleExportLayout },
    { id: 'toggle-theme', label: 'Toggle Theme', description: 'Switch dark/light mode', icon: '🎨', group: 'View', action: toggleTheme },
    { id: 'toggle-sidebar', label: 'Toggle Sidebar', description: 'Show/hide sidebar', icon: '📌', group: 'View', action: () => setCompactOffice(!compactOffice) },
    { id: 'toggle-results', label: 'Toggle Results Panel', description: 'Show/hide results', icon: '📊', group: 'View', action: () => setShowResultsPanel(!showResultsPanel) },
    { id: 'settings', label: 'Open Settings', description: 'Configure providers and budget', icon: '⚙', group: 'Navigation', shortcut: '⌘,', action: () => setShowSettings(true) },
    { id: 'help', label: 'Show Help', description: 'View keyboard shortcuts', icon: '❓', group: 'Navigation', shortcut: '?', action: () => setShowHelp(true) },
    { id: 'shortcuts', label: 'Keyboard Shortcuts', description: 'View all shortcuts', icon: '⌨', group: 'Navigation', action: () => setShowShortcuts(true) },
    { id: 'mcp-tools', label: 'MCP Tool Registry', description: 'Manage tool servers', icon: '🔧', group: 'Navigation', action: () => setShowMcpTools(true) },
    { id: 'agent-memory', label: 'Agent Memory', description: 'View learned patterns', icon: '🧠', group: 'Navigation', action: () => setShowAgentMemory(true) },
    { id: 'cost-tracker', label: 'Cost Tracker', description: 'View spending history', icon: '💰', group: 'Navigation', action: () => setShowCostTracker(true) },
    { id: 'leaderboard', label: 'Agent Leaderboard', description: 'Performance rankings', icon: '🏆', group: 'Navigation', action: () => setShowLeaderboard(true) },
    { id: 'session-notes', label: 'Session Notes', description: 'Attach notes to sessions', icon: '📝', group: 'Navigation', action: () => setShowSessionNotes(true) },
    { id: 'perf-dashboard', label: 'Performance Dashboard', description: 'Agent metrics', icon: '📈', group: 'Navigation', action: () => setShowPerfDashboard(true) },
    { id: 'clear-office', label: 'Clear Office', description: 'Remove all agents from desks', icon: '🗑', group: 'Office', action: clearOffice },
    { id: 'select-all', label: 'Select All Agents', description: '', icon: '✅', group: 'Office', action: selection.selectAll },
    { id: 'deselect-all', label: 'Deselect All Agents', description: '', icon: '⬜', group: 'Office', action: selection.deselectAll },
    ...WORKFLOW_TEMPLATES.map(t => ({
      id: `wf-${t.id}`,
      label: `Workflow: ${t.label}`,
      description: t.description,
      icon: t.icon,
      group: 'Workflows',
      action: () => handleWorkflowTemplate(t.id),
    })),
  ];

  function handleWorkflowTemplate(templateId: string) {
    const template = WORKFLOW_TEMPLATES.find(t => t.id === templateId);
    if (!template) return;
    setPrompt(template.prompt);
    // Select agents by role
    const matchingAgents = catalog.allAgents.filter(a =>
      template.agentRoles.includes(a.office_role)
    );
    if (matchingAgents.length > 0) {
      selection.setSelectedAgents(matchingAgents.map(a => a.id));
    }
    // Set workflow mode
    workflows.setWorkflowMode(template.workflowMode as Parameters<typeof workflows.setWorkflowMode>[0]);
    showToast(`Loaded workflow: ${template.label}`, 'success');
  }

  async function handleOvernightStart(objective: string, maxIter: number, maxTok: number, preventSleep: boolean) {
    // Set prompt and trigger suggest to pick agents
    setPrompt(objective);
    await orchestration.handleSuggest();
    // Wait a moment for suggestions to populate
    await new Promise(r => setTimeout(r, 500));

    const agentIds = selection.selectedAgents.length > 0
      ? selection.selectedAgents
      : officeAgents.map(a => a.id);

    overnight.startOvernight(
      objective,
      maxIter,
      maxTok,
      provider,
      preventSleep,
      async (p, ids) => {
        setPrompt(p);
        selection.setSelectedAgents(ids);
        await orchestration.handleSubmit();
      },
      () => agentIds,
    );
    logActivity(`Overnight mode started: ${objective}`, 'info');
  }

  function handleRunAll() {
    if (!prompt.trim() || officeAgents.length === 0 || isRunning) return;
    selection.setSelectedAgents(officeAgents.map(a => a.id));
    orchestration.handleSubmit();
    logActivity(`Running ${officeAgents.length} agents`, 'info');
  }

  async function handleRunQueue() {
    for (const q of orchestration.promptQueue) {
      setPrompt(q);
      await orchestration.handleSubmit();
    }
    orchestration.setPromptQueue([]);
    setPrompt('');
  }

  function handleKeyDown(e: React.KeyboardEvent) {
    if (e.key === 'Enter' && (e.shiftKey || e.metaKey || e.ctrlKey)) {
      if (e.metaKey || e.ctrlKey) {
        e.preventDefault();
        orchestration.handleSubmit();
      }
    } else if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      orchestration.handleSubmit();
    } else if (e.key === 'd' && (e.metaKey || e.ctrlKey)) {
      e.preventDefault();
      taskDecomp.decompose(prompt);
    }
  }

  async function handleCancel() {
    if (streaming.activeSession) {
      // @ts-expect-error - Tauri injected global
      await window.__TAURI__.invoke('cancel_session', { sessionId: streaming.activeSession });
      showToast('Cancellation requested', 'success');
    }
  }

  useKeyboardShortcuts({
    showHelp,
    setShowHelp: (v: boolean | ((p: boolean) => boolean)) => {
      const next = typeof v === 'function' ? v(showHelp) : v;
      setShowHelp(next);
    },
    showSettings,
    setShowSettings: (v: boolean | ((p: boolean) => boolean)) => {
      const next = typeof v === 'function' ? v(showSettings) : v;
      setShowSettings(next);
    },
    searchQuery: selection.searchQuery,
    setSearchQuery: selection.setSearchQuery,
    handleSuggest: orchestration.handleSuggest,
    handleRunAll,
    showShortcuts,
    setShowShortcuts,
    showCommandPalette,
    setShowCommandPalette,
  });

  function handleExportLayout() {
    exportLayout(
      officeAgents,
      selection.favorites,
      costBudget,
      provider,
      catalog.customAgents,
    );
  }

  function handleImportLayout(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = () => {
      try {
        const data = JSON.parse(reader.result as string);
        if (!data || typeof data !== 'object') throw new Error('Invalid format');
        if (data.officeAgents && Array.isArray(data.officeAgents)) {
          const valid = data.officeAgents.filter(
            (a: Record<string, unknown>) => a.id && a.name && a.role && typeof a.id === 'string' && typeof a.name === 'string'
          );
          setOfficeAgents(valid);
        }
        if (data.favorites && Array.isArray(data.favorites)) {
          const validFavs = data.favorites.filter((f: unknown) => typeof f === 'string');
          selection.setSelectedAgents(validFavs);
        }
        if (typeof data.costBudget === 'number' && data.costBudget >= 0) setCostBudget(data.costBudget);
        if (data.provider === 'anthropic' || data.provider === 'openai') setProvider(data.provider);
        showToast('Layout imported', 'success');
      } catch {
        showToast('Invalid layout file', 'error');
      }
    };
    reader.readAsText(file);
    e.target.value = '';
  }

  function handleCopyResult(text: string) {
    navigator.clipboard.writeText(text).then(
      () => showToast('Copied to clipboard', 'success'),
      () => showToast('Copy failed')
    );
  }

  function handleExportSingle(r: { agent_name: string; agent_id: string; status: string; tokens_used: number; cost_usd: number; elapsed_ms?: number; response: string }) {
    const agent = catalog.allAgents.find(a => a.id === r.agent_id);
    exportResultAsMarkdown(r as never, agent);
  }

  async function handleEvaluateQuality(response: string, criteria: string): Promise<{ passed: boolean; score: number; reasoning: string }> {
    try {
      return await invoke('evaluate_quality', { response, criteria, provider });
    } catch {
      return { passed: true, score: 0.5, reasoning: 'Evaluation unavailable' };
    }
  }

  function handleGroupLoad(name: string) {
    office.loadGroup(name, catalog.allAgents, selection.setSelectedAgents);
    logActivity(`Loaded group "${name}"`, 'success');
  }

  function handlePresetLoad(name: string) {
    loadOfficePreset(name);
    logActivity(`Loaded preset "${name}"`, 'success');
  }

  function handleGroupSave() {
    if (office.saveGroup(groupName, selection.selectedAgents)) {
      showToast(`Group "${groupName}" saved`, 'success');
    } else {
      showToast('Enter a group name and select agents', 'error');
    }
  }

  function handlePresetSave() {
    if (office.saveOfficePreset(presetName)) {
      showToast(`Preset saved`, 'success');
    } else {
      showToast('Enter a preset name', 'error');
    }
  }

  function handleCustomAgentAdd() {
    if (catalog.addCustomAgent()) {
      showToast(`Agent added`, 'success');
    } else {
      showToast('Name and system prompt required', 'error');
    }
  }

  return (
    <div className="agent-office-container" data-theme={theme === 'system' ? (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light') : theme}>
      <CommandPalette open={showCommandPalette} onOpenChange={setShowCommandPalette} commands={commands} />
      <Onboarding onComplete={() => setShowOnboarding(false)} />
      <ShortcutOverlay open={showShortcuts} onClose={() => setShowShortcuts(false)} />

      {offline && <div className="offline-banner">⚠ You are offline — LLM calls will fail</div>}
      {toast && (
        <div className={`toast ${toast.type}`} onClick={dismissToast} role="alert" aria-live="polite" aria-atomic="true">
          {toast.message}
        </div>
      )}

      <Sidebar
        filteredAgents={selection.filteredAgents}
        selectedAgents={selection.selectedAgents}
        officeAgents={officeAgents}
        favorites={selection.favorites}
        searchQuery={selection.searchQuery}
        roleFilter={selection.roleFilter}
        showFavoritesOnly={selection.showFavoritesOnly}
        agentGroups={office.agentGroupsArray}
        officePresets={office.officePresetsArray}
        theme={theme}
        sidebarSections={sidebarSections}
        onSearchChange={selection.setSearchQuery}
        onRoleFilterChange={selection.setRoleFilter}
        onShowFavoritesOnly={selection.setShowFavoritesOnly}
        onToggleAgent={selection.toggleAgent}
        onDoubleClickAgent={office.handleAgentDoubleClick}
        onDragStart={office.handleDragStart}
        onShowAgentDetail={catalog.showAgentDetail}
        onToggleFavorite={selection.toggleFavorite}
        onSelectAll={selection.selectAll}
        onDeselectAll={selection.deselectAll}
        onClearOffice={clearOffice}
        onToggleTheme={toggleTheme}
        onShowCustomAgent={() => catalog.setShowCustomAgent(true)}
        onShowGroupSave={() => setShowGroupSave(true)}
        onShowPresetSave={() => setShowPresetSave(true)}
        onExportLayout={handleExportLayout}
        onImportLayout={handleImportLayout}
        onLoadGroup={handleGroupLoad}
        onDeleteGroup={deleteGroup}
        onLoadPreset={handlePresetLoad}
        onDeletePreset={deleteOfficePreset}
        onSectionToggle={(section) => setSidebarSections(s => ({ ...s, [section]: !s[section] }))}
      />

      <div className="main-area">
        <header className="header">
          <div className="header-left">
            <div className="header-icon" />
            <span className="header-title">Agent Office</span>
            {seatedCount > 0 && <span className="header-badge">{seatedCount}/8 seated</span>}
            {isRunning && <span className="header-badge running">⚡ running</span>}
          </div>
          <div className="header-right">
            <AgentHealthIndicator providers={agentHealth.providers} />
            <span className="header-badge">{provider === 'anthropic' ? '🟣' : '🟢'} {provider}</span>
            <button
              onClick={handleRunAll}
              disabled={!prompt.trim() || officeAgents.length === 0 || isRunning}
              className="icon-btn"
              title="Run all seated agents"
              style={{ opacity: (!prompt.trim() || officeAgents.length === 0 || isRunning) ? 0.3 : 1 }}
            >▶▶</button>
            {isRunning && (
              <button
                onClick={handleCancel}
                className="icon-btn danger"
                title="Cancel running task"
              >✕</button>
            )}
            <button onClick={() => setShowResultsPanel(!showResultsPanel)} className="icon-btn" title={showResultsPanel ? 'Hide results' : 'Show results'}>
              {showResultsPanel ? '◀' : '▶'}
            </button>
            <button onClick={() => setShowMcpTools(true)} className="icon-btn" title="MCP Tool Registry">🔧</button>
            <button onClick={() => setShowAgentMemory(true)} className="icon-btn" title="Agent Memory">🧠</button>
            <button onClick={() => setShowCostTracker(true)} className="icon-btn" title="Cost Tracker">💰</button>
            <button onClick={() => setShowLeaderboard(true)} className="icon-btn" title="Agent Leaderboard">🏆</button>
            <button onClick={() => setShowPerfDashboard(true)} className="icon-btn" title="Performance dashboard">📊</button>
            <button onClick={() => setShowHelp(true)} className="icon-btn" title="Help">?</button>
            <button onClick={() => setShowSettings(true)} className="icon-btn" title="Settings">⚙</button>
            <button onClick={() => setCompactOffice(!compactOffice)} className="icon-btn" title={compactOffice ? 'Expand' : 'Compact'}>
              {compactOffice ? '🔽' : '🔼'}
            </button>
          </div>
        </header>

        <div className="content">
          <div className="workspace">
            <OfficeGrid
              officeAgents={officeAgents}
              compactOffice={compactOffice}
              dragOverRole={office.dragOverRole}
              onDragOver={office.handleDragOver}
              onDragLeave={office.handleDragLeave}
              onDrop={office.handleDrop}
              onDeskDragStart={office.handleDeskDragStart}
              onDeskDrop={office.handleDeskDrop}
              onRemoveFromDesk={removeFromDesk}
            />

            {pipeline.stages.length > 0 && (
              <PipelineVisualizer nodes={pipeline.nodes} stages={pipeline.stages} />
            )}

            <ResultsPanel
              resultsArray={streaming.resultsArray}
              allAgents={catalog.allAgents}
              totalCost={streaming.totalCost}
              totalTokens={streaming.totalTokens}
              isRunning={isRunning}
              expandedCards={streaming.expandedCards}
              compareMode={streaming.compareMode}
              bookmarks={streaming.bookmarks}
              ratings={streaming.ratings}
              selectedResults={streaming.selectedResults}
              activeSession={streaming.activeSession}
              resultsRef={streaming.resultsRef}
              onSetCompareMode={streaming.setCompareMode}
              onToggleCardExpanded={streaming.toggleCardExpanded}
              onToggleBookmark={streaming.toggleBookmark}
              onToggleRating={streaming.toggleRating}
              onToggleResultSelect={streaming.toggleResultSelect}
              onSelectAllResults={streaming.selectAllResults}
              onDeselectAllResults={streaming.deselectAllResults}
              onClearResults={streaming.clearResults}
              onOpenChat={chat.openChat}
              onCopyResult={handleCopyResult}
              onExportSingle={handleExportSingle}
              onShowResultsPanel={showResultsPanel}
              onEvaluateQuality={handleEvaluateQuality}
            />
          </div>

          <OvernightPanel
            isRunning={overnight.state.running}
            iteration={overnight.state.iteration}
            maxIterations={overnight.state.maxIterations}
            totalTokens={overnight.state.totalTokens}
            maxTokens={overnight.state.maxTokens}
            totalCost={overnight.state.totalCost}
            commits={overnight.state.commits}
            rollbacks={overnight.state.rollbacks}
            lastError={overnight.state.lastError}
            onStart={handleOvernightStart}
            onStop={overnight.stopOvernight}
          />

          <PromptBar
            prompt={prompt}
            setPrompt={setPrompt}
            selectedAgents={selection.selectedAgents}
            isRunning={isRunning}
            suggesting={orchestration.suggesting}
            suggestions={orchestration.suggestions}
            workflowMode={workflows.workflowMode}
            promptHistory={orchestration.promptHistory}
            promptQueue={orchestration.promptQueue}
            allAgents={catalog.allAgents}
            decomposed={taskDecomp.decomposed}
            decomposing={taskDecomp.decomposing}
            voiceSupported={voiceInput.supported}
            voiceListening={voiceInput.listening}
            onSetSuggestions={orchestration.setSuggestions}
            onSetSelectedAgents={selection.setSelectedAgents}
            onSubmit={orchestration.handleSubmit}
            onSuggest={orchestration.handleSuggest}
            onDecompose={() => taskDecomp.decompose(prompt)}
            onSetWorkflowMode={workflows.setWorkflowMode}
            onAddToQueue={orchestration.addToQueue}
            onClearQueue={orchestration.clearQueue}
            onRunQueue={handleRunQueue}
            onVoiceToggle={voiceInput.toggle}
            onWorkflowTemplate={handleWorkflowTemplate}
            onKeyDown={handleKeyDown}
          />
        </div>
      </div>

      {showSettings && (
        <SettingsModal
          provider={provider}
          costBudget={costBudget}
          onProviderChange={setProvider}
          onBudgetChange={setCostBudget}
          onSave={() => { setShowSettings(false); showToast('Settings saved', 'success'); }}
          onClose={() => setShowSettings(false)}
        />
      )}
      {showHelp && <HelpModal onClose={() => setShowHelp(false)} />}
      {catalog.agentDetail && (
        <AgentDetailModal detail={catalog.agentDetail} onClose={() => catalog.setAgentDetail(null)} />
      )}
      {showGroupSave && (
        <GroupSaveModal
          groupName={groupName}
          setGroupName={setGroupName}
          selectedCount={selection.selectedAgents.length}
          onSave={handleGroupSave}
          onClose={() => setShowGroupSave(false)}
        />
      )}
      {showPresetSave && (
        <PresetSaveModal
          presetName={presetName}
          setPresetName={setPresetName}
          seatedCount={seatedCount}
          onSave={handlePresetSave}
          onClose={() => setShowPresetSave(false)}
        />
      )}
      {catalog.showCustomAgent && (
        <CustomAgentModal
          customForm={catalog.customForm}
          setCustomForm={catalog.setCustomForm}
          onAdd={handleCustomAgentAdd}
          onClose={() => catalog.setShowCustomAgent(false)}
        />
      )}
      {chat.chatAgent && (
        <ChatModal
          agent={chat.chatAgent}
          messages={chat.chatMessages}
          chatInput={chat.chatInput}
          setChatInput={chat.setChatInput}
          chatLoading={chat.chatLoading}
          onSend={chat.sendChatMessage}
          onClose={() => chat.setChatAgent(null)}
        />
      )}
      {showPerfDashboard && (
        <PerformanceModal
          resultsArray={streaming.getAgentStats()}
          totalCost={streaming.totalCost}
          totalTokens={streaming.totalTokens}
          ratings={streaming.ratings}
          onClose={() => setShowPerfDashboard(false)}
        />
      )}
      {workflows.approvalStep && (
        <ApprovalModal
          agentName={workflows.approvalStep.agentName}
          agentEmoji={catalog.allAgents.find(a => a.id === workflows.approvalStep!.agentId)?.emoji || '🤖'}
          context={workflows.approvalStep.context}
          onApprove={() => workflows.resolveApproval(true)}
          onReject={() => workflows.resolveApproval(false)}
        />
      )}
      {overnight.summary && (
        <ExitSummaryModal
          summary={overnight.summary}
          onClose={overnight.clearSummary}
        />
      )}
      {showMcpTools && (
        <McpToolsModal
          servers={mcpTools.servers}
          onAdd={mcpTools.addServer}
          onRemove={mcpTools.removeServer}
          onToggle={mcpTools.toggleServer}
          onClose={() => setShowMcpTools(false)}
        />
      )}
      {showAgentMemory && (
        <AgentMemoryPanel
          memories={agentMemory.memories}
          onDelete={agentMemory.deleteMemory}
          onClose={() => setShowAgentMemory(false)}
        />
      )}
      {showCostTracker && (
        <CostTrackerModal
          entries={costTracker.entries}
          todayCost={costTracker.getTodayCost()}
          totalCost={costTracker.getTotalCost()}
          weeklyCost={costTracker.getWeeklyCost()}
          byProvider={costTracker.getCostByProvider()}
          budget={costTracker.budget}
          budgetCheck={costTracker.checkBudget()}
          onSetBudget={costTracker.setBudget}
          onClose={() => setShowCostTracker(false)}
        />
      )}
      {showLeaderboard && (
        <LeaderboardModal
          entries={leaderboard.getLeaderboard()}
          mostEfficient={leaderboard.getMostEfficient()}
          onClear={leaderboard.clearLeaderboard}
          onClose={() => setShowLeaderboard(false)}
        />
      )}
      {showSessionNotes && (
        <SessionNotesModal
          notes={sessionNotes.notes}
          onAdd={sessionNotes.addNote}
          onUpdate={sessionNotes.updateNote}
          onDelete={sessionNotes.deleteNote}
          onSearch={sessionNotes.searchNotes}
          allTags={sessionNotes.getAllTags()}
          onClose={() => setShowSessionNotes(false)}
        />
      )}

      <SessionHistory
        sessions={sessionHistory.sessions}
        onDelete={sessionHistory.deleteSession}
        onClear={sessionHistory.clearSessions}
        onLoad={(session) => {
          setPrompt(session.prompt);
          selection.setSelectedAgents(session.agentIds);
          showToast('Session loaded', 'success');
        }}
      />
      <ActivityLog entries={activityLog} />
      <StatusBar
        agentCount={catalog.allAgents.length}
        seatedCount={seatedCount}
        provider={provider}
        totalCost={streaming.totalCost}
        totalTokens={streaming.totalTokens}
        isRunning={isRunning}
        activityCount={activityLog.length}
        onClearActivity={clearActivityLog}
      />
    </div>
  );
}

export default function AppWithBoundary() {
  return (
    <ErrorBoundary>
      <App />
    </ErrorBoundary>
  );
}
