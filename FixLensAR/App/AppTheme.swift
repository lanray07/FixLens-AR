import SwiftUI

enum FixLensTheme {
    static let background = Color(red: 0.015, green: 0.018, blue: 0.024)
    static let panel = Color.white.opacity(0.08)
    static let panelStroke = Color.white.opacity(0.16)
    static let electricBlue = Color(red: 0.0, green: 0.48, blue: 1.0)
    static let emerald = Color(red: 0.0, green: 0.86, blue: 0.56)
    static let warning = Color(red: 1.0, green: 0.68, blue: 0.18)
    static let danger = Color(red: 1.0, green: 0.23, blue: 0.28)
    static let secondaryText = Color.white.opacity(0.68)

    static let heroGradient = LinearGradient(
        colors: [
            Color(red: 0.0, green: 0.2, blue: 0.42),
            Color(red: 0.0, green: 0.06, blue: 0.14),
            background
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct PremiumBackground: View {
    var body: some View {
        ZStack {
            FixLensTheme.background.ignoresSafeArea()
            FixLensTheme.heroGradient.opacity(0.65).ignoresSafeArea()
            GridOverlay()
                .stroke(Color.white.opacity(0.035), lineWidth: 0.7)
                .ignoresSafeArea()
            LinearGradient(
                colors: [.clear, FixLensTheme.emerald.opacity(0.12)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }
}

private struct GridOverlay: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let spacing: CGFloat = 34

        stride(from: rect.minX, through: rect.maxX, by: spacing).forEach { x in
            path.move(to: CGPoint(x: x, y: rect.minY))
            path.addLine(to: CGPoint(x: x, y: rect.maxY))
        }

        stride(from: rect.minY, through: rect.maxY, by: spacing).forEach { y in
            path.move(to: CGPoint(x: rect.minX, y: y))
            path.addLine(to: CGPoint(x: rect.maxX, y: y))
        }

        return path
    }
}

struct GlassPanelModifier: ViewModifier {
    var cornerRadius: CGFloat = 24

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(FixLensTheme.panelStroke, lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.25), radius: 22, x: 0, y: 16)
    }
}

extension View {
    func glassPanel(cornerRadius: CGFloat = 24) -> some View {
        modifier(GlassPanelModifier(cornerRadius: cornerRadius))
    }
}
