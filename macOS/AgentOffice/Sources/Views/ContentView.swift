// ContentView.swift
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        HSplitView {
            if store.showSidebar {
                SidebarView()
                    .frame(minWidth: 260, idealWidth: 280, maxWidth: 320)
            }

            VStack(spacing: 0) {
                HeaderView()
                OfficeGridView()
                PromptBarView()
                StatusBarView()
            }

            if store.showResultsPanel {
                ResultsPanelView()
                    .frame(minWidth: 360, idealWidth: 400, maxWidth: 500)
            }
        }
        .overlay(alignment: .top) {
            if let toast = store.toast {
                ToastView(toast: toast)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 8)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: store.toast?.id)
        // Modal sheets
        .sheet(isPresented: $store.showOnboarding) { OnboardingView() }
        .sheet(isPresented: $store.showSettings) { SettingsView() }
        .sheet(isPresented: $store.showHelp) { HelpView() }
        .sheet(isPresented: $store.showCommandPalette) { CommandPaletteView() }
        .sheet(isPresented: $store.showCostTracker) { CostTrackerView() }
        .sheet(isPresented: $store.showLeaderboard) { LeaderboardView() }
        .sheet(isPresented: $store.showPipelineVisualizer) { PipelineVisualizerView() }
        .sheet(isPresented: $store.showSessionNotes) { SessionNotesView() }
        .sheet(isPresented: $store.showActivityLog) { ActivityLogView() }
        .sheet(isPresented: $store.showCustomAgent) { CustomAgentView() }
        .sheet(isPresented: $store.showExport) { ExportView() }
        .sheet(isPresented: $store.showAgentMemory) { AgentMemoryView() }
        .sheet(isPresented: $store.showProjectBuilder) { ProjectBuilderView() }
        .sheet(isPresented: $store.showSessionReplay) { SessionReplayView() }
        .sheet(isPresented: $store.showWorkflowLog) { WorkflowLogView() }
        .sheet(isPresented: $store.showWorkflowSteps) { WorkflowStepsView() }
        .sheet(isPresented: $store.showAgentMetrics) { AgentMetricsView() }
        .sheet(isPresented: $store.showWorkflowHistory) { WorkflowHistoryView() }
        .sheet(isPresented: $store.showQuickActions) { QuickActionsView() }
        .sheet(isPresented: $store.showAnalytics) { AnalyticsDashboardView() }
        .sheet(isPresented: $store.showPlugins) { PluginConfigView() }
        .sheet(isPresented: $store.showCommands) { CommandRegistryView() }
        .sheet(isPresented: $store.showChains) { WorkflowChainView() }
        .sheet(isPresented: $store.showBatchRun) { BatchRunView() }
        .sheet(isPresented: $store.showConversationHistory) { ConversationHistoryView() }
        .sheet(isPresented: $store.showComparison) { AgentComparisonView() }
        .sheet(isPresented: $store.showPromptTemplates) { PromptTemplatesView() }
        .sheet(isPresented: $store.showTaskQueue) { TaskQueueView() }
        .sheet(isPresented: $store.showStorage) { StorageView() }
        .sheet(isPresented: $store.showClipboard) { ClipboardHistoryView() }
        .sheet(isPresented: $store.showDiagnostics) { DiagnosticsView() }
        .sheet(isPresented: $store.showChangelog) { ChangelogView() }
        .sheet(isPresented: $store.showCostProjection) { CostProjectionView() }
        .sheet(isPresented: $store.showOnboardingProgress) { OnboardingProgressView() }
        .sheet(isPresented: $store.showCommandHistory) { CommandHistoryView() }
        .sheet(isPresented: $store.showShortcutsCustomize) { KeyboardShortcutCustomizationView() }
        .sheet(isPresented: $store.showAgentModels) { AgentModelConfigView() }
        .sheet(isPresented: $store.showTemplateCategories) { WorkflowTemplateCategoriesView() }
        .sheet(isPresented: $store.showPerformanceComparison) { AgentPerformanceComparisonView() }
        .sheet(item: $store.showAgentDetail) { agent in AgentDetailView(agent: agent) }
        .sheet(item: $store.showChat) { dest in ChatView(agentId: dest.agentId, agentName: dest.agentName) }
        .sheet(isPresented: $store.showGroupSave) {
            GroupSaveView()
        }
        .sheet(isPresented: $store.showPresetSave) {
            PresetSaveView()
        }
        .sheet(isPresented: $store.showBulkActions) { WorkflowBulkActionsView() }
        .sheet(isPresented: $store.showAgentScheduler) { WorkflowAgentSchedulerView() }
        .sheet(isPresented: $store.showPromptLibrary) { WorkflowPromptLibraryView() }
        .sheet(isPresented: $store.showTemplateDesigner) { WorkflowTemplateDesignerView() }
        .sheet(isPresented: $store.showWorkspaceLayout) { WorkflowWorkspaceLayoutView() }
        .sheet(isPresented: $store.showAnalyticsDashboard) { WorkflowAnalyticsDashboardView() }
        .sheet(isPresented: $store.showWorkspaceQuickSwitch) { WorkspaceQuickSwitchView() }
        .sheet(isPresented: $store.showAgentStatus) { WorkflowAgentStatusView() }
        .sheet(isPresented: $store.showAgentProgress) { WorkflowAgentProgressView() }
        .sheet(isPresented: $store.showAgentPerformance) { WorkflowAgentPerformanceView() }
        .sheet(isPresented: $store.showAgentMetrics2) { WorkflowAgentMetricsView() }
        .sheet(isPresented: $store.showAgentActivity) { WorkflowAgentActivityView() }
        .sheet(isPresented: $store.showAgentCollaboration) { WorkflowAgentCollaborationView() }
        .sheet(isPresented: $store.showAgentInteractions) { WorkflowAgentInteractionView() }
        .sheet(isPresented: $store.showAgentSummary) { WorkflowAgentSummaryView() }
        .sheet(isPresented: $store.showAgentTasks) { WorkflowAgentTaskView() }
        .sheet(isPresented: $store.showAgentDetails) { WorkflowAgentDetailView() }
        .sheet(isPresented: $store.showSystemDiagnostics) { WorkflowSystemDiagnosticsView() }
        .sheet(isPresented: $store.showExecutionQueue) { WorkflowExecutionQueueView() }
        .sheet(isPresented: $store.showWorkspaceDashboard) { WorkflowWorkspaceDashboardView() }
        .sheet(isPresented: $store.showPerformanceReport) { WorkflowPerformanceReportView() }
        .sheet(isPresented: $store.showBackupRestore) { WorkspaceBackupRestoreView() }
        .sheet(isPresented: $store.showCostOptimization) { WorkflowCostOptimizationView() }
        .sheet(isPresented: $store.showSystemHealth) { WorkflowSystemHealthView() }
        .sheet(isPresented: $store.showCollaborationNetwork) { WorkflowAgentCollaborationNetworkView() }
        .sheet(isPresented: $store.showNotificationsCenter) { WorkflowNotificationsCenterView() }
        .sheet(isPresented: $store.showWorkspaceSettings) { WorkflowWorkspaceSettingsView() }
        .sheet(isPresented: $store.showAgentRoster) { WorkflowAgentRosterView() }
        .sheet(isPresented: $store.showSessionTimeline) { WorkflowSessionTimelineView() }
        .sheet(isPresented: $store.showSkillTree) { WorkflowSkillTreeVisualizerView() }
        .sheet(isPresented: $store.showQuickSnippets) { WorkflowQuickPromptSnippetsView() }
        .sheet(isPresented: $store.showAuditLog) { WorkflowAuditLogView() }
        .sheet(isPresented: $store.showTokenUsage) { WorkflowTokenUsageView() }
        .sheet(isPresented: $store.showModelPerformance) { WorkflowModelPerformanceView() }
        .sheet(isPresented: $store.showRoleAssignment) { WorkflowAgentRoleAssignmentView() }
        .sheet(isPresented: $store.showPerformanceTrend) { WorkflowPerformanceTrendView() }
        .sheet(isPresented: $store.showAgentSkillTags) { WorkflowAgentSkillTagsView() }
        .sheet(isPresented: $store.showOnboardingChecklist) { WorkflowAgentOnboardingChecklistView() }
        .sheet(isPresented: $store.showSessionComparisonDetail) { WorkflowSessionComparisonDetailView() }
        .sheet(isPresented: $store.showAgentHealthDetail) { WorkflowAgentHealthDetailView() }
        .sheet(isPresented: $store.showWorkspaceOverview) { WorkflowWorkspaceOverviewView() }
        .sheet(isPresented: $store.showBudgetForecast) { WorkflowBudgetForecastView() }
        .sheet(isPresented: $store.showAgentCommunicationLog) { WorkflowAgentCommunicationLogView() }
        .sheet(isPresented: $store.showAgentDependencyGraph) { WorkflowAgentDependencyGraphView() }
        .sheet(isPresented: $store.showSystemPreferences) { WorkflowSystemPreferencesView() }
        .sheet(isPresented: $store.showAgentLeaderboard) { WorkflowAgentLeaderboardDetailView() }
        .sheet(isPresented: $store.showSystemStatusDashboard) { WorkflowSystemStatusDashboardView() }
        .sheet(isPresented: $store.showStorageDetails) { WorkflowWorkspaceStorageDetailView() }
        .sheet(isPresented: $store.showAgentSchedulingCalendar) { WorkflowAgentSchedulingCalendarView() }
        .sheet(isPresented: $store.showAgentInteractionMatrix) { WorkflowAgentInteractionMatrixView() }
        .sheet(isPresented: $store.showAgentTaskHistory) { WorkflowAgentTaskHistoryView() }
        .sheet(isPresented: $store.showAgentAvailability) { WorkflowAgentAvailabilityView() }
        .sheet(isPresented: $store.showPerformanceComparison) { WorkflowAgentPerformanceComparisonView() }
        .sheet(isPresented: $store.showAgentMemoryManager) { WorkflowAgentMemoryManagerView() }
        .sheet(isPresented: $store.showCollaborationRules) { WorkflowAgentCollaborationRulesView() }
        .sheet(isPresented: $store.showCostBreakdownByDay) { WorkflowCostBreakdownByDayView() }
        .sheet(isPresented: $store.showWorkloadDistribution) { WorkflowAgentWorkloadDistributionView() }
        .sheet(isPresented: $store.showQualityScores) { WorkflowAgentQualityScoreView() }
        .sheet(isPresented: $store.showSentimentAnalysis) { WorkflowAgentSentimentAnalysisView() }
        .sheet(isPresented: $store.showErrorLog) { WorkflowAgentErrorLogView() }
        .sheet(isPresented: $store.showPromptTemplateLibrary) { WorkflowAgentPromptTemplateLibraryView() }
        .sheet(isPresented: $store.showResponseQualityAnalyzer) { WorkflowAgentResponseQualityAnalyzerView() }
        .sheet(isPresented: $store.showAgentTaskQueue) { WorkflowAgentTaskQueueView() }
        .sheet(isPresented: $store.showPerformanceDashboard) { WorkflowAgentPerformanceDashboardView() }
        .sheet(isPresented: $store.showRoleAssignmentMatrix) { WorkflowAgentRoleAssignmentMatrixView() }
        .sheet(isPresented: $store.showAgentCostOptimization) { WorkflowAgentCostOptimizationView() }
        .sheet(isPresented: $store.showOnboardingProgress) { WorkflowAgentOnboardingProgressView() }
        .sheet(isPresented: $store.showCollaborationTimeline) { WorkflowAgentCollaborationTimelineView() }
        .sheet(isPresented: $store.showSessionComparison) { WorkflowAgentSessionComparisonView() }
        .sheet(isPresented: $store.showDataPipeline) { WorkflowAgentDataPipelineView() }
        .sheet(isPresented: $store.showIntegrationTest) { WorkflowAgentIntegrationTestView() }
        .sheet(isPresented: $store.showSystemHealthMonitor) { WorkflowAgentSystemHealthMonitorView() }
        .sheet(isPresented: $store.showWorkflowOptimizer) { WorkflowAgentWorkflowOptimizerView() }
        .sheet(isPresented: $store.showActivityFeed) { WorkflowAgentActivityFeedView() }
        .sheet(isPresented: $store.showCostAlert) { WorkflowAgentCostAlertView() }
        .sheet(isPresented: $store.showWorkflowAnalytics) { WorkflowAgentWorkflowAnalyticsView() }
        .sheet(isPresented: $store.showAgentCommunication) { WorkflowAgentCommunicationView() }
        .sheet(isPresented: $store.showSessionManager) { WorkflowAgentSessionManagerView() }
        .sheet(isPresented: $store.showAgentSettings) { WorkflowAgentAgentSettingsView() }
        .sheet(isPresented: $store.showWorkflowBuilder) { WorkflowAgentWorkflowBuilderView() }
        .sheet(isPresented: $store.showAgentMonitor) { WorkflowAgentMonitorView() }
        .sheet(isPresented: $store.showAgentDependencyViewer) { WorkflowAgentDependencyViewerView() }
        .sheet(isPresented: $store.showSessionSummary) { WorkflowAgentSessionSummaryView() }
        .sheet(isPresented: $store.showTaskDispatcher) { WorkflowAgentTaskDispatcherView() }
        .sheet(isPresented: $store.showPerformanceTracker) { WorkflowAgentPerformanceTrackerView() }
        .sheet(isPresented: $store.showWorkloadAnalyzer) { WorkflowAgentWorkloadAnalyzerView() }
        .sheet(isPresented: $store.showTaskHistoryTracker) { WorkflowAgentTaskHistoryTrackerView() }
        .sheet(isPresented: $store.showTaskQueueManager) { WorkflowAgentTaskQueueManagerView() }
        .sheet(isPresented: $store.showPerformanceDashboardDetail) { WorkflowAgentPerformanceDashboardDetailView() }
        .sheet(isPresented: $store.showWorkflowExecution) { WorkflowAgentWorkflowExecutionView() }
        .sheet(isPresented: $store.showCostBreakdownDetail) { WorkflowAgentCostBreakdownDetailView() }
        .sheet(isPresented: $store.showCostOptimizationDetail) { WorkflowAgentCostOptimizationDetailView() }
        .sheet(isPresented: $store.showPerformanceReport) { WorkflowAgentPerformanceReportView() }
        .sheet(isPresented: $store.showAgentDashboard) { WorkflowAgentDashboardView() }
        .sheet(isPresented: $store.showSettingsManager) { WorkflowAgentSettingsManagerView() }
        .sheet(isPresented: $store.showActivityMonitor) { WorkflowAgentActivityMonitorView() }
        .sheet(isPresented: $store.showSettingsViewer) { WorkflowAgentSettingsViewerView() }
        .sheet(isPresented: $store.showSettingsEditor) { WorkflowAgentSettingsEditorView() }
        .sheet(isPresented: $store.showSettingsValidator) { WorkflowAgentSettingsValidatorView() }
        .sheet(isPresented: $store.showSettingsManagerDetail) { WorkflowAgentSettingsManagerDetailView() }
        .sheet(isPresented: $store.showSettingsValidatorDetail) { WorkflowAgentSettingsValidatorDetailView() }
        .sheet(isPresented: $store.showCollaborationAnalytics) { WorkflowAgentCollaborationAnalyticsView() }
        .sheet(isPresented: $store.showExecutionHistory) { WorkflowExecutionHistoryView() }
        .sheet(isPresented: $store.showCostPrediction) { WorkflowCostPredictionView() }
        .sheet(isPresented: $store.showExecutionTimeline) { WorkflowExecutionTimelineView() }
        .sheet(isPresented: $store.showSessionDetail) { WorkflowAgentSessionDetailView() }
        .sheet(isPresented: $store.showImportExportManager) { WorkflowImportExportManagerView() }
        .sheet(isPresented: $store.showAgentRoleEditor) { WorkflowAgentRoleEditorView() }
        .sheet(isPresented: $store.showMetricsDashboard) { WorkflowMetricsDashboardView() }
        .sheet(isPresented: $store.showOnboardingWizard) { WorkflowAgentOnboardingWizardView() }
        .sheet(isPresented: $store.showWorkflowQueue) { WorkflowAgentWorkflowQueueView() }
        .sheet(isPresented: $store.showCostOptimizationAdvisor) { WorkflowAgentCostOptimizationAdvisorView() }
        .sheet(isPresented: $store.showHealthReport) { WorkflowAgentHealthReportView() }
        .sheet(isPresented: $store.showTemplateManager) { WorkflowAgentTemplateManagerView() }
        .sheet(isPresented: $store.showCostBreakdown) { WorkflowAgentCostBreakdownView() }
        .sheet(isPresented: $store.showAnalyticsSummary) { WorkflowAgentAnalyticsSummaryView() }
        .sheet(isPresented: $store.showCostTrend) { WorkflowAgentCostTrendView() }
        .sheet(isPresented: $store.showBackupStatus) { WorkflowAgentBackupStatusView() }
        .sheet(isPresented: $store.showCollaborationHistory) { WorkflowAgentAgentCollaborationHistoryView() }
        .sheet(isPresented: $store.showSessionAnalytics) { WorkflowAgentSessionAnalyticsView() }
        .sheet(isPresented: $store.showPerformanceInsights) { WorkflowAgentPerformanceInsightsView() }
        .sheet(isPresented: $store.showWorkflowOptimization) { WorkflowAgentWorkflowOptimizationView() }
        .sheet(isPresented: $store.showAgentStatusDashboard) { WorkflowAgentAgentStatusDashboardView() }
        .sheet(isPresented: $store.showWorkflowTemplateEditor) { WorkflowAgentWorkflowTemplateEditorView() }
        .sheet(isPresented: $store.showQuickSetup) { WorkflowAgentQuickSetupView() }
        .sheet(isPresented: $store.showErrorHandling) { WorkflowAgentErrorHandlingView() }
        .sheet(isPresented: $store.showModelComparison) { WorkflowAgentModelComparisonView() }
        .sheet(isPresented: $store.showAPIKeyManager) { WorkflowAgentAPIKeyManagerView() }
        .sheet(isPresented: $store.showThemeCustomizer) { WorkflowAgentThemeCustomizerView() }
        .sheet(isPresented: $store.showKeyboardShortcutsEditor) { WorkflowAgentKeyboardShortcutsEditorView() }
        .sheet(isPresented: $store.showDataManagement) { WorkflowAgentDataManagementView() }
        .sheet(isPresented: $store.showPerformanceMonitor) { WorkflowAgentPerformanceMonitorView() }
        .sheet(isPresented: $store.showSystemInfo) { WorkflowAgentSystemInfoView() }
        .sheet(isPresented: $store.showAgentTraining) { WorkflowAgentAgentTrainingView() }
        .sheet(isPresented: $store.showWorkflowScheduler) { WorkflowAgentWorkflowSchedulerView() }
        .sheet(isPresented: $store.showAgentCollaboration) { WorkflowAgentAgentCollaborationView() }
        .sheet(isPresented: $store.showAgentHealth) { WorkflowAgentAgentHealthView() }
        .sheet(isPresented: $store.showSettingsPresets) { WorkflowAgentAgentSettingsPresetView() }
        .sheet(isPresented: $store.showAgentDebug) { WorkflowAgentAgentDebugView() }
        .sheet(isPresented: $store.showQuickActions) { WorkflowAgentQuickActionsView() }
        // Keyboard shortcuts
        .background(
            KeyboardShortcutsView()
        )
        .onAppear {
            NotificationCenter.default.addObserver(forName: .commandPalette, object: nil, queue: .main) { _ in
                store.showCommandPalette = true
            }
            NotificationCenter.default.addObserver(forName: .showHelp, object: nil, queue: .main) { _ in
                store.showHelp = true
            }
            NotificationCenter.default.addObserver(forName: .showExport, object: nil, queue: .main) { _ in
                store.showExport = true
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self)
        }
    }
}

// MARK: - Keyboard Shortcuts
struct KeyboardShortcutsView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                // Cmd+K: Command Palette
                if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "k" {
                    NotificationCenter.default.post(name: .commandPalette, object: nil)
                    return nil
                }
                // ?: Help
                if event.charactersIgnoringModifiers == "?" && !event.modifierFlags.contains(.command) {
                    NotificationCenter.default.post(name: .showHelp, object: nil)
                    return nil
                }
                // Cmd+E: Export
                if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "e" {
                    NotificationCenter.default.post(name: .showExport, object: nil)
                    return nil
                }
                // Cmd+1-8: Select desk
                if event.modifierFlags.contains(.command),
                   let char = event.charactersIgnoringModifiers,
                   let num = Int(char), (1...8).contains(num) {
                    NotificationCenter.default.post(name: .selectDesk, object: num - 1)
                    return nil
                }
                // Cmd+Up/Down: Navigate prompt history
                if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "\u{1e}" {
                    NotificationCenter.default.post(name: .promptHistoryUp, object: nil)
                    return nil
                }
                if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "\u{1f}" {
                    NotificationCenter.default.post(name: .promptHistoryDown, object: nil)
                    return nil
                }
                // Cmd+L: Clear prompt
                if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "l" {
                    NotificationCenter.default.post(name: .clearPrompt, object: nil)
                    return nil
                }
                return event
            }
        }
        return view
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}

// MARK: - Group Save View
struct GroupSaveView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var name = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Save Agent Group").font(.headline)
            TextField("Group name...", text: $name).textFieldStyle(.roundedBorder)
            HStack {
                Button("Cancel") { dismiss() }.buttonStyle(.bordered)
                Button("Save") { store.saveGroup(name); dismiss() }
                    .buttonStyle(.borderedProminent)
                    .disabled(name.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 320)
    }
}

// MARK: - Preset Save View
struct PresetSaveView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var name = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Save Office Preset").font(.headline)
            TextField("Preset name...", text: $name).textFieldStyle(.roundedBorder)
            HStack {
                Button("Cancel") { dismiss() }.buttonStyle(.bordered)
                Button("Save") { store.savePreset(name); dismiss() }
                    .buttonStyle(.borderedProminent)
                    .disabled(name.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 320)
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let commandPalette = Notification.Name("commandPalette")
    static let showHelp = Notification.Name("showHelp")
    static let showExport = Notification.Name("showExport")
    static let selectDesk = Notification.Name("selectDesk")
    static let promptHistoryUp = Notification.Name("promptHistoryUp")
    static let promptHistoryDown = Notification.Name("promptHistoryDown")
    static let clearPrompt = Notification.Name("clearPrompt")
}
