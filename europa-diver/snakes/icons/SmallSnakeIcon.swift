import SwiftUI
// Small snake — a skittish, acid-green alien eel, unlike the hostile snake's
// dark purple coloring

struct SmallSnakeIcon: View {
    var body: some View {
        ZStack {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.55, green: 0.95, blue: 0.35),
                            Color(red: 0.20, green: 0.55, blue: 0.15)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 180, height: 40)

            ForEach(0..<4) { index in
                Capsule()
                    .fill(Color(red: 0.30, green: 0.70, blue: 0.20).opacity(0.6))
                    .frame(width: 5, height: 32)
                    .offset(x: -65 + CGFloat(index * 44))
            }

            // Head
            Circle()
                .fill(Color(red: 0.15, green: 0.35, blue: 0.10))
                .frame(width: 46, height: 46)
                .offset(x: 80)

            // Eyes
            Circle()
                .fill(Color.yellow)
                .frame(width: 9)
                .overlay(Circle().fill(Color.black).frame(width: 4, height: 6))
                .offset(x: 92, y: -9)

            Circle()
                .fill(Color.yellow)
                .frame(width: 9)
                .overlay(Circle().fill(Color.black).frame(width: 4, height: 6))
                .offset(x: 92, y: 9)
        }
        .frame(width: 220, height: 60)
    }
}

#Preview {
    SmallSnakeIcon()
}
