import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void

    @State private var page = 0

    private struct Page {
        let symbol: String
        let title: String
        let text: String
        let color: Color
    }

    private let pages: [Page] = [
        Page(
            symbol: "target",
            title: "One task at a time",
            text: "OneTask shows you a single thing to focus on — no endless lists, no overwhelm. The rest waits quietly in your queue.",
            color: .blue
        ),
        Page(
            symbol: "timer",
            title: "Focus with intention",
            text: "Use the built-in Pomodoro timer or a stopwatch to stay in deep work, then take mindful breaks between sessions.",
            color: .orange
        ),
        Page(
            symbol: "chart.bar.fill",
            title: "See your progress",
            text: "Track focus time, completed tasks and daily streaks. Organize work with categories, subtasks and themes.",
            color: .green
        )
    ]

    var body: some View {
        VStack {
            TabView(selection: $page) {
                ForEach(pages.indices, id: \.self) { index in
                    let item = pages[index]
                    VStack(spacing: 24) {
                        Spacer()
                        Image(systemName: item.symbol)
                            .font(.system(size: 84, weight: .semibold))
                            .foregroundStyle(item.color)
                        Text(item.title)
                            .font(.largeTitle.bold())
                            .multilineTextAlignment(.center)
                        Text(item.text)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            Button(action: next) {
                Text(page == pages.count - 1 ? "Get started" : "Next")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }

    private func next() {
        if page < pages.count - 1 {
            withAnimation { page += 1 }
        } else {
            onFinish()
        }
    }
}
