//
//  Dice_GameTests.swift
//  Dice GameTests
//
//  Created by Andrew Tam on 13/11/2024.
//

import Testing
import Foundation
@testable import Dice_Game

struct Dice_GameTests {

    // MARK: - Team Tests

    @Test func testRecordFirstDice() {
        var team = Team(name: "Test Team", playerCount: 5)
        team.recordFirstDice(at: 10.5, forRound: 1)

        #expect(team.rounds.count == 1)
        #expect(team.rounds[0].firstDiceTime == 10.5)
        #expect(team.rounds[0].lastDiceTime == nil)
    }

    @Test func testRecordLastDice() {
        var team = Team(name: "Test Team", playerCount: 5)
        team.recordFirstDice(at: 10.5, forRound: 1)
        team.recordLastDice(at: 25.3, forRound: 1)

        #expect(team.rounds[0].lastDiceTime == 25.3)
    }

    @Test func testRecordLastDiceWithoutFirstDice() {
        var team = Team(name: "Test Team", playerCount: 5)
        team.recordLastDice(at: 25.3, forRound: 1)

        #expect(team.rounds.count == 1)
        #expect(team.rounds[0].lastDiceTime == nil) // Should not record without first dice
    }

    @Test func testDurationCalculation() {
        var team = Team(name: "Test Team", playerCount: 5)
        team.recordFirstDice(at: 10.0, forRound: 1)
        team.recordLastDice(at: 25.5, forRound: 1)

        #expect(team.rounds[0].duration == 15.5)
    }

    @Test func testDurationNilWhenIncomplete() {
        var team = Team(name: "Test Team", playerCount: 5)
        team.recordFirstDice(at: 10.0, forRound: 1)

        #expect(team.rounds[0].duration == nil)
    }

    @Test func testMultipleRounds() {
        var team = Team(name: "Test Team", playerCount: 5)

        team.recordFirstDice(at: 10.0, forRound: 1)
        team.recordLastDice(at: 25.0, forRound: 1)

        team.recordFirstDice(at: 5.0, forRound: 2)
        team.recordLastDice(at: 18.0, forRound: 2)

        #expect(team.rounds.count == 2)
        #expect(team.rounds[0].duration == 15.0)
        #expect(team.rounds[1].duration == 13.0)
    }

    @Test func testAverageDuration() {
        var team = Team(name: "Test Team", playerCount: 5)

        team.recordFirstDice(at: 0.0, forRound: 1)
        team.recordLastDice(at: 10.0, forRound: 1)

        team.recordFirstDice(at: 0.0, forRound: 2)
        team.recordLastDice(at: 20.0, forRound: 2)

        team.recordFirstDice(at: 0.0, forRound: 3)
        team.recordLastDice(at: 30.0, forRound: 3)

        #expect(team.averageDuration == 20.0) // (10 + 20 + 30) / 3
    }

    @Test func testAverageDurationNilWhenNoCompleteRounds() {
        var team = Team(name: "Test Team", playerCount: 5)
        team.recordFirstDice(at: 10.0, forRound: 1)

        #expect(team.averageDuration == nil)
    }

    @Test func testStandardDeviation() {
        var team = Team(name: "Test Team", playerCount: 5)

        team.recordFirstDice(at: 0.0, forRound: 1)
        team.recordLastDice(at: 10.0, forRound: 1)

        team.recordFirstDice(at: 0.0, forRound: 2)
        team.recordLastDice(at: 20.0, forRound: 2)

        team.recordFirstDice(at: 0.0, forRound: 3)
        team.recordLastDice(at: 30.0, forRound: 3)

        // Mean = 20, variance = ((10-20)^2 + (20-20)^2 + (30-20)^2) / 2 = 100
        // Std dev = sqrt(100) = 10
        #expect(team.standardDeviation == 10.0)
    }

    @Test func testStandardDeviationNilForSingleRound() {
        var team = Team(name: "Test Team", playerCount: 5)
        team.recordFirstDice(at: 0.0, forRound: 1)
        team.recordLastDice(at: 10.0, forRound: 1)

        #expect(team.standardDeviation == nil)
    }

    @Test func testFastestRound() {
        var team = Team(name: "Test Team", playerCount: 5)

        team.recordFirstDice(at: 0.0, forRound: 1)
        team.recordLastDice(at: 20.0, forRound: 1)

        team.recordFirstDice(at: 0.0, forRound: 2)
        team.recordLastDice(at: 10.0, forRound: 2)

        team.recordFirstDice(at: 0.0, forRound: 3)
        team.recordLastDice(at: 15.0, forRound: 3)

        let fastest = team.fastestRound
        #expect(fastest?.round == 2)
        #expect(fastest?.duration == 10.0)
    }

    @Test func testResetRounds() {
        var team = Team(name: "Test Team", playerCount: 5)
        team.recordFirstDice(at: 10.0, forRound: 1)
        team.recordLastDice(at: 25.0, forRound: 1)

        team.resetRounds()

        #expect(team.rounds.isEmpty)
    }

    // MARK: - GameTimer Tests

    @Test func testTimerInitialState() {
        let timer = GameTimer()

        #expect(timer.isRunning == false)
        #expect(timer.elapsedTime == 0)
    }

    @Test func testTimerStart() async throws {
        let timer = GameTimer()
        timer.start()

        #expect(timer.isRunning == true)

        // Wait a bit and check that time has elapsed
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        #expect(timer.elapsedTime > 0)
        #expect(timer.elapsedTime < 0.2) // Should be around 0.1s

        timer.stop()
    }

    @Test func testTimerStop() async throws {
        let timer = GameTimer()
        timer.start()

        try await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds

        timer.stop()
        let stoppedTime = timer.elapsedTime

        #expect(timer.isRunning == false)

        try await Task.sleep(nanoseconds: 50_000_000) // Wait more

        #expect(timer.elapsedTime == stoppedTime) // Time should not have changed
    }

    @Test func testTimerReset() async throws {
        let timer = GameTimer()
        timer.start()

        try await Task.sleep(nanoseconds: 50_000_000)

        timer.reset()

        #expect(timer.isRunning == false)
        #expect(timer.elapsedTime == 0)
    }

    @Test func testTimerPauseResume() async throws {
        let timer = GameTimer()
        timer.start()

        try await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds

        timer.pause()
        let pausedTime = timer.elapsedTime

        #expect(timer.isRunning == false)
        #expect(pausedTime > 0)

        try await Task.sleep(nanoseconds: 50_000_000) // Wait while paused

        #expect(timer.elapsedTime == pausedTime) // Should not change

        timer.resume()

        #expect(timer.isRunning == true)

        try await Task.sleep(nanoseconds: 50_000_000) // 0.05 more seconds

        #expect(timer.elapsedTime > pausedTime) // Should have continued

        timer.stop()
    }
}
