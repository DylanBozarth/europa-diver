import SwiftUI
// Non hostile fish — variant B, magenta bloated alien

struct FloaterFishIconB: View {
    var body: some View {
        ZStack {
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.65, green: 0.30, blue: 0.70),
                            Color(red: 0.35, green: 0.12, blue: 0.45)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 155, height: 105)

            FloaterTail()
                .fill(Color(red: 0.45, green: 0.18, blue: 0.55))
                .frame(width: 65, height: 90)
                .offset(x: -88)

            FloaterFin()
                .fill(Color(red: 0.50, green: 0.22, blue: 0.60))
                .frame(width: 55, height: 45)
                .rotationEffect(.degrees(-8))
                .offset(x: 5, y: -66)

            FloaterFin()
                .fill(Color(red: 0.40, green: 0.16, blue: 0.50))
                .frame(width: 50, height: 38)
                .rotationEffect(.degrees(10))
                .offset(x: 20, y: 63)

            Circle()
                .fill(Color(red: 0.90, green: 0.70, blue: 0.95))
                .frame(width: 22)
                .overlay(
                    Circle()
                        .fill(Color(red: 0.25, green: 0.08, blue: 0.30))
                        .frame(width: 8)
                )
                .offset(x: 48, y: -18)

            Circle()
                .fill(Color(red: 0.90, green: 0.70, blue: 0.95))
                .frame(width: 16)
                .overlay(
                    Circle()
                        .fill(Color(red: 0.25, green: 0.08, blue: 0.30))
                        .frame(width: 6)
                )
                .offset(x: 31, y: -30)

            Ellipse()
                .fill(Color(red: 0.25, green: 0.08, blue: 0.30))
                .frame(width: 28, height: 13)
                .offset(x: 52, y: 17)

            ForEach(0..<5) { index in
                Circle()
                    .fill(Color(red: 0.95, green: 0.60, blue: 1.0))
                    .frame(width: 4)
                    .offset(x: -45 + CGFloat(index * 14), y: -30 + CGFloat(index % 2) * 40)
            }
        }
        .frame(width: 230, height: 190)
    }
}

#Preview {
    FloaterFishIconB()
}
