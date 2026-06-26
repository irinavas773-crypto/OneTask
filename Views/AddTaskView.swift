import SwiftUI

struct AddTaskView: View {
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var categoryID: UUID?
    @State private var subtasks: [Subtask] = []
    @State private var newSubtask: String = ""
    @FocusState private var titleFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section("Task") {
                    TextField("What do you want to focus on?", text: $title, axis: .vertical)
                        .focused($titleFocused)
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

                Section("Subtasks (optional)") {
                    ForEach($subtasks) { $subtask in
                        TextField("Subtask", text: $subtask.title)
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
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { add() }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { titleFocused = true }
        }
    }

    private func addSubtask() {
        let trimmed = newSubtask.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        subtasks.append(Subtask(title: trimmed))
        newSubtask = ""
    }

    private func add() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let cleaned = subtasks.filter { !$0.title.trimmingCharacters(in: .whitespaces).isEmpty }
        viewModel.addTaskDetailed(title: trimmed, categoryID: categoryID, subtasks: cleaned)
        dismiss()
    }
}
