
import SwiftUI
import Combine

// MARK: - Light It Up Game

struct LightItUpView: View {

    @AppStorage("highScore_lightItUp") private var highScore = 0

    @State private var score = 0
    @State private var lives = 3
    @State private var timeRemaining = 60
    @State private var level = 1

    @State private var cards: [LightCard] = []
    @State private var activeCard: Int? = nil

    @State private var isPlaying = false
    @State private var isGameOver = false

    @State private var lastSpawnTime = Date()
    @State private var lastTimerUpdate = Date()
    @State private var litUntil = Date()

    @State private var feedbackColor: Color = .clear
    @State private var showFeedback = false

    private let timer = Timer.publish(
        every: 0.1,
        on: .main,
        in: .common
    ).autoconnect()

    // MARK: - Difficulty Settings

    private var cardCount: Int {
        switch level {
        case 1: return 6
        case 2: return 9
        case 3: return 12
        default: return 16
        }
    }

    private var litDuration: TimeInterval {
        switch level {
        case 1: return 1.2
        case 2: return 0.9
        case 3: return 0.7
        default: return 0.5
        }
    }

    private var spawnInterval: TimeInterval {
        switch level {
        case 1: return 1.5
        case 2: return 1.2
        case 3: return 0.9
        default: return 0.7
        }
    }

    private var levelColor: Color {
        switch level {
        case 1: return .yellow
        case 2: return .green
        case 3: return .cyan
        default: return .pink
        }
    }

    private var gridColumns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: 12),
            count: 3
        )
    }

    // MARK: - Main View

    var body: some View {

        ZStack {

            Color(red: 0.055, green: 0.075, blue: 0.13)
                .ignoresSafeArea()

            VStack(spacing: 22) {

                // Header

                VStack(spacing: 6) {

                    Text("LIGHT IT UP")
                        .font(.system(size: 30, weight: .black))
                        .foregroundStyle(.white)

                    Text("Test your reaction speed!")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                }
                .padding(.top, 12)

                // Scoreboard

                HStack {

                    statBox(
                        title: "SCORE",
                        value: "\(score)",
                        icon: "star.fill",
                        color: .yellow
                    )

                    statBox(
                        title: "LEVEL",
                        value: "\(level)",
                        icon: "bolt.fill",
                        color: levelColor
                    )

                    statBox(
                        title: "TIME",
                        value: "\(timeRemaining)s",
                        icon: "timer",
                        color: .cyan
                    )
                }

                // Lives

                HStack(spacing: 10) {

                    ForEach(0..<3, id: \.self) { index in

                        Image(
                            systemName: index < lives
                            ? "heart.fill"
                            : "heart"
                        )
                        .font(.title2)
                        .foregroundStyle(
                            index < lives ? .red : .gray
                        )
                    }
                }

                // Instructions

                VStack(spacing: 6) {

                    Text(
                        isPlaying
                        ? "TAP THE GLOWING CARD!"
                        : "READY TO PLAY?"
                    )
                    .font(.headline.bold())
                    .foregroundStyle(.white)

                    Text(
                        isPlaying
                        ? "Find the bright card before it disappears"
                        : "Tap START to begin the challenge"
                    )
                    .font(.caption)
                    .foregroundStyle(.gray)
                }
                .padding(.vertical, 8)

                // Game Grid

                LazyVGrid(
                    columns: gridColumns,
                    spacing: 14
                ) {

                    ForEach(cards) { card in

                        Button {
                            handleTap(card.id)
                        } label: {

                            ZStack {

                                RoundedRectangle(
                                    cornerRadius: 18
                                )
                                .fill(
                                    activeCard == card.id
                                    ? levelColor
                                    : Color(red: 0.12, green: 0.17, blue: 0.27)
                                )

                                RoundedRectangle(
                                    cornerRadius: 18
                                )
                                .stroke(
                                    activeCard == card.id
                                    ? Color.white
                                    : Color.white.opacity(0.08),
                                    lineWidth: activeCard == card.id ? 2.5 : 1
                                )

                                VStack(spacing: 7) {

                                    Image(
                                        systemName: activeCard == card.id
                                        ? "bolt.fill"
                                        : "square.fill"
                                    )
                                    .font(.system(size: 27, weight: .bold))
                                    .foregroundStyle(
                                        activeCard == card.id
                                        ? Color.black
                                        : Color.gray.opacity(0.3)
                                    )

                                    Text(
                                        activeCard == card.id
                                        ? "TAP ME!"
                                        : "READY"
                                    )
                                    .font(.system(size: 10, weight: .heavy))
                                    .foregroundStyle(
                                        activeCard == card.id
                                        ? Color.black
                                        : Color.gray.opacity(0.35)
                                    )
                                }
                            }
                            .frame(height: 90)
                            .shadow(
                                color: activeCard == card.id
                                ? levelColor.opacity(0.8)
                                : .clear,
                                radius: activeCard == card.id ? 15 : 0
                            )
                            .scaleEffect(
                                activeCard == card.id ? 1.06 : 1.0
                            )
                            .animation(
                                .spring(response: 0.25, dampingFraction: 0.65),
                                value: activeCard
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(!isPlaying)
                    }
                }

                // Feedback

                if showFeedback {

                    Text(feedbackColor == .green ? "GREAT HIT! +10" : "WRONG CARD!")
                        .font(.headline.bold())
                        .foregroundStyle(feedbackColor)
                        .transition(.scale.combined(with: .opacity))
                } else {

                    Text("BEST SCORE: \(highScore)")
                        .font(.caption.bold())
                        .foregroundStyle(.gray)
                }

                Spacer(minLength: 0)

                // Start Button

                if !isPlaying && !isGameOver {

                    Button(action: startGame) {

                        Label(
                            "START GAME",
                            systemImage: "play.fill"
                        )
                        .font(.headline.bold())
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(.yellow.gradient)
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            // Game Over Overlay

            if isGameOver {

                Color.black.opacity(0.7)
                    .ignoresSafeArea()

                VStack(spacing: 18) {

                    Image(systemName: "trophy.fill")
                        .font(.system(size: 55))
                        .foregroundStyle(.yellow)

                    Text("GAME OVER!")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)

                    Text("Final Score")
                        .foregroundStyle(.gray)

                    Text("\(score)")
                        .font(.system(size: 55, weight: .black))
                        .foregroundStyle(.yellow)

                    Text("Best Score: \(highScore)")
                        .foregroundStyle(.white)

                    Text(
                        lives == 0
                        ? "You ran out of lives!"
                        : "Time is up!"
                    )
                    .foregroundStyle(.gray)

                    Button(action: resetGame) {

                        Label(
                            "PLAY AGAIN",
                            systemImage: "arrow.clockwise"
                        )
                        .font(.headline.bold())
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.yellow.gradient)
                        .clipShape(Capsule())
                    }
                    .padding(.top, 10)
                }
                .padding(30)
                .background(
                    Color(red: 0.12, green: 0.16, blue: 0.25),
                    in: RoundedRectangle(cornerRadius: 28)
                )
                .padding(25)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(timer) { _ in
            updateGame()
        }
        .onAppear {
            createCards()
        }
    }

    // MARK: - Stat Box

    private func statBox(
        title: String,
        value: String,
        icon: String,
        color: Color
    ) -> some View {

        VStack(spacing: 7) {

            Image(systemName: icon)
                .foregroundStyle(color)

            Text(title)
                .font(.caption2.bold())
                .foregroundStyle(.gray)

            Text(value)
                .font(.headline.bold().monospacedDigit())
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            Color.white.opacity(0.07),
            in: RoundedRectangle(cornerRadius: 15)
        )
    }

    // MARK: - Create Cards

    private func createCards() {

        cards = (0..<cardCount).map {
            LightCard(id: $0)
        }
    }

    // MARK: - Start Game

    private func startGame() {

        score = 0
        lives = 3
        timeRemaining = 60
        level = 1

        isGameOver = false
        isPlaying = true

        activeCard = nil
        showFeedback = false

        createCards()

        lastSpawnTime = Date()
        lastTimerUpdate = Date()
        litUntil = Date()

        spawnCard()
    }

    // MARK: - Game Update

    private func updateGame() {

        guard isPlaying else { return }

        let now = Date()

        // Countdown

        if now.timeIntervalSince(lastTimerUpdate) >= 1 {

            timeRemaining = max(0, timeRemaining - 1)
            lastTimerUpdate = now
        }

        // Level progression

        let elapsed = 60 - timeRemaining
        let progress = Double(elapsed) / 60.0

        let newLevel: Int

        switch progress {
        case ..<0.25:
            newLevel = 1
        case ..<0.50:
            newLevel = 2
        case ..<0.75:
            newLevel = 3
        default:
            newLevel = 4
        }

        if newLevel != level {

            level = newLevel
            createCards()
            activeCard = nil
            lastSpawnTime = now
        }

        // Check missed card

        if activeCard != nil && now >= litUntil {

            activeCard = nil
            loseLife()

            guard isPlaying else { return }
        }

        // Spawn next card

        if activeCard == nil &&
            now.timeIntervalSince(lastSpawnTime) >= spawnInterval {

            spawnCard()
        }

        // End game

        if timeRemaining <= 0 {
            endGame()
        }
    }

    // MARK: - Spawn Glowing Card

    private func spawnCard() {

        guard !cards.isEmpty, isPlaying else { return }

        let randomID = Int.random(
            in: 0..<cards.count
        )

        activeCard = randomID

        lastSpawnTime = Date()

        litUntil = Date().addingTimeInterval(
            litDuration
        )
    }

    // MARK: - Handle Card Tap

    private func handleTap(_ id: Int) {

        guard isPlaying else { return }

        if activeCard == id {

            score += 10

            activeCard = nil

            showResult(.green)

            if score > highScore {
                highScore = score
            }

        } else {

            showResult(.red)
            loseLife()
        }
    }

    // MARK: - Feedback

    private func showResult(_ color: Color) {

        feedbackColor = color

        withAnimation {
            showFeedback = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {

            withAnimation {
                showFeedback = false
            }
        }
    }

    // MARK: - Lose Life

    private func loseLife() {

        lives -= 1

        if lives <= 0 {

            lives = 0
            endGame()
        }
    }

    // MARK: - End Game

    private func endGame() {

        isPlaying = false
        isGameOver = true
        activeCard = nil

        if score > highScore {
            highScore = score
        }
    }

    // MARK: - Reset Game

    private func resetGame() {

        score = 0
        lives = 3
        timeRemaining = 60
        level = 1

        isPlaying = false
        isGameOver = false
        activeCard = nil
        showFeedback = false

        createCards()
    }
}

// MARK: - Card Model

private struct LightCard: Identifiable {

    let id: Int
}

// MARK: - Preview

#Preview {
    NavigationStack {
        LightItUpView()
    }
}
