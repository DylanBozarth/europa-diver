import SwiftUI
// Snake enemy — a long, segmented alien predator

struct SnakeIcon: View {
    var body: some View {
        ZStack {
            // Long body
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.22, green: 0.06, blue: 0.30),
                            Color(red: 0.06, green: 0.02, blue: 0.10)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 380, height: 70)

            // Segment bands along the body
            ForEach(0..<7) { index in
                Capsule()
                    .fill(Color(red: 0.45, green: 0.15, blue: 0.55).opacity(0.55))
                    .frame(width: 8, height: 60)
                    .offset(x: -160 + CGFloat(index * 54))
            }

            // Head
            Ellipse()
                .fill(Color(red: 0.28, green: 0.09, blue: 0.38))
                .frame(width: 100, height: 82)
                .offset(x: 175)

            // Eyes
            Circle()
                .fill(Color(red: 1.0, green: 0.85, blue: 0.25))
                .frame(width: 18)
                .overlay(
                    Circle().fill(Color.black).frame(width: 8, height: 13)
                )
                .offset(x: 200, y: -16)

            Circle()
                .fill(Color(red: 1.0, green: 0.85, blue: 0.25))
                .frame(width: 18)
                .overlay(
                    Circle().fill(Color.black).frame(width: 8, height: 13)
                )
                .offset(x: 200, y: 16)

            // Fangs
            Tooth()
                .fill(Color.white.opacity(0.9))
                .frame(width: 9, height: 18)
                .offset(x: 212, y: 30)

            Tooth()
                .fill(Color.white.opacity(0.9))
                .rotationEffect(.degrees(180))
                .frame(width: 9, height: 18)
                .offset(x: 212, y: -30)

            // Glowing warning spots down the spine
            ForEach(0..<5) { index in
                Circle()
                    .fill(Color(red: 0.95, green: 0.35, blue: 0.95))
                    .frame(width: 7)
                    .offset(x: -150 + CGFloat(index * 60), y: index % 2 == 0 ? -20 : 20)
            }
        }
        .frame(width: 440, height: 110)
    }
}

#Preview {
    SnakeIcon()
}
