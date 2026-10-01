import SwiftUI
// Friendly fish — variant C, cyclops cyan alien with antennae

struct AlienFishIconC: View {
    var body: some View {
        ZStack {
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.20, green: 0.85, blue: 0.80),
                            Color(red: 0.05, green: 0.45, blue: 0.50)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 150, height: 78)

            TailFin()
                .fill(Color(red: 0.10, green: 0.60, blue: 0.60))
                .frame(width: 60, height: 60)
                .offset(x: -80)

            Fin()
                .fill(Color(red: 0.15, green: 0.65, blue: 0.65))
                .frame(width: 42, height: 32)
                .rotationEffect(.degrees(-6))
                .offset(x: 10, y: -50)

            // Single large central alien eye
            Circle()
                .fill(Color(red: 0.95, green: 1.0, blue: 0.85))
                .frame(width: 30, height: 30)
                .overlay(
                    Circle()
                        .fill(Color.black)
                        .frame(width: 16, height: 16)
                )
                .offset(x: 45, y: -5)

            // Antenna-like spines
            ForEach(0..<2) { index in
                Capsule()
                    .fill(Color(red: 0.15, green: 0.70, blue: 0.65))
                    .frame(width: 3, height: 26)
                    .rotationEffect(.degrees(index == 0 ? -25 : 25))
                    .offset(x: 10 + CGFloat(index * 8), y: -46)
            }

            Circle()
                .fill(Color(red: 0.70, green: 1.0, blue: 0.95))
                .frame(width: 5)
                .offset(x: -30, y: 10)

            Circle()
                .fill(Color(red: 0.70, green: 1.0, blue: 0.95))
                .frame(width: 4)
                .offset(x: -10, y: -18)
        }
        .frame(width: 210, height: 170)
    }
}

#Preview {
    AlienFishIconC()
}
