//
//  Copyright (c) 2026 Andrew Sokolov
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Testing
@testable import SklvObserver

@Suite("Observed Value Tests") @MainActor
struct ObservedValueTests {
    let value1 = "A"
    let value2 = "B"
    let value3 = "C"

    @Test("Action Trigger")
    func testActionTrigger() {
        var receivedValue: String?

        let observedValue = ObservedValue(value1)

        let valueObserver = ValueObserver(observedValue)
        valueObserver.action = { newValue in
            receivedValue = newValue
        }

        observedValue.value = value2
        #expect(receivedValue == value2)
    }

    @Test("No Action On Same Value")
    func testNoActionOnSameValue() {
        var count = 0

        let observedValue = ObservedValue(value1)

        let valueObserver = ValueObserver(observedValue)
        valueObserver.action = { _ in
            count += 1
        }

        observedValue.value = value1
        #expect(count == 0)
    }

    @Test("Observer Deinit")
    func testObserverDeinit() {
        var count = 0

        let observedValue = ObservedValue(value1)

        do {
            let valueObserver = ValueObserver(observedValue)
            valueObserver.action = { _ in
                count += 1
            }

            observedValue.value = value2
        }

        observedValue.value = value3
        #expect(count == 1)
    }

    @Test("Action Change")
    func testActionChange() {
        var receivedValue: String?
        var count = 0

        let observedValue = ObservedValue(value1)

        let valueObserver = ValueObserver(observedValue)
        valueObserver.action = { newValue in
            receivedValue = newValue
        }

        observedValue.value = value2
        #expect(receivedValue == value2)

        valueObserver.action = { _ in
            count += 1
        }

        observedValue.value = value3
        #expect(receivedValue == value2)
        #expect(count == 1)
    }
}
