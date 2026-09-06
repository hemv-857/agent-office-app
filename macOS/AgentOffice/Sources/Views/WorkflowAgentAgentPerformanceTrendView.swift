// WorkflowAgentAgentPerformanceTrendView.swift
import SwiftUI

struct WorkflowAgentAgentPerformanceTrendView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let trends: [(String, [Double])] = [
        ("Architect", [92.1, 93.5, 94.2, 95.0, 95.8, 96.2]),
        ("Builder", [90.5, 91.8, 92.5, 93.2, 94.0, 94.8]),
        ("Reviewer", [95.0, 95.5, 96.0, 96.5, 96.8, 97.1]),
        ("Tester", [89.0, 90.2, 91.5, 92.0, 92.8, 93.5]),
        ("Planner", [92.0, 92.8, 93.5, 94.0, 94.5, 95.0]),
        ("Security", [96.0, 96.5, 97.0, 97.5, 97.8, 98.0]),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Performance Trends").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Legend
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(trends.indices, id: \.self) { i in
                        Circle()
                            .fill(colorForIndex(i))
                            .frame(width: 10, height: 10)
                        Text(trends[i].0)
                            .font(.system(size: 10))
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            // Chart area
            GeometryReader { geo in
                VStack {
                    // Y-axis labels
                    HStack(spacing: 0) {
                        VStack(alignment: .trailing, spacing: 0) {
                            ForEach([100, 95, 90, 85], id: \.self) { val in
                                Text("\(val)%")
                                    .font(.system(size: 8))
                                    .foregroundStyle(.secondary)
                                    .frame(height: (geo.size.height - 40) / 3)
                            }
                        }
                        .frame(width: 35)
                        Spacer()
                    }
                    .frame(height: geo.size.height - 40)

                    // Lines
                    ForEach(trends.indices, id: \.self) { i in
                        PerformanceTrendLine(
                            values: trends[i].1,
                            color: colorForIndex(i),
                            height: geo.size.height - 40,
                            width: geo.size.width - 40
                        )
                        .offset(x: 35)
                    }
                }
            }
            .padding(.bottom, 40)
            .padding(.horizontal, 8)

            // X-axis labels
            HStack(spacing: 0) {
                Text("")
                    .frame(width: 35)
                ForEach(["W1", "W2", "W3", "W4", "W5", "W6"], id: \.self) { week in
                    Text(week)
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 8)

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 500, height: 400)
    }

    private func colorForIndex(_ i: Int) -> Color {
        [.blue, .green, .orange, .purple, .cyan, .red][i % 6]
    }
}

// MARK: - Performance Trend Line
struct PerformanceTrendLine: View {
    let values: [Double]
    let color: Color
    let height: Double
    let width: Double

    var body: some View {
        Path { path in
            guard !values.isEmpty else { return }
            let stepX = width / Double(values.count - 1)
            let minY = 85.0
            let maxY = 100.0
            let scaleY = height / (maxY - minY)

            path.move(to: CGPoint(x: 0, y: height - (values[0] - minY) * scaleY))
            for (i, val) in values.enumerated() {
                let x = Double(i) * stepX
                let y = height - (val - minY) * scaleY
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        .stroke(color, lineWidth: 2)
    }
}