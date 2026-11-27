// PINTests.swift
import Foundation
import Testing
@testable import FocusCore

@Suite struct PINTests {
    @Test(arguments: ["", "123456789", "12345678901", "12345abcde", "１２３４５６７８９０"])
    func rejects(pin: String) { #expect(!PINRules.isValid(pin)) }

    @Test func acceptsTenDigits() { #expect(PINRules.isValid("0123456789")) }

    @Test func vaultMatchesOnlyTheSetPIN() throws {
        let vault = PINVault(store: MemorySecretStore(), iterations: 10)
        #expect(!vault.hasPIN && !vault.matches("1234567890"))
        try vault.set("1234567890")
        #expect(vault.hasPIN && vault.matches("1234567890") && !vault.matches("1234567891"))
    }

    @Test func storedValueDoesNotContainThePIN() throws {
        let store = MemorySecretStore()
        try PINVault(store: store, iterations: 10).set("1234567890")
        #expect(!String(decoding: store.read()!, as: UTF8.self).contains("1234567890"))
    }

    @Test func settingAnInvalidPINThrows() {
        #expect(throws: PINError.invalid) { try PINVault(store: MemorySecretStore()).set("123") }
    }
}
