// CostBreakdownPieChartView.swift
import SwiftUI

struct CostBreakdownPieChartView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    private let segments: [(String, Double, Color)] = [
        ("Anthropic", 45.0, .orange),
        ("OpenAI", 30.0, .green),
        ("Ollama", 0.0, .blue),
        ("Cache Hits", 15.0, .purple),
        ("Retries", 10.0, .red),
    ]

    var total: Double {
        segments.reduce(0) { $0 + $1.1 }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Cost Breakdown").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            HStack(spacing: 24) {
                // Pie chart
                PieChartView(segments: segments, total: total)
                    .frame(width: 180, height: 180)

                // Legend
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(segments, id: \.0) { segment in
                        HStack {
                            Circle()
                                .fill(segment.2)
                                .frame(width: 10, height: 10)
                            Text(segment.0)
                                .font(.system(size: 11))
                            Spacer()
                            Text(String(format: "$%.2f", segment.1))
                                .font(.system(size: 11, design: .monospaced))
                            Text(String(format: "%.0f%%", segment.1 / total * 100))
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                    }

                    Divider()

                    HStack {
                        Text("Total")
                            .font(.system(size: 12, weight: .semibold))
                        Spacer()
                        Text(String(format: "$%.2f", total))
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                    }
                }
            }
            .padding()

            Spacer()

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 480, height: 350)
    }
}

// MARK: - Pie Chart
struct PieChartView: View {
    let segments: [(String, Double, Color)]
    let total: Double

    var body: some View {
        ZStack {
            ForEach(segments.indices, id: \.self) { index in
                PieSlice(
                    startAngle: angle(for: index),
                    endAngle: angle(for: index + 1)
                )
                .fill(segments[index].2)
            }
            Circle()
                .fill(Color(nsColor: .windowBackgroundColor))
                .frame(width: 60, height: 60)
            Text(String(format: "$%.2f", total))
                .font(.system(size: 11, weight: .bold, design: .monospaced))
        }
    }

    func angle(for index: Int) -> Angle {
        let cumulative = segments.prefix(index).reduce(0) { $0 + $1.1 }
        return .degrees(cumulative / total * 360 - 90)
    }
}

// MARK: - Pie Slice Shape
struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()
        return path
    }
}
