import SwiftUI

// MARK: - UIColor helpers
private extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        let r, g, b, a: UInt64
        switch hexSanitized.count {
        case 6: (r, g, b, a) = ((rgb & 0xFF0000) >> 16, (rgb & 0x00FF00) >> 8, (rgb & 0x0000FF), 0xFF)
        case 8: (r, g, b, a) = ((rgb & 0xFF000000) >> 24, (rgb & 0x00FF0000) >> 16, (rgb & 0x0000FF00) >> 8, (rgb & 0x000000FF))
        default: return nil
        }
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a) / 255.0)
    }
}

// MARK: - Color helpers
extension Color {
    static func dynamic(light: UIColor, dark: UIColor) -> Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? dark : light
        })
    }
}

// MARK: - App Theme
struct AppColors {
    // Base
    static let background = Color.dynamic(
        light: UIColor(hex: "#ffffff")!,
        dark: UIColor(hex: "#121113")!
    )
    static let foreground = Color.dynamic(
        light: UIColor(hex: "#111827")!,
        dark: UIColor(hex: "#c1c1c1")!
    )

    // Surfaces
    static let card = Color.dynamic(
        light: UIColor(hex: "#ffffff")!,
        dark: UIColor(hex: "#121212")!
    )
    static let cardForeground = Color.dynamic(
        light: UIColor(hex: "#111827")!,
        dark: UIColor(hex: "#c1c1c1")!
    )
    static let popover = Color.dynamic(
        light: UIColor(hex: "#ffffff")!,
        dark: UIColor(hex: "#121113")!
    )
    static let popoverForeground = Color.dynamic(
        light: UIColor(hex: "#111827")!,
        dark: UIColor(hex: "#c1c1c1")!
    )

    // Brand
    static let primary = Color.dynamic(
        light: UIColor(hex: "#d87943")!,
        dark: UIColor(hex: "#e78a53")!
    )
    static let primaryForeground = Color.dynamic(
        light: UIColor(hex: "#ffffff")!,
        dark: UIColor(hex: "#121113")!
    )

    static let secondary = Color.dynamic(
        light: UIColor(hex: "#527575")!,
        dark: UIColor(hex: "#5f8787")!
    )
    static let secondaryForeground = Color.dynamic(
        light: UIColor(hex: "#ffffff")!,
        dark: UIColor(hex: "#121113")!
    )

    // States & utility
    static let muted = Color.dynamic(
        light: UIColor(hex: "#f3f4f6")!,
        dark: UIColor(hex: "#222222")!
    )
    static let mutedForeground = Color.dynamic(
        light: UIColor(hex: "#6b7280")!,
        dark: UIColor(hex: "#888888")!
    )
    static let accent = Color.dynamic(
        light: UIColor(hex: "#eeeeee")!,
        dark: UIColor(hex: "#333333")!
    )
    static let accentForeground = Color.dynamic(
        light: UIColor(hex: "#111827")!,
        dark: UIColor(hex: "#c1c1c1")!
    )

    static let destructive = Color.dynamic(
        light: UIColor(hex: "#ef4444")!,
        dark: UIColor(hex: "#5f8787")!
    )
    static let destructiveForeground = Color.dynamic(
        light: UIColor(hex: "#fafafa")!,
        dark: UIColor(hex: "#121113")!
    )

    static let border = Color.dynamic(
        light: UIColor(hex: "#e5e7eb")!,
        dark: UIColor(hex: "#222222")!
    )
    static let input = Color.dynamic(
        light: UIColor(hex: "#e5e7eb")!,
        dark: UIColor(hex: "#222222")!
    )
    static let ring = Color.dynamic(
        light: UIColor(hex: "#d87943")!,
        dark: UIColor(hex: "#e78a53")!
    )

    // Charts
    static let chart1 = Color.dynamic(
        light: UIColor(hex: "#5f8787")!,
        dark: UIColor(hex: "#5f8787")!
    )
    static let chart2 = Color.dynamic(
        light: UIColor(hex: "#e78a53")!,
        dark: UIColor(hex: "#e78a53")!
    )
    static let chart3 = Color.dynamic(
        light: UIColor(hex: "#fbcb97")!,
        dark: UIColor(hex: "#fbcb97")!
    )
    static let chart4 = Color.dynamic(
        light: UIColor(hex: "#888888")!,
        dark: UIColor(hex: "#888888")!
    )
    static let chart5 = Color.dynamic(
        light: UIColor(hex: "#999999")!,
        dark: UIColor(hex: "#999999")!
    )

    // Sidebar (not used yet but available)
    static let sidebar = Color.dynamic(
        light: UIColor(hex: "#f3f4f6")!,
        dark: UIColor(hex: "#121212")!
    )
    static let sidebarForeground = Color.dynamic(
        light: UIColor(hex: "#111827")!,
        dark: UIColor(hex: "#c1c1c1")!
    )
    static let sidebarPrimary = Color.dynamic(
        light: UIColor(hex: "#d87943")!,
        dark: UIColor(hex: "#e78a53")!
    )
    static let sidebarPrimaryForeground = Color.dynamic(
        light: UIColor(hex: "#ffffff")!,
        dark: UIColor(hex: "#121113")!
    )
    static let sidebarAccent = Color.dynamic(
        light: UIColor(hex: "#ffffff")!,
        dark: UIColor(hex: "#333333")!
    )
    static let sidebarAccentForeground = Color.dynamic(
        light: UIColor(hex: "#111827")!,
        dark: UIColor(hex: "#c1c1c1")!
    )
    static let sidebarBorder = Color.dynamic(
        light: UIColor(hex: "#e5e7eb")!,
        dark: UIColor(hex: "#222222")!
    )
    static let sidebarRing = Color.dynamic(
        light: UIColor(hex: "#d87943")!,
        dark: UIColor(hex: "#e78a53")!
    )
}
