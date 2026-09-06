// CommandPaletteView.swift
import SwiftUI

struct CommandPaletteView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var query = ""
    @FocusState private var isFocused: Bool

    struct Command: Identifiable {
        let id = UUID()
        let label: String
        let shortcut: String?
        let icon: String
        let action: () -> Void
    }

    var commands: [Command] {
        [
            // Core
            Command(label: "Run All Agents", shortcut: "⌘↵", icon: "play.fill") { store.runAll(); dismiss() },
            Command(label: "Stop", shortcut: "⌘.", icon: "stop.fill") { store.cancelRun(); dismiss() },
            Command(label: "Clear Office", shortcut: nil, icon: "trash") { store.clearOffice(); dismiss() },
            Command(label: "Toggle Sidebar", shortcut: "⌘S", icon: "sidebar.left") { store.showSidebar.toggle(); dismiss() },
            Command(label: "Toggle Results", shortcut: nil, icon: "sidebar.right") { store.showResultsPanel.toggle(); dismiss() },

            // Views
            Command(label: "Settings", shortcut: "⌘,", icon: "gearshape") { store.showSettings = true; dismiss() },
            Command(label: "Help", shortcut: "?", icon: "questionmark.circle") { store.showHelp = true; dismiss() },
            Command(label: "Cost Tracker", shortcut: nil, icon: "dollarsign.circle") { store.showCostTracker = true; dismiss() },
            Command(label: "Leaderboard", shortcut: nil, icon: "chart.bar") { store.showLeaderboard = true; dismiss() },
            Command(label: "Session Notes", shortcut: nil, icon: "note.text") { store.showSessionNotes = true; dismiss() },
            Command(label: "Activity Log", shortcut: nil, icon: "list.bullet") { store.showActivityLog = true; dismiss() },
            Command(label: "Pipeline Visualizer", shortcut: nil, icon: "arrow.triangle.branch") { store.showPipelineVisualizer = true; dismiss() },
            Command(label: "Agent Memory", shortcut: nil, icon: "brain") { store.showAgentMemory = true; dismiss() },

            // New features
            Command(label: "Analytics Dashboard", shortcut: nil, icon: "chart.line.uptrend.xyaxis") { store.showAnalytics = true; dismiss() },
            Command(label: "Batch Run", shortcut: nil, icon: "square.stack") { store.showBatchRun = true; dismiss() },
            Command(label: "Compare Agents", shortcut: nil, icon: "arrow.left.arrow.right") { store.showComparison = true; dismiss() },
            Command(label: "Conversation History", shortcut: nil, icon: "bubble.left.and.bubble.right") { store.showConversationHistory = true; dismiss() },
            Command(label: "Prompt Templates", shortcut: nil, icon: "doc.text") { store.showPromptTemplates = true; dismiss() },
            Command(label: "Task Queue", shortcut: nil, icon: "list.number") { store.showTaskQueue = true; dismiss() },
            Command(label: "Workflow Chains", shortcut: nil, icon: "link") { store.showChains = true; dismiss() },
            Command(label: "Plugins", shortcut: nil, icon: "puzzlepiece") { store.showPlugins = true; dismiss() },
            Command(label: "Custom Commands", shortcut: nil, icon: "command") { store.showCommands = true; dismiss() },

            // Data
            Command(label: "Export Results", shortcut: "⌘E", icon: "square.and.arrow.up") { store.showExport = true; dismiss() },
            Command(label: "Storage", shortcut: nil, icon: "internaldrive") { store.showStorage = true; dismiss() },

            // Agent management
            Command(label: "Add Custom Agent", shortcut: nil, icon: "person.badge.plus") { store.showCustomAgent = true; dismiss() },
            Command(label: "Save Group", shortcut: nil, icon: "folder.badge.plus") { store.showGroupSave = true; dismiss() },
            Command(label: "Save Preset", shortcut: nil, icon: "bookmark.badge.plus") { store.showPresetSave = true; dismiss() },

            // New views
            Command(label: "Bulk Actions", shortcut: nil, icon: "checkmark.square") { store.showBulkActions = true; dismiss() },
            Command(label: "Agent Scheduler", shortcut: nil, icon: "calendar") { store.showAgentScheduler = true; dismiss() },
            Command(label: "Prompt Library", shortcut: nil, icon: "text.book.closed") { store.showPromptLibrary = true; dismiss() },
            Command(label: "Template Designer", shortcut: nil, icon: "plus.square.on.square") { store.showTemplateDesigner = true; dismiss() },
            Command(label: "Workspace Layout", shortcut: nil, icon: "rectangle.grid.2x2") { store.showWorkspaceLayout = true; dismiss() },
            Command(label: "Analytics Dashboard", shortcut: nil, icon: "chart.pie") { store.showAnalyticsDashboard = true; dismiss() },
            Command(label: "Quick Switch", shortcut: nil, icon: "arrow.triangle.2.circlepath") { store.showWorkspaceQuickSwitch = true; dismiss() },
            Command(label: "Agent Status", shortcut: nil, icon: "person.circle") { store.showAgentStatus = true; dismiss() },
            Command(label: "Agent Progress", shortcut: nil, icon: "chart.bar.fill") { store.showAgentProgress = true; dismiss() },
            Command(label: "System Diagnostics", shortcut: nil, icon: "stethoscope") { store.showSystemDiagnostics = true; dismiss() },
            Command(label: "Execution Queue", shortcut: nil, icon: "list.number") { store.showExecutionQueue = true; dismiss() },
            Command(label: "Workspace Dashboard", shortcut: nil, icon: "square.grid.3x3") { store.showWorkspaceDashboard = true; dismiss() },
            Command(label: "Performance Report", shortcut: nil, icon: "doc.text.magnifyingglass") { store.showPerformanceReport = true; dismiss() },
            Command(label: "Backup & Restore", shortcut: nil, icon: "arrow.clockwise.circle") { store.showBackupRestore = true; dismiss() },
            Command(label: "Cost Optimization", shortcut: nil, icon: "lightbulb.min") { store.showCostOptimization = true; dismiss() },
            Command(label: "System Health", shortcut: nil, icon: "heart.text.square") { store.showSystemHealth = true; dismiss() },
            Command(label: "Collaboration Network", shortcut: nil, icon: "point.3.connected.trianglepath.dotted") { store.showCollaborationNetwork = true; dismiss() },
            Command(label: "Notifications", shortcut: nil, icon: "bell.badge") { store.showNotificationsCenter = true; dismiss() },
            Command(label: "Workspace Settings", shortcut: nil, icon: "wrench.and.screwdriver") { store.showWorkspaceSettings = true; dismiss() },
            Command(label: "Agent Roster", shortcut: nil, icon: "person.3.sequence") { store.showAgentRoster = true; dismiss() },
            Command(label: "Session Timeline", shortcut: nil, icon: "timeline") { store.showSessionTimeline = true; dismiss() },
            Command(label: "Skill Tree", shortcut: nil, icon: "point.3.connected.trianglepath.dotted") { store.showSkillTree = true; dismiss() },
            Command(label: "Prompt Snippets", shortcut: nil, icon: "text.bubble") { store.showQuickSnippets = true; dismiss() },
            Command(label: "Audit Log", shortcut: nil, icon: "doc.text.magnifyingglass") { store.showAuditLog = true; dismiss() },
            Command(label: "Token Usage", shortcut: nil, icon: "text.word.spacing") { store.showTokenUsage = true; dismiss() },
            Command(label: "Model Performance", shortcut: nil, icon: "cpu") { store.showModelPerformance = true; dismiss() },
            Command(label: "Role Assignment", shortcut: nil, icon: "person.3.sequence") { store.showRoleAssignment = true; dismiss() },
            Command(label: "Performance Trend", shortcut: nil, icon: "chart.line.uptrend.xyaxis") { store.showPerformanceTrend = true; dismiss() },
            Command(label: "Agent Skill Tags", shortcut: nil, icon: "tag") { store.showAgentSkillTags = true; dismiss() },
            Command(label: "Agent Health", shortcut: nil, icon: "heart.text.square") { store.showAgentHealthDetail = true; dismiss() },
            Command(label: "Workspace Overview", shortcut: nil, icon: "square.grid.3x3") { store.showWorkspaceOverview = true; dismiss() },
            Command(label: "Budget Forecast", shortcut: nil, icon: "chart.line.downtrend.xyaxis") { store.showBudgetForecast = true; dismiss() },
            Command(label: "Onboarding", shortcut: nil, icon: "checkmark.seal") { store.showOnboardingChecklist = true; dismiss() },
            Command(label: "Communication Log", shortcut: nil, icon: "bubble.left.and.bubble.right") { store.showAgentCommunicationLog = true; dismiss() },
            Command(label: "Dependency Graph", shortcut: nil, icon: "point.3.connected.trianglepath.dotted") { store.showAgentDependencyGraph = true; dismiss() },
            Command(label: "System Preferences", shortcut: nil, icon: "gearshape.2") { store.showSystemPreferences = true; dismiss() },
            Command(label: "Leaderboard", shortcut: nil, icon: "trophy") { store.showAgentLeaderboard = true; dismiss() },
            Command(label: "System Status", shortcut: nil, icon: "network") { store.showSystemStatusDashboard = true; dismiss() },
            Command(label: "Storage Details", shortcut: nil, icon: "internaldrive") { store.showStorageDetails = true; dismiss() },
            Command(label: "Agent Schedule", shortcut: nil, icon: "calendar") { store.showAgentSchedulingCalendar = true; dismiss() },
            Command(label: "Interaction Matrix", shortcut: nil, icon: "squareshape.split.3x3") { store.showAgentInteractionMatrix = true; dismiss() },
            Command(label: "Task History", shortcut: nil, icon: "clock.arrow.circlepath") { store.showAgentTaskHistory = true; dismiss() },
            Command(label: "Agent Availability", shortcut: nil, icon: "person.crop.circle.badge.checkmark") { store.showAgentAvailability = true; dismiss() },
            Command(label: "Performance Compare", shortcut: nil, icon: "chart.bar.xaxis.ascending") { store.showPerformanceComparison = true; dismiss() },
            Command(label: "Memory Manager", shortcut: nil, icon: "brain") { store.showAgentMemoryManager = true; dismiss() },
            Command(label: "Collaboration Rules", shortcut: nil, icon: "list.bullet.rectangle") { store.showCollaborationRules = true; dismiss() },
            Command(label: "Cost by Day", shortcut: nil, icon: "calendar.badge.clock") { store.showCostBreakdownByDay = true; dismiss() },
            Command(label: "Workload Distribution", shortcut: nil, icon: "chart.bar") { store.showWorkloadDistribution = true; dismiss() },
            Command(label: "Quality Scores", shortcut: nil, icon: "star.square") { store.showQualityScores = true; dismiss() },
            Command(label: "Sentiment Analysis", shortcut: nil, icon: "face.smiling") { store.showSentimentAnalysis = true; dismiss() },
            Command(label: "Error Log", shortcut: nil, icon: "exclamationmark.triangle") { store.showErrorLog = true; dismiss() },
            Command(label: "Prompt Templates", shortcut: nil, icon: "doc.text") { store.showPromptTemplateLibrary = true; dismiss() },
            Command(label: "Response Quality", shortcut: nil, icon: "checkmark.circle.badge.star") { store.showResponseQualityAnalyzer = true; dismiss() },
            Command(label: "Task Queue", shortcut: nil, icon: "list.number") { store.showAgentTaskQueue = true; dismiss() },
            Command(label: "Performance Dashboard", shortcut: nil, icon: "gauge.with.dots.needle.67percent") { store.showPerformanceDashboard = true; dismiss() },
            Command(label: "Role Assignments", shortcut: nil, icon: "person.3.sequence") { store.showRoleAssignmentMatrix = true; dismiss() },
            Command(label: "Cost Optimization", shortcut: nil, icon: "dollarsign.circle") { store.showAgentCostOptimization = true; dismiss() },
            Command(label: "Onboarding Progress", shortcut: nil, icon: "figure.walk") { store.showOnboardingProgress = true; dismiss() },
            Command(label: "Collaboration Timeline", shortcut: nil, icon: "timeline-selection") { store.showCollaborationTimeline = true; dismiss() },
            Command(label: "Session Comparison", shortcut: nil, icon: "rectangle.split.2x1") { store.showSessionComparison = true; dismiss() },
            Command(label: "Quick Actions", shortcut: nil, icon: "bolt.circle") { store.showQuickActions = true; dismiss() },
            Command(label: "Data Pipeline", shortcut: nil, icon: "arrow.triangle.branch") { store.showDataPipeline = true; dismiss() },
            Command(label: "Integration Tests", shortcut: nil, icon: "testtube.2") { store.showIntegrationTest = true; dismiss() },
            Command(label: "System Health", shortcut: nil, icon: "heart.text.clipboard") { store.showSystemHealthMonitor = true; dismiss() },
            Command(label: "Workflow Optimizer", shortcut: nil, icon: "wand.and.stars") { store.showWorkflowOptimizer = true; dismiss() },
            Command(label: "Activity Feed", shortcut: nil, icon: "list.dash") { store.showActivityFeed = true; dismiss() },
            Command(label: "Cost Alerts", shortcut: nil, icon: "exclamationmark.circle") { store.showCostAlert = true; dismiss() },
            Command(label: "Workflow Analytics", shortcut: nil, icon: "chart.bar.doc.horizontal") { store.showWorkflowAnalytics = true; dismiss() },
            Command(label: "Agent Communication", shortcut: nil, icon: "bubble.left.and.bubble.right.fill") { store.showAgentCommunication = true; dismiss() },
            Command(label: "Session Manager", shortcut: nil, icon: "folder") { store.showSessionManager = true; dismiss() },
            Command(label: "Agent Settings", shortcut: nil, icon: "slider.horizontal.3") { store.showAgentSettings = true; dismiss() },
            Command(label: "Workflow Builder", shortcut: nil, icon: "wrench.and.screwdriver") { store.showWorkflowBuilder = true; dismiss() },
            Command(label: "Agent Monitor", shortcut: nil, icon: "eye") { store.showAgentMonitor = true; dismiss() },
            Command(label: "Agent Dependencies", shortcut: nil, icon: "arrow.triangle.swap") { store.showAgentDependencyViewer = true; dismiss() },
            Command(label: "Session Summary", shortcut: nil, icon: "doc.text.magnifyingglass") { store.showSessionSummary = true; dismiss() },
            Command(label: "Task Dispatcher", shortcut: nil, icon: "arrow.up.circle") { store.showTaskDispatcher = true; dismiss() },
            Command(label: "Performance Tracker", shortcut: nil, icon: "chart.line.uptrend.xyaxis.circle") { store.showPerformanceTracker = true; dismiss() },
            Command(label: "Workload Analyzer", shortcut: nil, icon: "chart.bar.doc.horizontal") { store.showWorkloadAnalyzer = true; dismiss() },
            Command(label: "Task History Tracker", shortcut: nil, icon: "clock.arrow.circlepath") { store.showTaskHistoryTracker = true; dismiss() },
            Command(label: "Task Queue Manager", shortcut: nil, icon: "list.number.rtl") { store.showTaskQueueManager = true; dismiss() },
            Command(label: "Performance Detail", shortcut: nil, icon: "chart.bar.xaxis.ascending.badge") { store.showPerformanceDashboardDetail = true; dismiss() },
            Command(label: "Workflow Execution", shortcut: nil, icon: "play.circle") { store.showWorkflowExecution = true; dismiss() },
            Command(label: "Cost Breakdown", shortcut: nil, icon: "chart.pie") { store.showCostBreakdownDetail = true; dismiss() },
            Command(label: "Cost Optimization Detail", shortcut: nil, icon: "wand.and.stars") { store.showCostOptimizationDetail = true; dismiss() },
            Command(label: "Performance Report", shortcut: nil, icon: "doc.richtext") { store.showPerformanceReport = true; dismiss() },
            Command(label: "Agent Dashboard", shortcut: nil, icon: "square.grid.2x2") { store.showAgentDashboard = true; dismiss() },
            Command(label: "Settings Manager", shortcut: nil, icon: "gearshape") { store.showSettingsManager = true; dismiss() },
            Command(label: "Activity Monitor", shortcut: nil, icon: "gauge.with.dots.needle.33percent") { store.showActivityMonitor = true; dismiss() },
            Command(label: "Settings Viewer", shortcut: nil, icon: "gearshape.2") { store.showSettingsViewer = true; dismiss() },
            Command(label: "Settings Editor", shortcut: nil, icon: "pencil.circle") { store.showSettingsEditor = true; dismiss() },
            Command(label: "Settings Validator", shortcut: nil, icon: "checkmark.shield") { store.showSettingsValidator = true; dismiss() },
            Command(label: "Settings Manager Detail", shortcut: nil, icon: "gearshape.2") { store.showSettingsManagerDetail = true; dismiss() },
            Command(label: "Settings Validator Detail", shortcut: nil, icon: "checkmark.shield.fill") { store.showSettingsValidatorDetail = true; dismiss() },
            Command(label: "Collaboration Analytics", shortcut: nil, icon: "chart.bar.fill") { store.showCollaborationAnalytics = true; dismiss() },
            Command(label: "Execution History", shortcut: nil, icon: "clock.arrow.circlepath") { store.showExecutionHistory = true; dismiss() },
            Command(label: "Cost Prediction", shortcut: nil, icon: "chart.line.downtrend.xyaxis") { store.showCostPrediction = true; dismiss() },
            Command(label: "Execution Timeline", shortcut: nil, icon: "timeline.selection") { store.showExecutionTimeline = true; dismiss() },
            Command(label: "Session Detail", shortcut: nil, icon: "doc.text.fill") { store.showSessionDetail = true; dismiss() },
            Command(label: "Import / Export", shortcut: nil, icon: "arrow.triangle.2.circlepath") { store.showImportExportManager = true; dismiss() },
            Command(label: "Role Editor", shortcut: nil, icon: "person.crop.circle.badge.gearshape") { store.showAgentRoleEditor = true; dismiss() },
            Command(label: "Metrics Dashboard", shortcut: nil, icon: "chart.pie.fill") { store.showMetricsDashboard = true; dismiss() },
            Command(label: "Onboarding Wizard", shortcut: nil, icon: "sparkles") { store.showOnboardingWizard = true; dismiss() },
            Command(label: "Workflow Queue", shortcut: nil, icon: "list.bullet.rectangle") { store.showWorkflowQueue = true; dismiss() },
            Command(label: "Cost Optimization Advisor", shortcut: nil, icon: "lightbulb.fill") { store.showCostOptimizationAdvisor = true; dismiss() },
            Command(label: "System Health Report", shortcut: nil, icon: "heart.text.square") { store.showHealthReport = true; dismiss() },
            Command(label: "Template Manager", shortcut: nil, icon: "square.stack.3d.up.fill") { store.showTemplateManager = true; dismiss() },
            Command(label: "Cost Breakdown", shortcut: nil, icon: "chart.bar.fill") { store.showCostBreakdown = true; dismiss() },
            Command(label: "Analytics Summary", shortcut: nil, icon: "chart.bar.doc.horizontal.fill") { store.showAnalyticsSummary = true; dismiss() },
            Command(label: "Cost Trend", shortcut: nil, icon: "chart.line.uptrend.xyaxis") { store.showCostTrend = true; dismiss() },
            Command(label: "Backup Status", shortcut: nil, icon: "externaldrive.fill") { store.showBackupStatus = true; dismiss() },
            Command(label: "Collaboration History", shortcut: nil, icon: "person.2.fill") { store.showCollaborationHistory = true; dismiss() },
            Command(label: "Session Analytics", shortcut: nil, icon: "chart.bar.fill") { store.showSessionAnalytics = true; dismiss() },
            Command(label: "Performance Insights", shortcut: nil, icon: "lightbulb.max.fill") { store.showPerformanceInsights = true; dismiss() },
            Command(label: "Workflow Optimization", shortcut: nil, icon: "wand.and.stars") { store.showWorkflowOptimization = true; dismiss() },
            Command(label: "Agent Status Dashboard", shortcut: nil, icon: "person.circle.fill") { store.showAgentStatusDashboard = true; dismiss() },
            Command(label: "Template Editor", shortcut: nil, icon: "pencil.and.list.clipboard") { store.showWorkflowTemplateEditor = true; dismiss() },
            Command(label: "Quick Setup", shortcut: nil, icon: "bolt.fill") { store.showQuickSetup = true; dismiss() },
            Command(label: "Error Handling", shortcut: nil, icon: "exclamationmark.triangle") { store.showErrorHandling = true; dismiss() },
            Command(label: "Model Comparison", shortcut: nil, icon: "cpu") { store.showModelComparison = true; dismiss() },
            Command(label: "API Key Manager", shortcut: nil, icon: "key.fill") { store.showAPIKeyManager = true; dismiss() },
            Command(label: "Theme Customizer", shortcut: nil, icon: "paintbrush.fill") { store.showThemeCustomizer = true; dismiss() },
            Command(label: "Keyboard Shortcuts", shortcut: nil, icon: "keyboard") { store.showKeyboardShortcutsEditor = true; dismiss() },
            Command(label: "Data Management", shortcut: nil, icon: "internaldrive") { store.showDataManagement = true; dismiss() },
            Command(label: "Performance Monitor", shortcut: nil, icon: "gauge.with.dots.needle.67percent") { store.showPerformanceMonitor = true; dismiss() },
            Command(label: "System Info", shortcut: nil, icon: "info.circle") { store.showSystemInfo = true; dismiss() },
            Command(label: "Agent Training", shortcut: nil, icon: "brain.head.profile") { store.showAgentTraining = true; dismiss() },
            Command(label: "Workflow Scheduler", shortcut: nil, icon: "calendar.badge.clock") { store.showWorkflowScheduler = true; dismiss() },
            Command(label: "Agent Collaboration", shortcut: nil, icon: "arrow.triangle.merge") { store.showAgentCollaboration = true; dismiss() },
            Command(label: "Agent Health", shortcut: nil, icon: "heart.circle") { store.showAgentHealth = true; dismiss() },
            Command(label: "Settings Presets", shortcut: nil, icon: "slider.horizontal.3") { store.showSettingsPresets = true; dismiss() },
            Command(label: "Agent Debug Console", shortcut: nil, icon: "terminal") { store.showAgentDebug = true; dismiss() },
            Command(label: "Activity Timeline", shortcut: nil, icon: "clock.arrow.circlepath") { store.showActivityTimeline = true; dismiss() },
            Command(label: "Model Performance", shortcut: nil, icon: "speedometer") { store.showModelPerformance = true; dismiss() },
            Command(label: "Prompt Templates", shortcut: nil, icon: "doc.text") { store.showPromptTemplates = true; dismiss() },
            Command(label: "Agent Metrics", shortcut: nil, icon: "chart.bar") { store.showAgentMetrics = true; dismiss() },
            Command(label: "Session Restore", shortcut: nil, icon: "arrow.clockwise") { store.showSessionRestore = true; dismiss() },
            Command(label: "Workflow Design", shortcut: nil, icon: "flowchart") { store.showWorkflowDesign = true; dismiss() },
            Command(label: "Agent Onboarding", shortcut: nil, icon: "hand.wave") { store.showAgentOnboarding = true; dismiss() },
            Command(label: "Agent Insights", shortcut: nil, icon: "lightbulb") { store.showAgentInsights = true; dismiss() },
            Command(label: "Cost Forecast", shortcut: nil, icon: "chart.line.uptrend.xyaxis") { store.showCostForecast = true; dismiss() },
            Command(label: "Agent Leaderboard", shortcut: nil, icon: "trophy") { store.showAgentLeaderboard = true; dismiss() },
            Command(label: "Agent Comparison", shortcut: nil, icon: "chart.bar.xaxis") { store.showAgentComparison = true; dismiss() },
            Command(label: "Agent Performance Trend", shortcut: nil, icon: "chart.xyaxis.line") { store.showAgentPerformanceTrend = true; dismiss() },
            Command(label: "Agent Error Log", shortcut: nil, icon: "exclamationmark.triangle") { store.showAgentErrorLog = true; dismiss() },
            Command(label: "Agent Task Queue", shortcut: nil, icon: "list.bullet.rectangle") { store.showAgentTaskQueue = true; dismiss() },
        ]
    }

    var filtered: [Command] {
        query.isEmpty ? commands : commands.filter { $0.label.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Type a command...", text: $query)
                    .textFieldStyle(.plain)
                    .focused($isFocused)
                Button(action: { dismiss() }) {
                    Text("esc").font(.system(size: 10)).padding(.horizontal, 4).padding(.vertical, 2)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 4))
                }
                .buttonStyle(.plain)
            }
            .padding(12)

            Divider()

            ScrollView {
                LazyVStack(spacing: 1) {
                    ForEach(filtered) { cmd in
                        HStack {
                            Image(systemName: cmd.icon).frame(width: 20).foregroundStyle(.secondary)
                            Text(cmd.label)
                            Spacer()
                            if let s = cmd.shortcut {
                                Text(s).font(.system(size: 10)).foregroundStyle(.secondary)
                                    .padding(.horizontal, 4).padding(.vertical, 2)
                                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 4))
                            }
                        }
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .contentShape(Rectangle())
                        .onTapGesture { cmd.action() }
                    }
                }
            }
        }
        .frame(width: 480, height: 400)
        .onAppear { isFocused = true }
    }
}
