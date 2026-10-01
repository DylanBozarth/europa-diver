import SwiftUI
// Hostile fish — variant B, venomous acid-green predator

struct HostileFishIconB: View {
    var body: some View {
        ZStack {
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.35, green: 0.55, blue: 0.15),
                            Color(red: 0.15, green: 0.28, blue: 0.10)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 150, height: 75)

            HostileTail()
                .fill(Color(red: 0.20, green: 0.35, blue: 0.12))
                .frame(width: 58, height: 75)
                .offset(x: -87)

            HostileFin()
                .fill(Color(red: 0.25, green: 0.40, blue: 0.14))
                .frame(width: 52, height: 48)
                .rotationEffect(.degrees(-12))
                .offset(x: 5, y: -54)

            HostileFin()
                .fill(Color(red: 0.18, green: 0.30, blue: 0.10))
                .frame(width: 45, height: 38)
                .rotationEffect(.degrees(15))
                .offset(x: 15, y: 49)

            Circle()
                .fill(Color(red: 0.85, green: 1.0, blue: 0.35))
                .frame(width: 25)
                .overlay(
                    Circle()
                        .fill(Color.black)
                        .frame(width: 11, height: 17)
                )
                .offset(x: 45, y: -10)

            Ellipse()
                .fill(Color(red: 0.08, green: 0.12, blue: 0.05))
                .frame(width: 38, height: 27)
                .offset(x: 53, y: 17)

            ForEach(0..<4) { index in
                Tooth()
                    .fill(Color(red: 0.75, green: 0.85, blue: 0.55))
                    .frame(width: 7, height: 13)
                    .offset(x: 39 + CGFloat(index * 9), y: 8)
            }

            // Venomous glowing warning spots
            ForEach(0..<4) { index in
                Circle()
                    .fill(Color(red: 0.70, green: 1.0, blue: 0.20))
                    .frame(width: 5)
                    .offset(x: -35 + CGFloat(index * 9), y: -20 + CGFloat(index % 2) * 14)
            }
        }
        .frame(width: 225, height: 170)
    }
}

#Preview {
    HostileFishIconB()
}
