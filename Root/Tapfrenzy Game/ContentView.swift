
import SwiftUI

struct ContentView: View {

    var body: some View {

        NavigationStack {

            ZStack {

                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 35) {

                    // MARK: - App Heading

                    VStack(spacing: 12) {

                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 65))
                            .foregroundStyle(.purple)

                        Text("Reflex Arcade")
                            .font(.largeTitle.bold())

                        Text("Choose Your Game")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 60)

                    // MARK: - Game Options

                    VStack(spacing: 20) {

                        // Game 1: Tap Frenzy

                        NavigationLink {
                            TapFrenzyView()
                        } label: {

                            GameCard(
                                title: "Tap Frenzy",
                                subtitle: "Test your tapping speed!",
                                icon: "hand.tap.fill",
                                color: .blue
                            )
                        }
                        .buttonStyle(.plain)

                        // Game 2: Light It Up

                        NavigationLink {
                            LightItUpView()
                        } label: {

                            GameCard(
                                title: "Light It Up",
                                subtitle: "Test your reaction time!",
                                icon: "square.grid.3x3.fill",
                                color: .orange
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 24)

                    Spacer()

                    Text("BSC Computing • iOS Game Collection")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 20)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "gearshape.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - Game Card Component

struct GameCard: View {

    let title: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {

        HStack(spacing: 18) {

            // Game Icon

            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundStyle(color)
                .frame(width: 65, height: 65)
                .background(
                    color.opacity(0.15),
                    in: RoundedRectangle(cornerRadius: 16)
                )

            // Game Information

            VStack(alignment: .leading, spacing: 7) {

                Text(title)
                    .font(.title3.bold())
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Navigation Arrow

            Image(systemName: "chevron.right")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 22)
        )
    }
}

#Preview {
    ContentView()
}
