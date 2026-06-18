import SwiftUI

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var velocityX: CGFloat
    var velocityY: CGFloat
    var size: CGFloat
    var rotation: CGFloat
    var rotationSpeed: CGFloat
    var color: Color
}

struct ConfettiView: View {
    let duration: TimeInterval

    @State private var particles: [ConfettiParticle] = []
    @State private var startTime: Date = Date()

    private static let palette: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple, .pink, .mint
    ]

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let now = timeline.date.timeIntervalSince(startTime)
                let progress = min(now / duration, 1)
                let opacity = 1 - progress

                for particle in particles {
                    let t = now
                    let px = particle.x + particle.velocityX * t
                    let py = particle.y + particle.velocityY * t + 0.5 * 400 * t * t
                    let rotation = particle.rotation + particle.rotationSpeed * t

                    var rect = Path(
                        CGRect(
                            x: -particle.size / 2,
                            y: -particle.size / 2,
                            width: particle.size,
                            height: particle.size * 0.6
                        )
                    )

                    var transform = CGAffineTransform.identity
                    transform = transform.translatedBy(x: px * size.width, y: py * size.height)
                    transform = transform.rotated(by: rotation)
                    rect = rect.applying(transform)

                    context.fill(
                        rect,
                        with: .color(particle.color.opacity(opacity))
                    )
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear { generate() }
    }

    private func generate() {
        startTime = Date()
        particles = (0..<120).map { _ in
            ConfettiParticle(
                x: CGFloat.random(in: 0.3...0.7),
                y: CGFloat.random(in: 0.35...0.55),
                velocityX: CGFloat.random(in: -0.6...0.6),
                velocityY: CGFloat.random(in: -1.4...(-0.6)),
                size: CGFloat.random(in: 8...16),
                rotation: CGFloat.random(in: 0...(.pi * 2)),
                rotationSpeed: CGFloat.random(in: -6...6),
                color: Self.palette.randomElement() ?? .blue
            )
        }
    }
}
