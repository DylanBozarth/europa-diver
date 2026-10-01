import SwiftUI
// Non hostile fish — variant C, warty acid-green bloat

struct FloaterFishIconC: View {
    var body: some View {
        ZStack {
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.55, green: 0.70, blue: 0.25),
                            Color(red: 0.30, green: 0.42, blue: 0.12)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 160, height: 108)

            FloaterTail()
                .fill(Color(red: 0.35, green: 0.48, blue: 0.15))
                .frame(width: 65, height: 90)
                .offset(x: -88)

            FloaterFin()
                .fill(Color(red: 0.40, green: 0.52, blue: 0.18))
                .frame(width: 55, height: 45)
                .rotationEffect(.degrees(-8))
                .offset(x: 5, y: -66)

            Circle()
                .fill(Color(red: 0.85, green: 0.95, blue: 0.55))
                .frame(width: 24)
                .overlay(
                    Circle()
                        .fill(Color(red: 0.15, green: 0.22, blue: 0.05))
                        .frame(width: 9)
                )
                .offset(x: 50, y: -16)

            // Warty bumps across the body
            ForEach(0..<6) { index in
                Circle()
                    .fill(Color(red: 0.45, green: 0.58, blue: 0.20))
                    .frame(width: 10)
                    .offset(
                        x: -50 + CGFloat(index * 18),
                        y: index % 2 == 0 ? -25 : 20
                    )
            }

            Ellipse()
                .fill(Color(red: 0.15, green: 0.22, blue: 0.05))
                .frame(width: 26, height: 12)
                .offset(x: 54, y: 16)
        }
        .frame(width: 230, height: 190)
    }
}

#Preview {
    FloaterFishIconC()
}
