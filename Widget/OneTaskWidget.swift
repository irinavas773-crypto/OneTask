import WidgetKit
import SwiftUI

struct SimpleEntry: TimelineEntry {
    let date: Date
    let title: String
    let pendingCount: Int
}

struct Provider: TimelineProvider {
    private static let storageKey = "taskQueue"

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), title: "Current task", pendingCount: 2)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let entry = loadEntry()
        let next = Calendar.current.date(byAdding: .minute, value: 15, to: entry.date) ?? entry.date
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func loadEntry() -> SimpleEntry {
        let defaults = UserDefaults.standard
        guard
            let data = defaults.data(forKey: Self.storageKey),
            let queue = try? JSONDecoder().decode(TaskQueue.self, from: data)
        else {
            return SimpleEntry(date: Date(), title: "No tasks", pendingCount: 0)
        }
        return SimpleEntry(
            date: Date(),
            title: queue.current?.title ?? "No tasks",
            pendingCount: queue.pending.count
        )
    }
}

struct OneTaskWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Now")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(entry.title)
                .font(.headline)
                .lineLimit(3)
                .minimumScaleFactor(0.7)

            Spacer(minLength: 0)

            if entry.pendingCount > 0 {
                Text("\(entry.pendingCount) more in queue")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct OneTaskWidget: Widget {
    let kind: String = "OneTaskWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            OneTaskWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("OneTask")
        .description("Your current task from the queue.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
