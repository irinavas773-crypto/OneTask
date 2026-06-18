import Foundation
import Combine

final class TimerService: ObservableObject {
    @Published var elapsed: TimeInterval = 0

    private var cancellable: AnyCancellable?
    private var startDate: Date?

    var formatted: String {
        let total = Int(elapsed)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func start() {
        reset()
        startDate = Date()
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, let startDate = self.startDate else { return }
                self.elapsed = Date().timeIntervalSince(startDate)
            }
    }

    func reset() {
        cancellable?.cancel()
        cancellable = nil
        startDate = nil
        elapsed = 0
    }
}
