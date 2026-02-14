import SwiftUI

enum NowDesign {
    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Typography
    enum Typography {
        static let timerDisplay = Font.system(size: 72, weight: .ultraLight, design: .rounded)
        static let heading = Font.system(size: 28, weight: .semibold, design: .rounded)
        static let subheading = Font.system(size: 17, weight: .medium, design: .rounded)
        static let body = Font.system(size: 15, weight: .regular, design: .default)
        static let caption = Font.system(size: 13, weight: .regular, design: .default)
        static let statLarge = Font.system(size: 48, weight: .light, design: .rounded)
    }

    // MARK: - Corner Radius
    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let card: CGFloat = 20
    }

    // MARK: - Animations
    enum Anim {
        static let standard = Animation.easeInOut(duration: 0.3)
        static let slow = Animation.easeInOut(duration: 0.8)
        static let spring = Animation.spring(response: 0.5, dampingFraction: 0.7)
    }

    // MARK: - Timer Presets (seconds)
    static let timerPresets: [Int] = [300, 480, 600, 900, 1200, 1800]

    // MARK: - Timer Preset Labels
    static let timerPresetLabels: [Int: String] = [
        300: "5 min",
        480: "8 min",
        600: "10 min",
        900: "15 min",
        1200: "20 min",
        1800: "30 min"
    ]
}
