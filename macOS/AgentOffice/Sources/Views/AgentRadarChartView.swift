// AgentRadarChartView.swift
import SwiftUI

struct AgentRadarChartView: View {
    let agent: Agent
    let metrics: AgentMetrics

    var body: some View {
        VStack(spacing: 8) {
            Text("\(agent.emoji) \(agent.name) Skill Profile")
                .font(.system(size: 13, weight: .semibold))

            RadarChartView(
                data: [
                    ("Speed", metrics.speedRating),
                    ("Quality", metrics.qualityRating),
                    ("Creativity", metrics.creativityRating),
                    ("Accuracy", metrics.accuracyRating),
                    ("Helpfulness", metrics.helpfulnessRating),
                ],
                maxValue: 5
            )
            .frame(width: 200, height: 200)
        }
        .padding()
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Radar Chart
struct RadarChartView: View {
    let data: [(String, Double)]
    let maxValue: Double

    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = min(geometry.size.width, geometry.size.height) / 2 - 20
            let angleStep = 2 * .pi / Double(data.count)

            ZStack {
                // Grid circles
                ForEach(1...5, id: \.self) { level in
                    let levelRadius = radius * Double(level) / 5.0
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                        .frame(width: levelRadius * 2, height: levelRadius * 2)
                }

                // Axis lines
                ForEach(0..<data.count, id: \.self) { index in
                    let angle = angleStep * Double(index) - .pi / 2
                    Path { path in
                        path.move(to: center)
                        path.addLine(to: CGPoint(
                            x: center.x + cos(angle) * radius,
                            y: center.y + sin(angle) * radius
                        ))
                    }
                    .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                }

                // Data polygon
                Path { path in
                    for (index, item) in data.enumerated() {
                        let angle = angleStep * Double(index) - .pi / 2
                        let value = item.1 / maxValue
                        let point = CGPoint(
                            x: center.x + cos(angle) * radius * value,
                            y: center.y + sin(angle) * radius * value
                        )
                        if index == 0 {
                            path.move(to: point)
                        } else {
                            path.addLine(to: point)
                        }
                    }
                    path.closeSubpath()
                }
                .fill(Color.accentColor.opacity(0.3))
                .stroke(Color.accentColor, lineWidth: 1.5)

                // Data points
                ForEach(0..<data.count, id: \.self) { index in
                    let angle = angleStep * Double(index) - .pi / 2
                    let value = data[index].1 / maxValue
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 6, height: 6)
                        .position(
                            x: center.x + cos(angle) * radius * value,
                            y: center.y + sin(angle) * radius * value
                        )
                }

                // Labels
                ForEach(0..<data.count, id: \.self) { index in
                    let angle = angleStep * Double(index) - .pi / 2
                    let labelRadius = radius + 15
                    Text(data[index].0)
                        .font(.system(size: 8))
                        .position(
                            x: center.x + cos(angle) * labelRadius,
                            y: center.y + sin(angle) * labelRadius
                        )
                }
            }
        }
    }
}

// MARK: - Agent Metrics Model
struct AgentMetrics {
    var speedRating: Double = 3.0
    var qualityRating: Double = 3.0
    var creativityRating: Double = 3.0
    var accuracyRating: Double = 3.0
    var helpfulnessRating: Double = 3.0

    static func random() -> AgentMetrics {
        AgentMetrics(
            speedRating: Double.random(in: 2...5),
            qualityRating: Double.random(in: 2...5),
            creativityRating: Double.random(in: 2...5),
            accuracyRating: Double.random(in: 2...5),
            helpfulnessRating: Double.random(in: 2...5)
        )
    }
}
