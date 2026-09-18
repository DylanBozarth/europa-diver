import SwiftUI
// Friendly fish 
struct AlienFishIcon: View {
    var body: some View {
        ZStack {
            // Alien fish body
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.32, green: 0.65, blue: 0.62),
                            Color(red: 0.18, green: 0.42, blue: 0.48)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 145, height: 82)

            // Tail
            TailFin()
                .fill(Color(red: 0.24, green: 0.53, blue: 0.55))
                .frame(width: 55, height: 65)
                .offset(x: -78)

            // Dorsal fin
            Fin()
                .fill(Color(red: 0.27, green: 0.57, blue: 0.57))
                .frame(width: 45, height: 35)
                .rotationEffect(.degrees(-8))
                .offset(x: 15, y: -52)

            // Lower fin
            Fin()
                .fill(Color(red: 0.22, green: 0.49, blue: 0.51))
                .frame(width: 38, height: 28)
                .rotationEffect(.degrees(12))
                .offset(x: 25, y: 48)

            // Large alien eye
            Circle()
                .fill(Color(red: 0.82, green: 0.91, blue: 0.83))
                .frame(width: 28, height: 28)
                .overlay(
                    Circle()
                        .fill(Color(red: 0.12, green: 0.20, blue: 0.22))
                        .frame(width: 12, height: 18)
                )
                .offset(x: 43, y: -8)

            // Second, smaller eye
            Circle()
                .fill(Color(red: 0.75, green: 0.87, blue: 0.80))
                .frame(width: 17, height: 17)
                .overlay(
                    Circle()
                        .fill(Color(red: 0.12, green: 0.20, blue: 0.22))
                        .frame(width: 7, height: 11)
                )
                .offset(x: 25, y: -22)

            // Subtle gill markings
            ForEach(0..<3) { index in
                Capsule()
                    .fill(Color.black.opacity(0.18))
                    .frame(width: 3, height: 18)
                    .rotationEffect(.degrees(-12))
                    .offset(
                        x: -15 + CGFloat(index * 9),
                        y: 3
                    )
            }

            // Small bioluminescent markings
            Circle()
                .fill(Color(red: 0.55, green: 0.88, blue: 0.79))
                .frame(width: 5)
                .offset(x: -5, y: -22)

            Circle()
                .fill(Color(red: 0.55, green: 0.88, blue: 0.79))
                .frame(width: 4)
                .offset(x: -27, y: -15)

            Circle()
                .fill(Color(red: 0.55, green: 0.88, blue: 0.79))
                .frame(width: 4)
                .offset(x: -3, y: 22)
        }
        .frame(width: 210, height: 170)
    }
}

struct Fin: Shape {
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

struct TailFin: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.maxX, y: rect.midY))

        path.addCurve(
            to: CGPoint(x: rect.minX, y: rect.minY),
            control1: CGPoint(
                x: rect.minX + 20,
                y: rect.midY - 5
            ),
            control2: CGPoint(
                x: rect.minX + 10,
                y: rect.minY + 5
            )
        )

        path.addCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY),
            control1: CGPoint(
                x: rect.minX + 10,
                y: rect.maxY - 5
            ),
            control2: CGPoint(
                x: rect.minX + 20,
                y: rect.midY + 5
            )
        )

        path.closeSubpath()

        return path
    }
}

#Preview {
    AlienFishIcon()
}