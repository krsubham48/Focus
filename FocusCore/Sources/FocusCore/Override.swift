/// One easy sum on the way out of a session.
public struct Sum: Equatable, Sendable {
    public enum Operation: Sendable {
        case add, subtract
    }

    public let left: Int
    public let right: Int
    public let operation: Operation

    public init(left: Int, right: Int, operation: Operation) {
        self.left = left
        self.right = right
        self.operation = operation
    }

    public var answer: Int { operation == .add ? left + right : left - right }

    public var text: String { "\(left) \(operation == .add ? "+" : "−") \(right)" }
}

public enum SumGenerator {
    /// Numbers from 1 to 20, never a negative answer, never the same sum twice running.
    public static func next(avoiding previous: Sum?, using generator: inout some RandomNumberGenerator) -> Sum {
        while true {
            let operation: Sum.Operation = Bool.random(using: &generator) ? .add : .subtract
            var left = Int.random(in: 1...20, using: &generator)
            var right = Int.random(in: 1...20, using: &generator)
            if operation == .subtract, right > left { swap(&left, &right) }
            let sum = Sum(left: left, right: right, operation: operation)
            if sum != previous { return sum }
        }
    }
}

/// PIN, five right sums, "are you sure", PIN again. Cancelling just discards it.
public struct OverrideFlow: Equatable, Sendable {
    public enum Step: Equatable, Sendable {
        case enterPIN
        case sum(Sum, solved: Int)
        case confirm
        case reenterPIN
        case approved
    }

    public static let sumsRequired = 5
    public private(set) var step: Step = .enterPIN

    public init() {}

    public mutating func pinEntered(correct: Bool, using generator: inout some RandomNumberGenerator) {
        guard correct else { return }
        if step == .enterPIN {
            step = .sum(SumGenerator.next(avoiding: nil, using: &generator), solved: 0)
        } else if step == .reenterPIN {
            step = .approved
        }
    }

    /// A wrong answer gives a new sum and keeps the count.
    @discardableResult
    public mutating func answer(_ value: Int, using generator: inout some RandomNumberGenerator) -> Bool {
        guard case let .sum(sum, solved) = step else { return false }
        let correct = value == sum.answer
        let count = correct ? solved + 1 : solved
        step =
            count == Self.sumsRequired
            ? .confirm : .sum(SumGenerator.next(avoiding: sum, using: &generator), solved: count)
        return correct
    }

    public mutating func confirm() {
        if step == .confirm { step = .reenterPIN }
    }
}
