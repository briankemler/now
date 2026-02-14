import SwiftUI

struct AnimatedCheckmark: View {
    @State private var trimEnd: CGFloat = 0

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.nowSuccess.opacity(0.15))
                .frame(width: 120, height: 120)

            Circle()
                .stroke(Color.nowSuccess, lineWidth: 4)
                .frame(width: 120, height: 120)

            CheckmarkShape()
                .trim(from: 0, to: trimEnd)
                .stroke(
                    Color.nowSuccess,
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .frame(width: 50, height: 50)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                trimEnd = 1.0
            }
        }
    }
}

struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: w * 0.1, y: h * 0.5))
        path.addLine(to: CGPoint(x: w * 0.4, y: h * 0.8))
        path.addLine(to: CGPoint(x: w * 0.9, y: h * 0.2))
        return path
    }
}
