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

struct TapFrenzyView: View  {
    @State private var score = 0
    @State private var timeRemaining:Double = 10.0
    @State private var phase: GamePhase = .idle
    @State private var isNewBestScore = false
    @AppStorage("highScore") private var highScore = 0

    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

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
                
                    Text("\(score)")
                        .font(.system(size: 80, weight: .heavy))
                        .foregroundStyle(.white)
                    
                
                    Text("Time: \(String(format: "%.1f", timeRemaining))s")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.gray)
                    
                
                    ProgressView(value: timeRemaining, total: 10)
                        .tint(timeRemaining > 5 ? .green : timeRemaining > 2 ? .orange : .red)
                        .frame(width: 250)
                        .scaleEffect(y: 3)
                    
                    
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
            
            if timeRemaining > 0 {
                timeRemaining -= 0.1
            }
            
            if timeRemaining <= 0 {
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
        timeRemaining = 10.0
        isNewBestScore = false
        phase = .idle
    }
}

#Preview {
    ContentView()
}
