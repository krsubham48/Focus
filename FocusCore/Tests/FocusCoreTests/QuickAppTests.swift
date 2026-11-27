// QuickAppTests.swift
import Testing
@testable import FocusCore

@Suite struct QuickAppTests {
    @Test func sixAppsInGridOrder() {
        #expect(QuickApp.allCases == [.phone, .messages, .whatsApp, .safari, .camera, .spotify])
    }

    @Test func linksMatchTheDesign() {
        #expect(QuickApp.allCases.map { $0.urls.map(\.absoluteString) } == [
            ["mobilephone://"], ["sms:"], ["whatsapp://"],
            ["x-web-search://?", "https://www.google.com/"], ["camera://"], ["spotify://"],
        ])
    }
}
