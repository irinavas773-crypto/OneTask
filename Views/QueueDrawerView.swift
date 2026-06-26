import SwiftUI

struct QueueDrawerView: View {
    @ObservedObject var viewModel: MainViewModel
    @Binding var isDrawerOpen: Bool

    @State private var newTaskTitle: String = ""
    @FocusState private var fieldFocused: Bool
    @State private var editMode: EditMode = .inactive
    @State private var detailTask: Task?

    var body: some View {
        VStack(spacing: 0) {
            grabber
            header
            addRow
            list
        }
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(radius: 12, y: -4)
        .sheet(item: $detailTask) { task in
            TaskDetailView(task: task, viewModel: viewModel)
        }
    }

    private var grabber: some View {
        Capsule()
            .fill(Color.secondary.opacity(0.4))
            .frame(width: 44, height: 5)
            .padding(.top, 10)
            .padding(.bottom, 12)
    }

    private var header: some View {
        HStack {
            Text("Tasks")
                .font(.headline)
            Spacer()
            if !viewModel.pendingTasks.isEmpty {
                Button(editMode.isEditing ? "Done" : "Reorder") {
                    withAnimation { editMode = editMode.isEditing ? .inactive : .active }
                }
                .font(.subheadline.weight(.semibold))
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 4)
    }

    private var addRow: some View {
        HStack(spacing: 8) {
            TextField("New task", text: $newTaskTitle)
                .textFieldStyle(.roundedBorder)
                .focused($fieldFocused)
                .submitLabel(.done)
                .onSubmit(addTask)

            Button("Add", action: addTask)
                .buttonStyle(.borderedProminent)
                .disabled(newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }

    private var list: some View {
        List {
            if let current = viewModel.currentTask {
                Section("Current") {
                    row(current)
                }
            }
            Section("Up next") {
                if viewModel.pendingTasks.isEmpty {
                    Text("Empty")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.pendingTasks) { task in
                        row(task)
                    }
                    .onDelete(perform: deleteTasks)
                    .onMove(perform: viewModel.moveTask)
                }
            }
        }
        .listStyle(.insetGrouped)
        .environment(\.editMode, $editMode)
    }

    private func row(_ task: Task) -> some View {
        Button {
            detailTask = task
        } label: {
            HStack(spacing: 10) {
                if let category = viewModel.categories.category(for: task.categoryID) {
                    Circle()
                        .fill(category.color)
                        .frame(width: 10, height: 10)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title)
                        .foregroundStyle(.primary)
                    if task.hasSubtasks {
                        let progress = task.subtaskProgress
                        Text("\(progress.done)/\(progress.total) subtasks")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
        .tint(.primary)
    }

    private func addTask() {
        viewModel.addTask(newTaskTitle)
        newTaskTitle = ""
        fieldFocused = false
    }

    private func deleteTasks(at offsets: IndexSet) {
        for index in offsets {
            let task = viewModel.pendingTasks[index]
            viewModel.removeTask(task)
        }
    }
}
