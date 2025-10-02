import Foundation

struct Team: Identifiable {
    let id = UUID()
    var name: String
    var playerCount: Int
    var rounds: [RoundTiming] = []
    
    struct RoundTiming {
        var firstDiceTime: TimeInterval?
        var lastDiceTime: TimeInterval?

        var duration: TimeInterval? {
            guard let first = firstDiceTime, let last = lastDiceTime else { return nil }
            return last - first
        }
    }
    
    mutating func recordFirstDice(at time: TimeInterval, forRound round: Int) {
        while rounds.count < round {
            rounds.append(RoundTiming())
        }
        rounds[round - 1].firstDiceTime = time
    }
    
    mutating func recordLastDice(at time: TimeInterval, forRound round: Int) {
        while rounds.count < round {
            rounds.append(RoundTiming())
        }
        if rounds[round - 1].firstDiceTime != nil {
            rounds[round - 1].lastDiceTime = time
        }
    }
    
    mutating func resetRounds() {
        rounds = []
    }
    
    var averageDuration: TimeInterval? {
        let completedRounds = rounds.compactMap { $0.duration }
        guard !completedRounds.isEmpty else { return nil }
        return completedRounds.reduce(0, +) / Double(completedRounds.count)
    }
    
    var standardDeviation: TimeInterval? {
        let completedRounds = rounds.compactMap { $0.duration }
        guard let avg = averageDuration, completedRounds.count > 1 else { return nil }
        
        let variance = completedRounds.map { pow($0 - avg, 2) }.reduce(0, +) / Double(completedRounds.count - 1)
        return sqrt(variance)
    }
    
    var fastestRound: (round: Int, duration: TimeInterval)? {
        guard let minDuration = rounds.compactMap({ $0.duration }).min(),
              let roundIndex = rounds.firstIndex(where: { $0.duration == minDuration }) else {
            return nil
        }
        return (roundIndex + 1, minDuration)
    }
} 