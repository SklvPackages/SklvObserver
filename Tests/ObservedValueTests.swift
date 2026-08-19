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
import Foundation
import SklvObserver

/// A test suite verifying the behavior of the `ObservedValue` and `ValueObserver` components.
@Suite("Observed Value Tests")
@MainActor
struct ObservedValueTests {

    /// Tests that the observed value initializes correctly and holds the initial state.
    @Test("Initializes with correct value")
    func testInitialization() {
        let observed = ObservedValue(100)
        #expect(observed.value == 100)
    }

    /// Tests that changing the value triggers the registered observer action with the new value.
    @Test("Triggers action upon value change")
    func testActionTriggeredOnValueChange() {
        let observed = ObservedValue("Initial")
        var receivedValue: String?

        let observer = ValueObserver(observed) { newValue in
            receivedValue = newValue
        }

        observed.value = "Updated"

        #expect(receivedValue == "Updated")

        _ = observer
    }

    /// Tests that the action is NOT triggered if the new value is identical to the old value.
    @Test("Ignores identical value updates")
    func testIgnoresIdenticalValueUpdates() {
        let observed = ObservedValue(42)
        var triggerCount = 0

        let observer = ValueObserver(observed) { _ in
            triggerCount += 1
        }

        // Setting the exact same value should bypass the didSet logic
        observed.value = 42

        #expect(triggerCount == 0)
        
        _ = observer
    }

    /// Tests that replacing the action closure on the observer successfully updates the behavior.
    @Test("Updates observer action dynamically")
    func testUpdatesObserverAction() {
        let observed = ObservedValue(0)
        var pathTaken = ""

        let observer = ValueObserver(observed) { _ in
            pathTaken = "First"
        }

        // Dynamically swap the action closure
        observer.action = { _ in
            pathTaken = "Second"
        }

        observed.value = 1

        #expect(pathTaken == "Second")

        _ = observer
    }

    /// Tests that deallocating the observer properly unregisters the action from the observed value.
    @Test("Unregisters action upon observer deallocation")
    func testUnregistersOnDeallocation() {
        let observed = ObservedValue(false)
        var triggerCount = 0

        // Create an artificial scope so the observer is deallocated at the end of the block
        do {
            let observer = ValueObserver(observed) { _ in
                triggerCount += 1
            }

            observed.value = true // Should trigger (Count = 1)
            #expect(triggerCount == 1)

            _ = observer // Silences the unused variable warning
        } // `observer` is deallocated here due to ARC, triggering the isolated deinit

        observed.value = false // Should NOT trigger (Count remains 1)

        #expect(triggerCount == 1)
    }
}
