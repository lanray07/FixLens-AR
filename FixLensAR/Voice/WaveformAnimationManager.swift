import Foundation
import SwiftUI

@MainActor
final class WaveformAnimationManager: ObservableObject {
    @Published var samples: [CGFloat] = Array(repeating: 0.22, count: 34)
    private var timer: Timer?

    func start() {
        stop()
        timer = Timer.scheduledTimer(withTimeInterval: 0.09, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.samples = self?.samples.map { _ in CGFloat.random(in: 0.12...1.0) } ?? []
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        samples = Array(repeating: 0.22, count: 34)
    }
}
