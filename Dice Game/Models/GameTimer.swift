import Foundation

class GameTimer: ObservableObject {
    @Published var isRunning = false
    @Published var elapsedTime: TimeInterval = 0
    private var startTime: Date?
    private var timer: Timer?
    
    var roundStartTime: TimeInterval = 0
    
    func start() {
        startTime = Date()
        roundStartTime = 0
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.startTime else { return }
            self.elapsedTime = Date().timeIntervalSince(startTime)
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
    
    func reset() {
        stop()
        elapsedTime = 0
        startTime = nil
        roundStartTime = 0
    }
} 