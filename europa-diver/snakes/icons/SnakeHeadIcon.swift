import SwiftUI
// Just the hostile snake's head — the body is now built from separate
// trailing segments in Snake.swift, not baked into one long image.

struct SnakeHeadIcon: View {
    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color(red: 0.28, green: 0.09, blue: 0.38))
                .frame(width: 90, height: 78)

            Circle()
                .fill(Color(red: 1.0, green: 0.85, blue: 0.25))
                .frame(width: 18)
                .overlay(
                    Circle().fill(Color.black).frame(width: 8, height: 13)
                )
                .offset(x: 18, y: -16)

            Circle()
                .fill(Color(red: 1.0, green: 0.85, blue: 0.25))
                .frame(width: 18)
                .overlay(
                    Circle().fill(Color.black).frame(width: 8, height: 13)
                )
                .offset(x: 18, y: 16)

            Tooth()
                .fill(Color.white.opacity(0.9))
                .frame(width: 9, height: 18)
                .offset(x: 30, y: 30)

            Tooth()
                .fill(Color.white.opacity(0.9))
                .rotationEffect(.degrees(180))
                .frame(width: 9, height: 18)
                .offset(x: 30, y: -30)
        }
        .frame(width: 110, height: 90)
    }
}

#Preview {
    SnakeHeadIcon()
}
