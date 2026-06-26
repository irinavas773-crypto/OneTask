import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: SettingsStore
    @ObservedObject var theme: ThemeStore
    @ObservedObject var categories: CategoryStore
    @ObservedObject var store: TaskStore
    let onClearHistory: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var showHistory = false

    var body: some View {
        NavigationStack {
            Form {
                focusSection
                appearanceSection
                organizationSection
                remindersSection
                feedbackSection
                dataSection
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

    private var focusSection: some View {
        Section("Focus timer") {
            Picker("Mode", selection: $settings.timerMode) {
                ForEach(TimerMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }

            if settings.timerMode == .pomodoro {
                Stepper("Focus: \(settings.workMinutes) min",
                        value: $settings.workMinutes, in: 5...90, step: 5)
                Stepper("Short break: \(settings.shortBreakMinutes) min",
                        value: $settings.shortBreakMinutes, in: 1...30)
                Stepper("Long break: \(settings.longBreakMinutes) min",
                        value: $settings.longBreakMinutes, in: 5...45, step: 5)
                Stepper("Sessions before long break: \(settings.sessionsBeforeLongBreak)",
                        value: $settings.sessionsBeforeLongBreak, in: 2...8)
            }
        }
    }

    private var appearanceSection: some View {
        Section("Appearance") {
            Picker("Theme", selection: $theme.appearance) {
                ForEach(AppearanceMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Accent color")
                    .font(.subheadline)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                    ForEach(ThemeStore.accents) { option in
                        Circle()
                            .fill(option.color)
                            .frame(width: 30, height: 30)
                            .overlay(
                                Circle().stroke(Color.primary, lineWidth: theme.accentID == option.id ? 3 : 0)
                            )
                            .onTapGesture { theme.accentID = option.id }
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var organizationSection: some View {
        Section("Organization") {
            NavigationLink {
                CategoryManagerView(store: categories)
            } label: {
                Label("Categories", systemImage: "tag")
            }
        }
    }

    private var remindersSection: some View {
        Section("Reminders") {
            Toggle("Timer reminder", isOn: $settings.remindersEnabled)
            if settings.remindersEnabled {
                Stepper("After \(settings.reminderMinutes) min",
                        value: $settings.reminderMinutes, in: 1...180)
            }
        }
    }

    private var feedbackSection: some View {
        Section("Feedback") {
            Toggle("Haptics on completion", isOn: $settings.hapticsEnabled)
        }
    }

    private var dataSection: some View {
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
}
