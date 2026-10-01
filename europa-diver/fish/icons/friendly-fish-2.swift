import SwiftUI
// Friendly fish — variant B, three-eyed violet alien

struct AlienFishIconB: View {
    var body: some View {
        ZStack {
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.55, green: 0.25, blue: 0.75),
                            Color(red: 0.30, green: 0.10, blue: 0.50)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 140, height: 80)

            TailFin()
                .fill(Color(red: 0.40, green: 0.15, blue: 0.60))
                .frame(width: 55, height: 65)
                .offset(x: -78)

            Fin()
                .fill(Color(red: 0.45, green: 0.18, blue: 0.65))
                .frame(width: 45, height: 35)
                .rotationEffect(.degrees(-8))
                .offset(x: 15, y: -52)

            Fin()
                .fill(Color(red: 0.35, green: 0.14, blue: 0.55))
                .frame(width: 38, height: 28)
                .rotationEffect(.degrees(12))
                .offset(x: 25, y: 48)

            // Three small alien eyes instead of two
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color(red: 0.85, green: 0.95, blue: 0.55))
                    .frame(width: 14, height: 14)
                    .overlay(
                        Circle()
                            .fill(Color.black)
                            .frame(width: 6, height: 9)
                    )
                    .offset(x: 30 + CGFloat(index * 10), y: -6 + CGFloat(index * -6))
            }

            // Glowing bioluminescent markings
            ForEach(0..<4) { index in
                Circle()
                    .fill(Color(red: 0.75, green: 1.0, blue: 0.55))
                    .frame(width: 5)
                    .offset(x: -25 + CGFloat(index * 12), y: -10 + CGFloat(index % 2) * 18)
            }
        }
        .frame(width: 210, height: 170)
    }
}

#Preview {
    AlienFishIconB()
}
