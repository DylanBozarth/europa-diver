import SwiftUI

struct HostileFishIcon: View {
    var body: some View {
        ZStack {
            // Main body
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.52, green: 0.28, blue: 0.24),
                            Color(red: 0.25, green: 0.16, blue: 0.18)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 150, height: 75)

            // Tail
            HostileTail()
                .fill(Color(red: 0.32, green: 0.19, blue: 0.20))
                .frame(width: 58, height: 75)
                .offset(x: -87)

            // Aggressive dorsal fin
            HostileFin()
                .fill(Color(red: 0.38, green: 0.21, blue: 0.22))
                .frame(width: 52, height: 48)
                .rotationEffect(.degrees(-12))
                .offset(x: 5, y: -54)

            // Lower fin
            HostileFin()
                .fill(Color(red: 0.30, green: 0.18, blue: 0.19))
                .frame(width: 45, height: 38)
                .rotationEffect(.degrees(15))
                .offset(x: 15, y: 49)

            // Forward-facing eye
            Circle()
                .fill(Color(red: 0.85, green: 0.72, blue: 0.45))
                .frame(width: 25)
                .overlay(
                    Circle()
                        .fill(Color.black)
                        .frame(width: 11, height: 17)
                )
                .overlay(
                    Circle()
                        .fill(Color.white.opacity(0.65))
                        .frame(width: 4)
                        .offset(x: -3, y: -4)
                )
                .offset(x: 45, y: -10)

            // Second eye
            Circle()
                .fill(Color(red: 0.78, green: 0.65, blue: 0.40))
                .frame(width: 16)
                .overlay(
                    Circle()
                        .fill(Color.black)
                        .frame(width: 7, height: 12)
                )
                .offset(x: 27, y: -22)

            // Large open mouth
            Ellipse()
                .fill(Color(red: 0.10, green: 0.07, blue: 0.08))
                .frame(width: 38, height: 27)
                .offset(x: 53, y: 17)

            // Upper teeth
            ForEach(0..<4) { index in
                Tooth()
                    .fill(Color(red: 0.82, green: 0.80, blue: 0.68))
                    .frame(width: 7, height: 13)
                    .offset(
                        x: 39 + CGFloat(index * 9),
                        y: 8
                    )
            }

            // Lower teeth
            ForEach(0..<3) { index in
                Tooth()
                    .fill(Color(red: 0.72, green: 0.70, blue: 0.60))
                    .rotationEffect(.degrees(180))
                    .frame(width: 7, height: 11)
                    .offset(
                        x: 44 + CGFloat(index * 9),
                        y: 27
                    )
            }

            // Gill slits
            ForEach(0..<3) { index in
                Capsule()
                    .fill(Color.black.opacity(0.28))
                    .frame(width: 4, height: 23)
                    .rotationEffect(.degrees(-18))
                    .offset(
                        x: -18 + CGFloat(index * 9),
                        y: 3
                    )
            }

            // Subtle body ridges
            ForEach(0..<3) { index in
                Capsule()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 3, height: 38)
                    .rotationEffect(.degrees(-70))
                    .offset(
                        x: -30 + CGFloat(index * 14),
                        y: -5
                    )
            }

            // Small bioluminescent warning markings
            Circle()
                .fill(Color(red: 0.75, green: 0.30, blue: 0.24))
                .frame(width: 5)
                .offset(x: -35, y: -18)

            Circle()
                .fill(Color(red: 0.75, green: 0.30, blue: 0.24))
                .frame(width: 4)
                .offset(x: -20, y: -27)

            Circle()
                .fill(Color(red: 0.75, green: 0.30, blue: 0.24))
                .frame(width: 4)
                .offset(x: -5, y: -20)
        }
        .frame(width: 225, height: 170)
    }
}

struct HostileFin: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))

        path.addLine(
            to: CGPoint(
                x: rect.midX + 5,
                y: rect.minY
            )
        )

        path.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY),
            control1: CGPoint(
                x: rect.midX + 15,
                y: rect.minY + 15
            ),
            control2: CGPoint(
                x: rect.maxX - 10,
                y: rect.maxY - 5
            )
        )

        path.closeSubpath()

        return path
    }
}

struct HostileTail: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.maxX, y: rect.midY))

        path.addLine(
            to: CGPoint(
                x: rect.minX,
                y: rect.minY
            )
        )

        path.addCurve(
            to: CGPoint(
                x: rect.minX + 10,
                y: rect.midY
            ),
            control1: CGPoint(
                x: rect.minX + 3,
                y: rect.minY + 25
            ),
            control2: CGPoint(
                x: rect.minX + 3,
                y: rect.midY - 5
            )
        )

        path.addLine(
            to: CGPoint(
                x: rect.minX,
                y: rect.maxY
            )
        )

        path.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY),
            control1: CGPoint(
                x: rect.minX + 3,
                y: rect.midY + 5
            ),
            control2: CGPoint(
                x: rect.minX + 3,
                y: rect.maxY - 25
            )
        )

        path.closeSubpath()

        return path
    }
}

struct Tooth: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()

        return path
    }
}

#Preview {
    HostileFishIcon()
}