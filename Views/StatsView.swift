import SwiftUI
import Charts

struct StatsView: View {
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    summaryCards
                    focusChartCard
                    tasksChartCard
                    streakCard
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    // MARK: - Cards

    private var summaryCards: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(title: "Focus today", value: "\(todayFocusMinutes)m", systemImage: "timer", tint: .blue)
            StatCard(title: "Done today", value: "\(todayTasks)", systemImage: "checkmark.circle", tint: .green)
            StatCard(title: "Current streak", value: "\(streak)d", systemImage: "flame", tint: .orange)
            StatCard(title: "Total focus", value: "\(totalFocusHours)h", systemImage: "hourglass", tint: .purple)
        }
    }

    private var focusChartCard: some View {
        ChartCard(title: "Focus minutes — last 7 days") {
            Chart(last7Days) { bar in
                BarMark(
                    x: .value("Day", bar.label),
                    y: .value("Minutes", bar.focusMinutes)
                )
                .foregroundStyle(viewModel.theme.accentColor.gradient)
                .cornerRadius(6)
            }
            .frame(height: 170)
        }
    }

    private var tasksChartCard: some View {
        ChartCard(title: "Tasks completed — last 7 days") {
            Chart(last7Days) { bar in
                BarMark(
                    x: .value("Day", bar.label),
                    y: .value("Tasks", bar.tasks)
                )
                .foregroundStyle(Color.green.gradient)
                .cornerRadius(6)
            }
            .chartYAxis {
                AxisMarks(values: .automatic(desiredCount: 4))
            }
            .frame(height: 170)
        }
    }

    private var streakCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "flame.fill")
                .font(.title)
                .foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text(streak > 0 ? "\(streak)-day streak" : "No streak yet")
                    .font(.headline)
                Text(streak > 0
                     ? "Complete a task today to keep it going."
                     : "Finish a task to start a streak.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(totalTasks) total")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Data

    private struct DayBar: Identifiable {
        let id = UUID()
        let date: Date
        let label: String
        let focusMinutes: Double
        let tasks: Int
    }

    private var last7Days: [DayBar] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let sessions = viewModel.stats.sessions
        let completed = viewModel.completedTasks

        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"

        return (0..<7).reversed().map { offset in
            let day = calendar.date(byAdding: .day, value: -offset, to: today) ?? today
            let nextDay = calendar.date(byAdding: .day, value: 1, to: day) ?? day

            let focus = sessions
                .filter { $0.date >= day && $0.date < nextDay }
                .reduce(0) { $0 + $1.seconds }

            let tasks = completed.filter {
                guard let completedAt = $0.completedAt else { return false }
                return completedAt >= day && completedAt < nextDay
            }.count

            return DayBar(
                date: day,
                label: formatter.string(from: day),
                focusMinutes: (focus / 60).rounded(),
                tasks: tasks
            )
        }
    }

    private var streak: Int {
        let calendar = Calendar.current
        let days = Set(viewModel.completedTasks
            .compactMap { $0.completedAt }
            .map { calendar.startOfDay(for: $0) })
        guard !days.isEmpty else { return 0 }

        var day = calendar.startOfDay(for: Date())
        if !days.contains(day) {
            // Allow the streak to count from yesterday if nothing done today yet.
            day = calendar.date(byAdding: .day, value: -1, to: day) ?? day
            if !days.contains(day) { return 0 }
        }

        var count = 0
        while days.contains(day) {
            count += 1
            day = calendar.date(byAdding: .day, value: -1, to: day) ?? day
        }
        return count
    }

    private var todayFocusMinutes: Int {
        Int((last7Days.last?.focusMinutes ?? 0).rounded())
    }

    private var todayTasks: Int {
        last7Days.last?.tasks ?? 0
    }

    private var totalFocusHours: String {
        let total = viewModel.stats.sessions.reduce(0) { $0 + $1.seconds }
        return String(format: "%.1f", total / 3600)
    }

    private var totalTasks: Int {
        viewModel.completedTasks.count
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let systemImage: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(tint)
            Text(value)
                .font(.title.weight(.bold))
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct ChartCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            content
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}
