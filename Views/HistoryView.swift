import SwiftUI

struct HistoryView: View {
    @ObservedObject var store: TaskStore
    let onClear: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if store.completed.isEmpty {
                    ContentUnavailableView(
                        "No completed tasks",
                        systemImage: "checkmark.circle",
                        description: Text("Finished tasks will appear here.")
                    )
                } else {
                    List(store.completed) { task in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(task.title)
                                .font(.body.weight(.medium))
                            if let date = task.completedAt {
                                Text(date, format: .dateTime.day().month().hour().minute())
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .destructiveAction) {
                    Button("Clear", role: .destructive, action: onClear)
                        .disabled(store.completed.isEmpty)
                }
            }
        }
    }
}
