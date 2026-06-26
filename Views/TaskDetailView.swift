import SwiftUI

struct TaskDetailView: View {
    let originalTask: Task
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var note: String
    @State private var categoryID: UUID?
    @State private var subtasks: [Subtask]
    @State private var newSubtask: String = ""

    init(task: Task, viewModel: MainViewModel) {
        self.originalTask = task
        self.viewModel = viewModel
        _title = State(initialValue: task.title)
        _note = State(initialValue: task.note)
        _categoryID = State(initialValue: task.categoryID)
        _subtasks = State(initialValue: task.subtasks)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Task") {
                    TextField("Title", text: $title, axis: .vertical)
                }

                Section("Category") {
                    Picker("Category", selection: $categoryID) {
                        Text("None").tag(UUID?.none)
                        ForEach(viewModel.categories.categories) { category in
                            Label(category.name, systemImage: category.symbol)
                                .tag(Optional(category.id))
                        }
                    }
                }

                Section("Subtasks") {
                    ForEach($subtasks) { $subtask in
                        HStack {
                            Button {
                                subtask.isDone.toggle()
                            } label: {
                                Image(systemName: subtask.isDone ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(subtask.isDone ? Color.accentColor : .secondary)
                            }
                            .buttonStyle(.plain)

                            TextField("Subtask", text: $subtask.title)
                                .strikethrough(subtask.isDone)
                                .foregroundStyle(subtask.isDone ? .secondary : .primary)
                        }
                    }
                    .onDelete { subtasks.remove(atOffsets: $0) }

                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.tint)
                        TextField("Add subtask", text: $newSubtask)
                            .submitLabel(.done)
                            .onSubmit(addSubtask)
                    }
                }

                Section("Notes") {
                    TextField("Notes", text: $note, axis: .vertical)
                        .lineLimit(3...8)
                }

                Section("Focus") {
                    HStack {
                        Text("Time focused")
                        Spacer()
                        Text(focusText)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                }
            }
        }
    }

    private var focusText: String {
        let total = Int(originalTask.focusSeconds)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }

    private func addSubtask() {
        let trimmed = newSubtask.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        subtasks.append(Subtask(title: trimmed))
        newSubtask = ""
    }

    private func save() {
        var updated = originalTask
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.title = trimmed.isEmpty ? originalTask.title : trimmed
        updated.note = note
        updated.categoryID = categoryID
        updated.subtasks = subtasks.filter { !$0.title.trimmingCharacters(in: .whitespaces).isEmpty }
        viewModel.updateTask(updated)
        dismiss()
    }
}
