import Foundation

/// Saves everything as one JSON file on the device.
public struct FocusStore: Sendable {
    public let url: URL

    public init(url: URL) { self.url = url }

    public static var standard: FocusStore {
        FocusStore(url: URL.applicationSupportDirectory.appending(path: "focus.json"))
    }

    public func load() -> FocusData {
        guard let data = try? Data(contentsOf: url) else { return FocusData() }
        if let decoded = try? JSONDecoder().decode(FocusData.self, from: data) { return decoded }
        // Keep what could not be read, so the next save does not destroy it.
        let copy = url.appendingPathExtension("unreadable")
        try? FileManager.default.removeItem(at: copy)
        try? FileManager.default.copyItem(at: url, to: copy)
        return FocusData()
    }

    public func save(_ data: FocusData) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try JSONEncoder().encode(data).write(to: url, options: .atomic)
    }
}
