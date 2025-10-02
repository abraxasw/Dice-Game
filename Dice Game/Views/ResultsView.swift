import SwiftUI

extension View {
    func cardStyle(cornerRadius: CGFloat = 16, shadowRadius: CGFloat = 8, shadowY: CGFloat = 4) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: shadowRadius, y: shadowY)
        }
    }
}

struct ResultsView: View {
    let teams: [Team]
    let currentRound: Int
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Team Statistics Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Team Statistics")
                                .font(.title2.bold())
                                .foregroundStyle(.primary)
                            
                            ForEach(teams) { team in
                                TeamStatsCard(team: team)
                            }
                        }
                        .padding()
                        
                        // Round Statistics Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Round Statistics")
                                .font(.title2.bold())
                                .foregroundStyle(.primary)
                            
                            ForEach(1..<currentRound, id: \.self) { round in
                                RoundStatsCard(round: round, teams: teams)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct TeamStatsCard: View {
    let team: Team
    
    var averageTimePerPerson: TimeInterval? {
        guard let avg = team.averageDuration else { return nil }
        return avg / Double(team.playerCount)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(team.name)
                .font(.title3.bold())
            
            // Round Times
            VStack(spacing: 8) {
                ForEach(Array(team.rounds.enumerated()), id: \.offset) { index, round in
                    if let first = round.firstDiceTime, let duration = round.duration {
                        HStack {
                            Text("Round \(index + 1)")
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            HStack(spacing: 16) {
                                Label(String(format: "%.2fs", first), systemImage: "1.circle")
                                    .foregroundStyle(.blue)
                                
                                Label(String(format: "%.2fs", duration), systemImage: "clock")
                                    .foregroundStyle(.purple)
                            }
                        }
                        .font(.subheadline.monospacedDigit())
                    }
                }
                
                Divider()
                    .padding(.vertical, 4)
                
                if let avg = team.averageDuration {
                    StatRow(
                        label: "Average Time",
                        value: String(format: "%.2fs", avg),
                        icon: "clock.fill",
                        color: .purple
                    )
                }
                
                if let avgPerPerson = averageTimePerPerson {
                    StatRow(
                        label: "Average per Person",
                        value: String(format: "%.2fs", avgPerPerson),
                        icon: "person.fill",
                        color: .green
                    )
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle(shadowY: 0)
    }
}

struct RoundStatsCard: View {
    let round: Int
    let teams: [Team]
    @State private var isExpanded = false
    
    var roundResults: [(team: Team, duration: TimeInterval)] {
        teams.compactMap { team in
            guard round <= team.rounds.count,
                  let duration = team.rounds[round - 1].duration else {
                return nil
            }
            return (team, duration)
        }
        .sorted { $0.duration < $1.duration }
    }
    
    var averageTime: TimeInterval? {
        guard !roundResults.isEmpty else { return nil }
        let total = roundResults.reduce(0) { $0 + $1.duration }
        return total / Double(roundResults.count)
    }
    
    var standardDeviation: TimeInterval? {
        guard let avg = averageTime, roundResults.count > 1 else { return nil }
        let variance = roundResults.map { pow($0.duration - avg, 2) }.reduce(0, +) / Double(roundResults.count - 1)
        return sqrt(variance)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Round \(round)")
                .font(.headline)
            
            if let avg = averageTime {
                StatRow(
                    label: "Average Time",
                    value: String(format: "%.2fs", avg),
                    icon: "clock.fill",
                    color: .blue
                )
            }
            
            if let std = standardDeviation {
                StatRow(
                    label: "Standard Deviation",
                    value: String(format: "%.2fs", std),
                    icon: "chart.bar.fill",
                    color: .purple
                )
            }
            
            Divider()
                .padding(.vertical, 4)
            
            ForEach(roundResults, id: \.team.id) { result in
                HStack {
                    Text(result.team.name)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text(String(format: "%.2fs", result.duration))
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .cardStyle(shadowY: 0)
    }
}

struct StatRow: View {
    let label: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)
            
            Text(label)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
                .monospacedDigit()
        }
        .font(.subheadline)
    }
} 