import SwiftUI
// Hostile fish — variant C, abyssal red-black predator with a lure

struct HostileFishIconC: View {
    var body: some View {
        ZStack {
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.65, green: 0.08, blue: 0.12),
                            Color(red: 0.12, green: 0.02, blue: 0.04)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 150, height: 75)

            HostileTail()
                .fill(Color(red: 0.25, green: 0.04, blue: 0.06))
                .frame(width: 58, height: 75)
                .offset(x: -87)

            HostileFin()
                .fill(Color(red: 0.30, green: 0.05, blue: 0.08))
                .frame(width: 52, height: 48)
                .rotationEffect(.degrees(-12))
                .offset(x: 5, y: -54)

            Circle()
                .fill(Color(red: 1.0, green: 0.35, blue: 0.20))
                .frame(width: 25)
                .overlay(
                    Circle()
                        .fill(Color.black)
                        .frame(width: 11, height: 17)
                )
                .offset(x: 45, y: -10)

            Ellipse()
                .fill(Color.black)
                .frame(width: 40, height: 28)
                .offset(x: 54, y: 17)

            ForEach(0..<5) { index in
                Tooth()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: 6, height: 14)
                    .offset(x: 38 + CGFloat(index * 8), y: 8)
            }

            // Glowing lure-like spots down the spine
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color(red: 1.0, green: 0.45, blue: 0.15))
                    .frame(width: 6)
                    .offset(x: -30 + CGFloat(index * 15), y: -22)
            }
        }
        .frame(width: 225, height: 170)
    }
}

#Preview {
    HostileFishIconC()
}
