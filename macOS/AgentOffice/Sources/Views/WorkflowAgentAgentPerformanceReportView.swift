// WorkflowAgentAgentPerformanceReportView.swift
import SwiftUI

struct WorkflowAgentAgentPerformanceReportView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let sections: [(String, [(String, String)])] = [
        ("Executive Summary", [
            ("Overall Health", "Excellent"),
            ("Total Tasks", "817"),
            ("Success Rate", "94.7%"),
            ("Avg Response", "1.8s"),
        ]),
        ("Agent Performance", [
            ("Top Performer", "Security (98.0%)"),
            ("Most Active", "Builder (289 tasks)"),
            ("Most Improved", "Tester (+2.3%)"),
            ("Needs Attention", "None"),
        ]),
        ("Cost Analysis", [
            ("This Month", "$66.00"),
            ("Per Task", "$0.08"),
            ("Budget Used", "34%"),
            ("Projection", "$76.20"),
        ]),
        ("Recommendations", [
            ("Scale Builder", "High throughput agent"),
            ("Optimize Tester", "Reduce error rate"),
            ("Add Cache", "For Architect queries"),
        ]),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Performance Report").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(sections.indices, id: \.self) { i in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(sections[i].0)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.blue)
                            
                            ForEach(sections[i].1.indices, id: \.self) { j in
                                HStack {
                                    Text(sections[i].1[j].0)
                                        .font(.system(size: 10))
                                        .foregroundStyle(.secondary)
                                        .frame(width: 120, alignment: .leading)
                                    Text(sections[i].1[j].1)
                                        .font(.system(size: 10, weight: .medium))
                                    Spacer()
                                }
                                .padding(.vertical, 2)
                            }
                        }
                        .padding(12)
                        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Button("Export PDF") {
                    store.showToast("PDF exported", type: .success)
                }
                .buttonStyle(.bordered)
                Button("Email Report") { }
                    .buttonStyle(.bordered)
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 500)
    }
}