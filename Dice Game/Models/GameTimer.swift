import Foundation

class GameTimer: ObservableObject {
    @Published var isRunning = false
    @Published var elapsedTime: TimeInterval = 0
    private var startTime: Date?
    private var timer: Timer?
    
    var roundStartTime: TimeInterval = 0
    
    var formattedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        let milliseconds = Int((elapsedTime.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
    
    var progressPercentage: Double {
        let roundLength: TimeInterval = 60
        return min(elapsedTime / roundLength, 1.0)
    }
    
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
    
    func pause() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        if let startTime = startTime {
            elapsedTime = Date().timeIntervalSince(startTime)
        }
    }
    
    func resume() {
        startTime = Date().addingTimeInterval(-elapsedTime)
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.startTime else { return }
            self.elapsedTime = Date().timeIntervalSince(startTime)
        }
    }
} 