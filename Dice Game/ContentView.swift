//
//  ContentView.swift
//  Dice Game
//
//  Created by Andrew Tam on 13/11/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameTimer = GameTimer()
    @State private var teams: [Team] = []
    @State private var currentRound = 1
    @State private var showingAddTeam = false
    @State private var showingResults = false
    @State private var showingResetConfirmation = false
    @State private var isResetting = false
    @State private var showingCompletionBanner = false
    
    var allTeamsFinished: Bool {
        guard !teams.isEmpty else { return false }
        return teams.allSatisfy { team in
            team.rounds.count >= currentRound && 
            team.rounds[currentRound - 1].lastDiceTime != nil
        }
    }
    
    var canStartTimer: Bool {
        !allTeamsFinished && !teams.isEmpty
    }
    
    func resetAll() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isResetting = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.4)) {
                currentRound = 1
                gameTimer.reset()
                for index in teams.indices {
                    teams[index].resetRounds()
                }
                isResetting = false
            }
        }
    }
    
    func resetEverything() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isResetting = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.4)) {
                currentRound = 1
                gameTimer.reset()
                teams = []
                isResetting = false
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Timer Card with Status
                    VStack(spacing: 8) {
                        HStack {
                            Text("Round \(currentRound)")
                                .font(.title2.bold())
                            
                            if gameTimer.isRunning {
                                Text("• In Progress")
                                    .foregroundStyle(.green)
                                    .font(.headline)
                            } else if allTeamsFinished {
                                Text("• Complete")
                                    .foregroundStyle(.blue)
                                    .font(.headline)
                            }
                        }
                        .foregroundStyle(.secondary)
                        
                        Text(String(format: "%.2f", gameTimer.elapsedTime))
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .contentTransition(.numericText())
                            .animation(.snappy, value: gameTimer.elapsedTime)
                            .rotation3DEffect(
                                .degrees(isResetting ? 360 : 0),
                                axis: (x: 1, y: 0, z: 0)
                            )
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.background)
                            .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                    }
                    .padding(.horizontal)
                    
                    // Progress Indicator
                    if !teams.isEmpty && gameTimer.isRunning {
                        let completedCount = teams.filter { team in
                            team.rounds.count >= currentRound && 
                            team.rounds[currentRound - 1].lastDiceTime != nil
                        }.count
                        
                        VStack(spacing: 4) {
                            HStack {
                                Text("Teams Completed")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("\(completedCount)/\(teams.count)")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.blue)
                            }
                            
                            ProgressView(value: Double(completedCount), total: Double(teams.count))
                                .tint(.blue)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Team List
                    List {
                        ForEach(teams.indices, id: \.self) { index in
                            TeamRowView(
                                team: teams[index],
                                currentRound: currentRound,
                                gameTimer: gameTimer,
                                isResetting: isResetting,
                                onRecordFirst: {
                                    withAnimation {
                                        teams[index].recordFirstDice(at: gameTimer.elapsedTime, forRound: currentRound)
                                    }
                                },
                                onRecordLast: {
                                    withAnimation {
                                        teams[index].recordLastDice(at: gameTimer.elapsedTime, forRound: currentRound)
                                        if allTeamsFinished {
                                            gameTimer.stop()
                                        }
                                    }
                                }
                            )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .listStyle(.plain)
                    
                    // Control Panel
                    VStack(spacing: 16) {
                        // Timer Controls
                        HStack(spacing: 20) {
                            // Start/Stop Button
                            Button(action: {
                                withAnimation {
                                    if gameTimer.isRunning {
                                        gameTimer.stop()
                                    } else {
                                        gameTimer.start()
                                    }
                                }
                            }) {
                                Circle()
                                    .fill(gameTimer.isRunning ? .red : (canStartTimer ? .green : .gray))
                                    .frame(width: 64, height: 64)
                                    .overlay {
                                        Image(systemName: gameTimer.isRunning ? "pause.fill" : "play.fill")
                                            .font(.title)
                                            .foregroundColor(.white)
                                    }
                            }
                            .disabled(!canStartTimer && !gameTimer.isRunning)
                            
                            // Reset Button
                            Button(action: {
                                showingResetConfirmation = true
                            }) {
                                Circle()
                                    .fill(.secondary.opacity(0.2))
                                    .frame(width: 64, height: 64)
                                    .overlay {
                                        Image(systemName: "arrow.counterclockwise")
                                            .font(.title2)
                                            .foregroundColor(.primary)
                                            .rotationEffect(.degrees(isResetting ? 360 : 0))
                                    }
                            }
                            
                            // Results Button (now shows when round is complete)
                            if !teams.isEmpty && (allTeamsFinished || !gameTimer.isRunning) {
                                Button(action: { showingResults = true }) {
                                    Circle()
                                        .fill(.blue.opacity(0.2))
                                        .frame(width: 64, height: 64)
                                        .overlay {
                                            Image(systemName: "chart.bar.fill")
                                                .font(.title2)
                                                .foregroundColor(.blue)
                                        }
                                }
                            }
                        }
                        
                        // Next Round Button (only show when round is complete)
                        if allTeamsFinished && !gameTimer.isRunning {
                            Button(action: {
                                withAnimation {
                                    currentRound += 1
                                    gameTimer.reset()
                                }
                            }) {
                                Text("Next Round")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background {
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(.blue)
                                    }
                            }
                        }
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.background)
                            .shadow(color: .black.opacity(0.05), radius: 8, y: -4)
                    }
                }
            }
            .navigationTitle("Dice Timer")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddTeam = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingAddTeam) {
                AddTeamView(teams: $teams)
            }
            .sheet(isPresented: $showingResults) {
                ResultsView(teams: teams, currentRound: currentRound)
            }
            .overlay {
                if showingCompletionBanner {
                    VStack {
                        Spacer()
                        
                        Text("Round Complete!")
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.blue)
                                    .shadow(radius: 8)
                            }
                            .padding()
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
        }
        .confirmationDialog(
            "Reset Timer",
            isPresented: $showingResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset Everything", role: .destructive) {
                resetEverything()
            }
            Button("Reset All Rounds", role: .destructive) {
                resetAll()
            }
            Button("Reset Current Round", role: .destructive) {
                withAnimation {
                    gameTimer.reset()
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Choose what to reset")
        }
    }
    
    func onRoundComplete() {
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Show completion banner
        withAnimation {
            showingCompletionBanner = true
            showingResults = true  // Automatically show results when round completes
        }
        
        // Hide banner after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showingCompletionBanner = false
            }
        }
    }
}

struct TeamRowView: View {
    var team: Team
    let currentRound: Int
    let gameTimer: GameTimer
    let isResetting: Bool
    let onRecordFirst: () -> Void
    let onRecordLast: () -> Void
    
    var roundTiming: Team.RoundTiming? {
        guard team.rounds.count >= currentRound else { return nil }
        return team.rounds[currentRound - 1]
    }
    
    var canRecordLast: Bool {
        roundTiming?.firstDiceTime != nil && roundTiming?.lastDiceTime == nil
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Team Info and Buttons Row
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(team.name)
                        .font(.headline)
                    Text("\(team.playerCount) players")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Timing Buttons
                if gameTimer.isRunning {
                    HStack(spacing: 12) {
                        TimingButton(
                            action: onRecordFirst,
                            icon: "1.circle.fill",
                            isRecorded: roundTiming?.firstDiceTime != nil,
                            color: .blue
                        )
                        
                        TimingButton(
                            action: onRecordLast,
                            icon: "checkmark.circle.fill",
                            isRecorded: roundTiming?.lastDiceTime != nil,
                            color: .green,
                            isEnabled: canRecordLast
                        )
                    }
                }
            }
            
            // Timing Info Row (Compact)
            if let timing = roundTiming {
                HStack(spacing: 16) {
                    if let first = timing.firstDiceTime {
                        Label(String(format: "%.2fs", first), systemImage: "1.circle")
                            .font(.footnote.monospacedDigit())
                            .foregroundStyle(.blue)
                    }
                    
                    if let last = timing.lastDiceTime {
                        Label(String(format: "%.2fs", last), systemImage: "checkmark.circle")
                            .font(.footnote.monospacedDigit())
                            .foregroundStyle(.green)
                            
                        Spacer()
                        
                        Label(String(format: "%.2fs", last), systemImage: "clock")
                            .font(.footnote.monospacedDigit())
                            .foregroundStyle(.purple)
                    }
                }
                .frame(maxHeight: 20) // Limit the height
            }
        }
        .padding(.vertical, 12) // Reduced vertical padding
        .padding(.horizontal)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 4)
        }
        .padding(.horizontal)
        .opacity(isResetting ? 0.5 : 1)
        .scaleEffect(isResetting ? 0.98 : 1)
        .animation(.spring(response: 0.3), value: isResetting)
    }
}

struct TimingButton: View {
    let action: () -> Void
    let icon: String
    let isRecorded: Bool
    let color: Color
    var isEnabled: Bool = true
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(
                    isRecorded ? .secondary :
                    isEnabled ? color : .secondary.opacity(0.5)
                )
        }
        .disabled(isRecorded || !isEnabled)
    }
}

#Preview {
    ContentView()
}
