import SwiftUI

struct QueueDrawerView: View {
    @ObservedObject var viewModel: MainViewModel
    @Binding var isDrawerOpen: Bool

    @State private var newTaskTitle: String = ""
    @FocusState private var fieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.secondary.opacity(0.4))
                .frame(width: 44, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 12)

            HStack {
                Text("Tasks")
                    .font(.headline)
                Spacer()
                Label("Add task", systemImage: "plus.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .labelStyle(.titleAndIcon)
                    .foregroundStyle(.tint)
            }
            .padding(.horizontal)
            .padding(.bottom, 4)

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

            List {
                if let current = viewModel.currentTask {
                    Section("Current") {
                        Text(current.title)
                            .font(.body.weight(.semibold))
                    }
                }
                Section("Up next") {
                    if viewModel.pendingTasks.isEmpty {
                        Text("Empty")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(viewModel.pendingTasks) { task in
                            Text(task.title)
                        }
                        .onDelete(perform: deleteTasks)
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(radius: 12, y: -4)
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
