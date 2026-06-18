import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: SettingsStore
    @ObservedObject var store: TaskStore
    let onClearHistory: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var showHistory = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Reminders") {
                    Toggle("Timer reminder", isOn: $settings.remindersEnabled)
                    if settings.remindersEnabled {
                        Stepper(
                            "After \(settings.reminderMinutes) min",
                            value: $settings.reminderMinutes,
                            in: 1...180
                        )
                    }
                }

                Section("Feedback") {
                    Toggle("Haptics on completion", isOn: $settings.hapticsEnabled)
                }

                Section {
                    Button {
                        showHistory = true
                    } label: {
                        HStack {
                            Text("Completed tasks")
                            Spacer()
                            Text("\(store.completed.count)")
                                .foregroundStyle(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .tint(.primary)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showHistory) {
                HistoryView(store: store, onClear: onClearHistory)
            }
        }
    }
}
