import SwiftUI
// NON HOSTILE FISH

struct FloaterFishIcon: View {
    var body: some View {
        ZStack {
            // Large floating body
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.55, green: 0.60, blue: 0.58),
                            Color(red: 0.34, green: 0.40, blue: 0.41)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 155, height: 105)

            // Large tail
            FloaterTail()
                .fill(Color(red: 0.40, green: 0.46, blue: 0.46))
                .frame(width: 65, height: 90)
                .offset(x: -88)

            // Top floating fin
            FloaterFin()
                .fill(Color(red: 0.44, green: 0.51, blue: 0.50))
                .frame(width: 55, height: 45)
                .rotationEffect(.degrees(-8))
                .offset(x: 5, y: -66)

            // Bottom fin
            FloaterFin()
                .fill(Color(red: 0.38, green: 0.45, blue: 0.45))
                .frame(width: 50, height: 38)
                .rotationEffect(.degrees(10))
                .offset(x: 20, y: 63)

            // Small, unfocused eyes
            Circle()
                .fill(Color(red: 0.68, green: 0.74, blue: 0.70))
                .frame(width: 22)
                .overlay(
                    Circle()
                        .fill(Color(red: 0.20, green: 0.25, blue: 0.25))
                        .frame(width: 8)
                )
                .offset(x: 48, y: -18)

            Circle()
                .fill(Color(red: 0.68, green: 0.74, blue: 0.70))
                .frame(width: 16)
                .overlay(
                    Circle()
                        .fill(Color(red: 0.20, green: 0.25, blue: 0.25))
                        .frame(width: 6)
                )
                .offset(x: 31, y: -30)

            // Large mouth / intake
            Ellipse()
                .fill(Color(red: 0.20, green: 0.25, blue: 0.25))
                .frame(width: 28, height: 13)
                .offset(x: 52, y: 17)

            // Gill folds
            ForEach(0..<4) { index in
                Capsule()
                    .fill(Color.black.opacity(0.15))
                    .frame(width: 4, height: 25)
                    .rotationEffect(.degrees(-15))
                    .offset(
                        x: -25 + CGFloat(index * 9),
                        y: 8
                    )
            }

            // Large soft body markings
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 25)
                .offset(x: -35, y: -20)

            Circle()
                .fill(Color.white.opacity(0.06))
                .frame(width: 15)
                .offset(x: -10, y: 27)

            // Tiny bioluminescent spots
            Circle()
                .fill(Color(red: 0.55, green: 0.70, blue: 0.66))
                .frame(width: 5)
                .offset(x: -40, y: 5)

            Circle()
                .fill(Color(red: 0.55, green: 0.70, blue: 0.66))
                .frame(width: 4)
                .offset(x: -20, y: -12)
        }
        .frame(width: 230, height: 190)
    }
}

struct FloaterFin: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))

        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY),
            control: CGPoint(
                x: rect.midX,
                y: rect.minY
            )
        )

        path.closeSubpath()

        return path
    }
}

struct FloaterTail: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.maxX, y: rect.midY))

        path.addCurve(
            to: CGPoint(x: rect.minX, y: rect.minY),
            control1: CGPoint(
                x: rect.minX + 25,
                y: rect.midY - 8
            ),
            control2: CGPoint(
                x: rect.minX + 10,
                y: rect.minY + 10
            )
        )

        path.addCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY),
            control1: CGPoint(
                x: rect.minX + 10,
                y: rect.maxY - 10
            ),
            control2: CGPoint(
                x: rect.minX + 25,
                y: rect.midY + 8
            )
        )

        path.closeSubpath()

        return path
    }
}

#Preview {
    FloaterFishIcon()
}