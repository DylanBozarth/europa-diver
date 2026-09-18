import SwiftUI

struct YellowSubmarineIcon: View {
    var body: some View {
        ZStack {
            // Submarine body
            Capsule()
                .fill(Color.yellow)
                .frame(width: 150, height: 75)

            // Bottom keel
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.orange)
                .frame(width: 75, height: 10)
                .offset(y: 37)

            // Portholes
            HStack(spacing: 16) {
                ForEach(0..<3) { _ in
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 18, height: 18)
                        .overlay(
                            Circle()
                                .stroke(Color.black.opacity(0.5), lineWidth: 3)
                        )
                }
            }
            .offset(x: -10, y: -5)

            // Conning tower
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.yellow)
                    .frame(width: 35, height: 20)

                Rectangle()
                    .fill(Color.yellow)
                    .frame(width: 22, height: 12)
            }
            .offset(x: 20, y: -48)

            // Periscope
            Path { path in
                path.move(to: CGPoint(x: 115, y: 43))
                path.addLine(to: CGPoint(x: 115, y: 20))
                path.addLine(to: CGPoint(x: 130, y: 20))
            }
            .stroke(Color.black, style: StrokeStyle(lineWidth: 5, lineCap: .round))

            // Propeller
            ZStack {
                Capsule()
                    .fill(Color.gray)
                    .frame(width: 8, height: 38)

                Capsule()
                    .fill(Color.gray)
                    .frame(width: 38, height: 8)
            }
            .offset(x: -82)

            // Tail
            Triangle()
                .fill(Color.yellow)
                .frame(width: 30, height: 40)
                .offset(x: -75, y: -35)
        }
        .frame(width: 200, height: 160)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()

        return path
    }
}

#Preview {
    YellowSubmarineIcon()
}