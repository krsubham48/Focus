// FocusStoreTests.swift
import Foundation
import Testing
@testable import FocusCore

@Suite struct FocusStoreTests {
    let url = URL.temporaryDirectory.appending(path: "\(UUID().uuidString)/focus.json")

    @Test func missingFileGivesEmptyData() {
        #expect(FocusStore(url: url).load() == FocusData())
    }

    @Test func savedDataLoadsBack() throws {
        var data = FocusData()
        _ = try data.start(minutes: 10, now: .now)
        data.onboarded = true
        try FocusStore(url: url).save(data)
        #expect(FocusStore(url: url).load() == data)
    }

    @Test func decodesOlderDataWithDefaults() throws {
        try write(#"{"history":[]}"#)
        let data = FocusStore(url: url).load()
        #expect(data.lastMinutes == 20 && !data.onboarded && data.active == nil)
        #expect(!FileManager.default.fileExists(atPath: url.appendingPathExtension("unreadable").path))
    }

    @Test func unreadableFileIsKeptAside() throws {
        try write("not json")
        #expect(FocusStore(url: url).load() == FocusData())
        #expect(FileManager.default.fileExists(atPath: url.appendingPathExtension("unreadable").path))
    }

    private func write(_ text: String) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data(text.utf8).write(to: url)
    }
}
