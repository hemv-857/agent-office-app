// WorkflowAgentAgentSchedulingCalendarView.swift
import SwiftUI

struct WorkflowAgentAgentSchedulingCalendarView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var currentDate = Date()
    @State private var selectedDate: Date? = Date()

    private let calendar = Calendar.current
    private let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Scheduling Calendar").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Month navigation
            HStack {
                Button(action: { changeMonth(-1) }) {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(.plain)
                Text(monthYearString)
                    .font(.system(size: 13, weight: .semibold))
                Button(action: { changeMonth(1) }) {
                    Image(systemName: "chevron.right")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            // Day headers
            HStack(spacing: 0) {
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 4)

            Divider()

            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 2) {
                ForEach(0..<dayOffset, id: \.self) { _ in
                    Color.clear.frame(height: 36)
                }
                ForEach(1...daysInMonth, id: \.self) { day in
                    CalendarDayCell(
                        day: day,
                        isSelected: isSelected(day),
                        hasEvents: hasEvents(day),
                        onTap: { selectDay(day) }
                    )
                }
            }
            .padding(.horizontal)

            Divider()

            // Events for selected date
            if let selected = selectedDate {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Events for \(dayString(selected))")
                        .font(.system(size: 11, weight: .semibold))
                        .padding(.horizontal)
                    ScrollView {
                        VStack(spacing: 4) {
                            ForEach(eventsForDate(selected), id: \.0) { event in
                                HStack {
                                    Circle().fill(event.1).frame(width: 8, height: 8)
                                    Text(event.0)
                                        .font(.system(size: 10))
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .frame(height: 120)
                }
                .padding()
            }

            Divider()

            HStack {
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 380, height: 520)
    }

    private var dayOffset: Int {
        let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
        return calendar.component(.weekday, from: firstOfMonth) - 1
    }

    private var daysInMonth: Int {
        calendar.range(of: .day, in: .month, for: currentDate)!.count
    }

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentDate)
    }

    private func changeMonth(_ delta: Int) {
        currentDate = calendar.date(byAdding: .month, value: delta, to: currentDate)!
    }

    private func isSelected(_ day: Int) -> Bool {
        guard let selected = selectedDate else { return false }
        return calendar.component(.day, from: selected) == day &&
               calendar.component(.month, from: selected) == calendar.component(.month, from: currentDate) &&
               calendar.component(.year, from: selected) == calendar.component(.year, from: currentDate)
    }

    private func selectDay(_ day: Int) {
        var components = calendar.dateComponents([.year, .month], from: currentDate)
        components.day = day
        selectedDate = calendar.date(from: components)
    }

    private func dayString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }

    private func hasEvents(_ day: Int) -> Bool {
        [5, 12, 19, 26].contains(day)
    }

    private func eventsForDate(_ date: Date) -> [(String, Color)] {
        let day = calendar.component(.day, from: date)
        switch day {
        case 5: return [("Daily Standup", .blue), ("Code Review", .green)]
        case 12: return [("Sprint Planning", .orange), ("Security Scan", .red)]
        case 19: return [("Weekly Report", .purple)]
        case 26: return [("Model Retraining", .cyan)]
        default: return []
        }
    }
}

// MARK: - Calendar Day Cell
struct CalendarDayCell: View {
    let day: Int
    let isSelected: Bool
    let hasEvents: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text("\(day)")
                    .font(.system(size: 12, weight: isSelected ? .bold : .regular))
                    .foregroundStyle(isSelected ? .white : .primary)
                if hasEvents {
                    Circle()
                        .fill(.blue)
                        .frame(width: 4, height: 4)
                }
            }
            .frame(height: 36)
            .frame(maxWidth: .infinity)
            .background(isSelected ? .blue : .clear, in: RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
    }
}