//
//  FlowTheme.swift
//  Float4
//
//  Created by Anantika Mannby on 9/16/25.
//

import SwiftUI

enum FlowTheme {
    static let accentPrimary   = Color(red: 0.2, green: 0.4, blue: 0.6)
    static let accentAlternate = Color.blue

    static let bg              = Color(.systemBackground)
    static let surface         = Color(.secondarySystemBackground)
    static let textPrimary     = Color(.label)
    static let textSecondary   = Color(.secondaryLabel)
    static let stroke          = Color(.separator)
    static let danger          = Color(.systemRed)
    struct Fonts {
        static func display(_ size: CGFloat) -> Font { .system(size: size, weight: .semibold, design: .rounded) }
        static var title: Font { .system(.title, design: .rounded).weight(.semibold) }
        static var headline: Font { .system(.headline, design: .rounded).weight(.semibold) }
        static var body: Font { .system(.body, design: .rounded) }
        static var caption: Font { .system(.caption, design: .rounded) }
    }
    
    enum Mood: String, CaseIterable, Hashable {
        case calm, focus, uplift, cozy, night, zen
        
        var displayName: String {
            switch self {
            case .calm: return "calm"
            case .focus: return "focus"
            case .uplift: return "uplift"
            case .cozy: return "cozy"
            case .night: return "night"
            case .zen: return "zen"
            }
        }
        
        var subtitle: String {
            switch self {
            case .calm: return "soft and clear"
            case .focus: return "cool and steady"
            case .uplift: return "bright and airy"
            case .cozy: return "warm and gentle"
            case .night: return "dim and quiet"
            case .zen: return "balanced and centered"
            }
        }
    }
    
    static func backgroundGradient(for mood: Mood, intensity: Double) -> LinearGradient {
        let t = max(0, min(1, intensity))
        switch mood {
        case .calm:
            return LinearGradient(colors: [Color.blue.opacity(0.10 + t * 0.25), Color.teal.opacity(0.10 + t * 0.25)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .focus:
            return LinearGradient(colors: [Color.indigo.opacity(0.10 + t * 0.25), Color.blue.opacity(0.10 + t * 0.25)], startPoint: .top, endPoint: .bottom)
        case .uplift:
            return LinearGradient(colors: [Color.orange.opacity(0.08 + t * 0.25), Color.yellow.opacity(0.08 + t * 0.25)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .cozy:
            return LinearGradient(colors: [Color.pink.opacity(0.10 + t * 0.25), Color.orange.opacity(0.10 + t * 0.25)], startPoint: .leading, endPoint: .trailing)
        case .night:
            return LinearGradient(colors: [Color.black.opacity(0.20 + t * 0.25), Color.purple.opacity(0.10 + t * 0.25)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .zen:
            return LinearGradient(colors: [Color.green.opacity(0.10 + t * 0.25), Color.mint.opacity(0.10 + t * 0.25)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

struct FlowProminentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(FlowTheme.Fonts.body.weight(.semibold))
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(FlowTheme.accentPrimary.opacity(configuration.isPressed ? 0.88 : 1))
            )
            .foregroundStyle(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.black.opacity(0.05))
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct FlowBorderedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(FlowTheme.Fonts.body)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(FlowTheme.bg)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(FlowTheme.accentPrimary.opacity(configuration.isPressed ? 0.55 : 0.35), lineWidth: 1)
            )
            .foregroundStyle(FlowTheme.accentPrimary)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct FlowField: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(FlowTheme.bg, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(FlowTheme.stroke, lineWidth: 1)
            )
            .foregroundStyle(FlowTheme.textPrimary)
    }
}

struct FlowCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(FlowTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(FlowTheme.stroke, lineWidth: 1)
            )
    }
}

extension View {
    func flowField() -> some View { modifier(FlowField()) }
    func flowCard() -> some View { modifier(FlowCard()) }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
