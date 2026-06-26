import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel

    @State private var isDrawerOpen: Bool = false
    @State private var dragOffset: CGFloat = 0
    @State private var showSettings: Bool = false
    @State private var showStats: Bool = false
    @State private var showAddTask: Bool = false
    @State private var showDetail: Bool = false

    var body: some View {
        GeometryReader { geo in
            let drawerHeight = geo.size.height * 0.72
            let peekHeight: CGFloat = 84
            let closedOffset = geo.size.height - peekHeight
            let openOffset = geo.size.height - drawerHeight

            ZStack(alignment: .bottom) {
                Color(.systemBackground)
                    .ignoresSafeArea()

                content(in: geo.size)

                topBar

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
                    theme: viewModel.theme,
                    categories: viewModel.categories,
                    store: viewModel.store,
                    onClearHistory: viewModel.clearHistory
                )
            }
            .sheet(isPresented: $showStats) {
                StatsView(viewModel: viewModel)
            }
            .sheet(isPresented: $showAddTask) {
                AddTaskView(viewModel: viewModel)
            }
            .sheet(isPresented: $showDetail) {
                if let task = viewModel.currentTask {
                    TaskDetailView(task: task, viewModel: viewModel)
                }
            }
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        VStack {
            HStack {
                Button { showStats = true } label: {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .padding(12)
                }
                Spacer()
                Button { showSettings = true } label: {
                    Image(systemName: "gearshape")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .padding(12)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 8)
    }

    // MARK: - Content

    private func content(in size: CGSize) -> some View {
        VStack(spacing: 22) {
            Spacer()

            if let task = viewModel.currentTask {
                currentTaskView(task)
            } else {
                emptyView
            }

            focusTimer

            controls

            Spacer()
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 96)
        .animation(.default, value: viewModel.showConfetti)
    }

    private func currentTaskView(_ task: Task) -> some View {
        VStack(spacing: 12) {
            if let category = viewModel.categories.category(for: task.categoryID) {
                CategoryChip(category: category)
            }

            Text(task.title)
                .font(.system(size: 38, weight: .bold))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.5)
                .lineLimit(4)

            if task.hasSubtasks {
                let progress = task.subtaskProgress
                Label("\(progress.done)/\(progress.total) subtasks", systemImage: "checklist")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Button { showDetail = true } label: {
                Label("Details", systemImage: "slider.horizontal.3")
                    .font(.footnote.weight(.semibold))
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .clipShape(Capsule())
        }
    }

    private var emptyView: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text("All done")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.secondary)
            Text("Add a task to start focusing.")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
    }

    private var focusTimer: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.15), lineWidth: 10)

            if viewModel.timerMode == .pomodoro {
                Circle()
                    .trim(from: 0, to: viewModel.timerProgress)
                    .stroke(phaseColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.2), value: viewModel.timerProgress)
            }

            VStack(spacing: 4) {
                Text(viewModel.timerText)
                    .font(.system(size: 42, weight: .semibold, design: .monospaced))
                    .monospacedDigit()
                Text(phaseLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
            }
        }
        .frame(width: 200, height: 200)
        .opacity(viewModel.hasTask ? 1 : 0.4)
    }

    private var controls: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button { viewModel.toggleTimer() } label: {
                    Label(
                        viewModel.isTimerRunning ? "Pause" : "Start",
                        systemImage: viewModel.isTimerRunning ? "pause.fill" : "play.fill"
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.bordered)
                .disabled(!viewModel.hasTask)

                Button { viewModel.skipPhase() } label: {
                    Label("Skip", systemImage: "forward.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.bordered)
                .disabled(!viewModel.hasTask || viewModel.timerMode == .stopwatch)
            }

            Button { viewModel.completeCurrentTask() } label: {
                Text("Done")
                    .font(.title3.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.hasTask)

            Button { showAddTask = true } label: {
                Label("Add task", systemImage: "plus")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.bordered)
        }
    }

    private var phaseLabel: String {
        viewModel.timerPhase == .idle ? viewModel.timerMode.title : viewModel.timerPhase.title
    }

    private var phaseColor: Color {
        viewModel.timerPhase.isBreak ? .green : viewModel.theme.accentColor
    }

    // MARK: - Gestures

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
    MainView(viewModel: MainViewModel())
}
