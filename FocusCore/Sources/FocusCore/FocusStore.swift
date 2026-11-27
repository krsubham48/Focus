import Foundation

/// Saves everything as one JSON file on the device.
public struct FocusStore: Sendable {
    public let url: URL

    public init(url: URL) { self.url = url }

    public static var standard: FocusStore {
        FocusStore(url: URL.applicationSupportDirectory.appending(path: "focus.json"))
    }

    /// Throws when a file is there but cannot be read, as after a restart before the first unlock.
    /// The caller must then not save, or it would replace what it could not see.
    public func read() throws -> FocusData {
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch CocoaError.fileReadNoSuchFile {
            return FocusData()
        }
        if let decoded = try? JSONDecoder().decode(FocusData.self, from: data) { return decoded }
        // Keep what could not be read, so the next save does not destroy it.
        let copy = url.appendingPathExtension("unreadable")
        try? FileManager.default.removeItem(at: copy)
        try? FileManager.default.copyItem(at: url, to: copy)
        return FocusData()
    }

    public func load() -> FocusData {
        (try? read()) ?? FocusData()
    }

    public func save(_ data: FocusData) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try JSONEncoder().encode(data).write(to: url, options: .atomic)
    }
}
