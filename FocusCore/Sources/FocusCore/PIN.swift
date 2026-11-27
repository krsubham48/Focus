import CommonCrypto
import Foundation

public enum PINRules {
    public static let length = 10

    public static func isValid(_ pin: String) -> Bool {
        pin.count == length && pin.allSatisfy { $0.isASCII && $0.isNumber }
    }
}

/// What is stored instead of the PIN.
public struct PINHash: Codable, Equatable, Sendable {
    public let salt: Data
    public let hash: Data
    public let iterations: Int
}

public enum PINHasher {
    public static let defaultIterations = 100_000

    /// PBKDF2-HMAC-SHA256, 32 bytes.
    public static func derive(_ pin: String, salt: Data, iterations: Int) -> Data {
        var out = [UInt8](repeating: 0, count: 32)
        let status = salt.withUnsafeBytes { saltBytes in
            CCKeyDerivationPBKDF(
                CCPBKDFAlgorithm(kCCPBKDF2), pin, pin.utf8.count,
                saltBytes.bindMemory(to: UInt8.self).baseAddress, salt.count,
                CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256), UInt32(iterations), &out, out.count)
        }
        precondition(status == kCCSuccess, "PIN hashing failed")
        return Data(out)
    }

    public static func make(_ pin: String, iterations: Int = defaultIterations) -> PINHash {
        var generator = SystemRandomNumberGenerator()
        let salt = Data((0..<16).map { _ in UInt8.random(in: .min ... .max, using: &generator) })
        return PINHash(salt: salt, hash: derive(pin, salt: salt, iterations: iterations), iterations: iterations)
    }

    /// Compares without stopping at the first difference.
    public static func matches(_ pin: String, _ stored: PINHash) -> Bool {
        let candidate = derive(pin, salt: stored.salt, iterations: stored.iterations)
        guard candidate.count == stored.hash.count else { return false }
        return zip(candidate, stored.hash).reduce(UInt8(0)) { $0 | ($1.0 ^ $1.1) } == 0
    }
}

/// Where the hashed PIN is kept: the Keychain in the app, memory in tests.
public protocol SecretStore: Sendable {
    func read() -> Data?
    func write(_ data: Data) throws
    func delete()
}

public final class MemorySecretStore: SecretStore, @unchecked Sendable {
    private let lock = NSLock()
    private var value: Data?

    public init() {}

    public func read() -> Data? { lock.withLock { value } }
    public func write(_ data: Data) throws { lock.withLock { value = data } }
    public func delete() { lock.withLock { value = nil } }
}

public enum PINError: Error, Equatable {
    case invalid
}

public struct PINVault: Sendable {
    private let store: any SecretStore
    private let iterations: Int

    public init(store: any SecretStore, iterations: Int = PINHasher.defaultIterations) {
        self.store = store
        self.iterations = iterations
    }

    public var hasPIN: Bool { stored != nil }

    public func set(_ pin: String) throws {
        guard PINRules.isValid(pin) else { throw PINError.invalid }
        try store.write(try JSONEncoder().encode(PINHasher.make(pin, iterations: iterations)))
    }

    public func matches(_ pin: String) -> Bool {
        guard let stored else { return false }
        return PINHasher.matches(pin, stored)
    }

    public func clear() { store.delete() }

    private var stored: PINHash? {
        store.read().flatMap { try? JSONDecoder().decode(PINHash.self, from: $0) }
    }
}
