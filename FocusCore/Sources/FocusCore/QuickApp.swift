import Foundation

/// The six apps offered on the countdown screen, in grid order.
public enum QuickApp: String, CaseIterable, Identifiable, Sendable {
    case phone, messages, whatsApp, safari, camera, spotify

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .phone: "Phone"
        case .messages: "Messages"
        case .whatsApp: "WhatsApp"
        case .safari: "Safari"
        case .camera: "Camera"
        case .spotify: "Spotify"
        }
    }

    public var symbol: String {
        switch self {
        case .phone: "phone.fill"
        case .messages: "message.fill"
        case .whatsApp: "phone.bubble.fill"
        case .safari: "safari.fill"
        case .camera: "camera.fill"
        case .spotify: "music.note"
        }
    }

    /// Links to try in order. Phone and Camera links are unofficial.
    public var urls: [URL] {
        let links: [String] =
            switch self {
            case .phone: ["mobilephone://"]
            case .messages: ["sms:"]
            case .whatsApp: ["whatsapp://"]
            case .safari: ["x-web-search://?", "https://www.google.com/"]
            case .camera: ["camera://"]
            case .spotify: ["spotify://"]
            }
        return links.compactMap { URL(string: $0) }
    }

    public var failureMessage: String {
        switch self {
        case .whatsApp, .spotify: "\(title) isn't installed."
        default: "\(title) couldn't be opened."
        }
    }
}
