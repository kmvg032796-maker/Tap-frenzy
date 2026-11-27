//
//  ContentView.swift
//  TapFrenzy
//
//  Created by COBSCCOMP-077  on 2026-11-21.
//

import SwiftUI
import Combine

enum GamePhase {
    case idle, playing, over
}

struct ContentView: View {
    @State private var score = 0
    @State private var timeRemaining = 10
    @State private var phase: GamePhase = .idle
    @State private var isNewBestScore = false
    @AppStorage("highScore") private var highScore = 0

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Text("Tap Frenzy")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundStyle(.white)

                if phase == .idle || phase == .playing {
                    // 1. Score Label
                    Text("\(score)")
                        .font(.system(size: 80, weight: .heavy))
                        .foregroundStyle(.white)

                    // 2. Timer Label
                    Text("Time: \(timeRemaining)s")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.gray)

                    // 3. Big Circular Tap Button
                    Button(action: handleTap) {
                        Text(phase == .idle ? "START" : "TAP")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(width: 200, height: 200)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(radius: 10)
                    }
                } else {
                    // Game-Over View
                    VStack(spacing: 20) {
                        Text("Time's Up!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)

                        if isNewBestScore {
                            Text("New Best Score!")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(.yellow)
                        }

                        Text("\(score)")
                            .font(.system(size: 80, weight: .heavy))
                            .foregroundStyle(.white)

                        Text("Best: \(highScore)")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.orange)
                        
                        Text("Best: \(score)")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.orange)

                        Button("Play Again", action: resetGame)
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .background(Color.green)
                            .clipShape(Capsule())
                            .padding(.top, 20)
                    }
                }
            }
            .padding()
        }
        .onReceive(timer) { _ in
            guard phase == .playing else { return }

            if timeRemaining > 1 {
                timeRemaining -= 1
            } else {
                timeRemaining = 0
                endGame()
            }
        }
    }

    private func handleTap() {
        if phase == .idle {
            phase = .playing
        }
        score += 1
    }

    private func endGame() {
        phase = .over
        if score > highScore {
            highScore = score
            isNewBestScore = true
        } else {
            isNewBestScore = false
        }
    }

    private func resetGame() {
        score = 0
        timeRemaining = 10
        isNewBestScore = false
        phase = .idle
    }
}

#Preview {
    ContentView()
}
