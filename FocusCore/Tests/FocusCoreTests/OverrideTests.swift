import Testing
@testable import FocusCore

struct SeededRNG: RandomNumberGenerator {
    var state: UInt64
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

@Suite struct OverrideTests {
    @Test func sumsStayEasyNeverNegativeAndNeverRepeat() {
        var rng = SeededRNG(state: 1)
        var previous: Sum?
        for _ in 0..<2000 {
            let sum = SumGenerator.next(avoiding: previous, using: &rng)
            #expect((1...20).contains(sum.left) && (1...20).contains(sum.right) && sum.answer >= 0)
            #expect(sum != previous)
            previous = sum
        }
    }

    @Test func sumTextAndAnswer() {
        let sum = Sum(left: 13, right: 4, operation: .subtract)
        #expect(sum.text == "13 − 4" && sum.answer == 9)
        #expect(Sum(left: 7, right: 5, operation: .add).text == "7 + 5")
    }

    @Test func wrongPINStaysOnThePINStep() {
        var rng = SeededRNG(state: 2)
        var flow = OverrideFlow()
        flow.pinEntered(correct: false, using: &rng)
        #expect(flow.step == .enterPIN)
    }

    @Test func wrongAnswerKeepsProgressAndChangesTheSum() {
        var rng = SeededRNG(state: 3)
        var flow = OverrideFlow()
        flow.pinEntered(correct: true, using: &rng)
        guard case let .sum(first, solved: 0) = flow.step else { Issue.record("no sum"); return }
        #expect(!flow.answer(first.answer + 1, using: &rng))
        guard case let .sum(second, solved: 0) = flow.step else { Issue.record("no sum"); return }
        #expect(second != first)
    }

    @Test func fiveRightAnswersThenConfirmThenPINApproves() {
        var rng = SeededRNG(state: 4)
        var flow = OverrideFlow()
        flow.pinEntered(correct: true, using: &rng)
        for _ in 0..<5 {
            guard case let .sum(sum, _) = flow.step else { Issue.record("no sum"); return }
            #expect(flow.answer(sum.answer, using: &rng))
        }
        #expect(flow.step == .confirm)
        flow.confirm()
        flow.pinEntered(correct: false, using: &rng)
        #expect(flow.step == .reenterPIN)
        flow.pinEntered(correct: true, using: &rng)
        #expect(flow.step == .approved)
    }
}
