import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    @State private var isDrawerOpen: Bool = false
    @State private var dragOffset: CGFloat = 0
    @State private var showSettings: Bool = false
    @State private var showAddTask: Bool = false
    @State private var newTaskTitle: String = ""

    var body: some View {
        GeometryReader { geo in
            let drawerHeight = geo.size.height * 0.7
            let peekHeight: CGFloat = 84
            let closedOffset = geo.size.height - peekHeight
            let openOffset = geo.size.height - drawerHeight

            ZStack(alignment: .bottom) {
                Color(.systemBackground)
                    .ignoresSafeArea()

                content(in: geo.size)

                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .padding(12)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(.trailing, 8)

                if viewModel.showConfetti {
                    ConfettiView(duration: 1.5)
                        .ignoresSafeArea()
                        .transition(.opacity)
                }

                QueueDrawerView(viewModel: viewModel, isDrawerOpen: $isDrawerOpen)
                    .frame(height: drawerHeight)
                    .offset(y: (isDrawerOpen ? openOffset : closedOffset) + dragOffset)
                    .animation(.spring(response: 0.4, dampingFraction: 0.85), value: isDrawerOpen)
                    .onTapGesture {
                        if !isDrawerOpen { isDrawerOpen = true }
                    }
                    .gesture(drawerDrag(open: openOffset, closed: closedOffset))
            }
            .gesture(edgeDrag())
            .sheet(isPresented: $showSettings) {
                SettingsView(
                    settings: viewModel.settings,
                    store: viewModel.store,
                    onClearHistory: viewModel.clearHistory
                )
            }
            .alert("New task", isPresented: $showAddTask) {
                TextField("Task title", text: $newTaskTitle)
                Button("Cancel", role: .cancel) { }
                Button("Add") {
                    viewModel.addTask(newTaskTitle)
                    newTaskTitle = ""
                }
            } message: {
                Text("Enter what you want to focus on.")
            }
        }
    }

    private func content(in size: CGSize) -> some View {
        VStack(spacing: 24) {
            Spacer()

            Group {
                if let task = viewModel.currentTask {
                    Text(task.title)
                        .font(.system(size: 42, weight: .bold))
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5)
                        .padding(.horizontal, 24)
                } else {
                    Text("No tasks")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(height: size.height * 0.6)

            Text(viewModel.timerText)
                .font(.system(size: 28, weight: .medium, design: .monospaced))
                .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                Button(action: { viewModel.completeCurrentTask() }) {
                    Text("Done")
                        .font(.title2.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.hasTask)

                Button {
                    newTaskTitle = ""
                    showAddTask = true
                } label: {
                    Label("Add task", systemImage: "plus")
                        .font(.body.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 32)

            Spacer()
        }
        .animation(.default, value: viewModel.showConfetti)
    }

    private func drawerDrag(open: CGFloat, closed: CGFloat) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if isDrawerOpen {
                    dragOffset = max(0, value.translation.height)
                } else {
                    dragOffset = min(0, value.translation.height)
                }
            }
            .onEnded { value in
                dragOffset = 0
                if value.translation.height < -80 {
                    isDrawerOpen = true
                } else if value.translation.height > 80 {
                    isDrawerOpen = false
                }
            }
    }

    private func edgeDrag() -> some Gesture {
        DragGesture()
            .onEnded { value in
                guard !isDrawerOpen else { return }
                if value.translation.height < -80 {
                    isDrawerOpen = true
                }
            }
    }
}

#Preview {
    MainView()
}
