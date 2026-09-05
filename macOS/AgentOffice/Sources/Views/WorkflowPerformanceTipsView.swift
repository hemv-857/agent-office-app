// WorkflowPerformanceTipsView.swift
import SwiftUI

struct WorkflowPerformanceTipsView: View {
    @Environment(\.dismiss) var dismiss

    private let tips: [(String, String)] = [
        ("Use Parallel Mode", "Run independent tasks simultaneously for faster completion"),
        ("Cache Results", "Reuse previous results when inputs haven't changed"),
        ("Limit Token Usage", "Set max tokens per request to control costs"),
        ("Choose Right Model", "Use smaller models for simple tasks"),
        ("Batch Operations", "Combine related prompts to reduce API calls"),
        ("Monitor Performance", "Check the analytics dashboard regularly"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Performance Tips").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(tips.indices, id: \.self) { index in
                        PerformanceTipRow(
                            title: tips[index].0,
                            description: tips[index].1,
                            number: index + 1
                        )
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 450, height: 420)
    }
}

// MARK: - Performance Tip Row
struct PerformanceTipRow: View {
    let title: String
    let description: String
    let number: Int

    var body: some View {
        HStack(spacing: 10) {
            Text("\(number)")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
                .frame(width: 20, height: 20)
                .background(Color.accentColor, in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                Text(description)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
    }
}
