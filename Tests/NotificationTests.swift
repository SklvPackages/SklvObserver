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

/// A test suite verifying the behavior of the SklvObserver library components.
@Suite("Notification Tests")
struct ObserverTests {

    /// Tests that a single notification can be dispatched and successfully caught by the watcher.
    @Test("Posts and receives a single notification with a generic value")
    func testSingleNotificationWithValue() async throws {
        let notificationName = Notification.Name("TestSingleNotification")
        let testKey = "username"
        let testValue = "JohnDoe"

        // Use confirmation to wait for the asynchronous callback
        await confirmation("Expected to receive a single notification") { confirm in

            // 1. Set up the watcher
            let watcher = NotificationWatcher(notificationName) { notification in
                let receivedValue = notification.userInfo?[testKey] as? String
                #expect(receivedValue == testValue)
                confirm()
            }

            // 2. Allow the internal Task in the watcher a moment to start listening
            try? await Task.sleep(nanoseconds: 50_000_000) // 50 ms delay

            // 3. Dispatch the notification
            let dispatcher = NotificationDispatcher(notificationName)
            dispatcher.post(value: testValue, forKey: testKey)

            // 4. Allow the async sequence to process the event
            try? await Task.sleep(nanoseconds: 50_000_000)

            // Keep a reference to the watcher so it isn't deallocated prematurely
            _ = watcher
        }
    }

    /// Tests that the watcher correctly handles listening to multiple notification names concurrently.
    @Test("Posts and receives multiple notification types")
    func testMultipleNotifications() async throws {
        let nameOne = Notification.Name("TestMultipleOne")
        let nameTwo = Notification.Name("TestMultipleTwo")

        // We expect the closure to be triggered exactly twice
        await confirmation("Expected to receive two distinct notifications", expectedCount: 2) { confirm in
            let watcher = NotificationWatcher([nameOne, nameTwo]) { notification in
                #expect(notification.name == nameOne || notification.name == nameTwo)
                confirm()
            }

            try? await Task.sleep(nanoseconds: 50_000_000)

            NotificationDispatcher(nameOne).post()
            NotificationDispatcher(nameTwo).post()

            try? await Task.sleep(nanoseconds: 50_000_000)

            _ = watcher
        }
    }

    /// Tests that the dispatcher correctly sends a full dictionary payload and the watcher reads it.
    @Test("Posts and receives a dictionary payload")
    func testDictionaryPayload() async throws {
        let name = Notification.Name("TestDictionaryPayload")
        let payload: [AnyHashable: any Sendable] = ["id": 123, "isActive": true]

        await confirmation("Expected to receive the dictionary payload") { confirm in
            let watcher = NotificationWatcher(name) { notification in
                let id = notification.userInfo?["id"] as? Int
                let isActive = notification.userInfo?["isActive"] as? Bool

                #expect(id == 123)
                #expect(isActive == true)
                confirm()
            }

            try? await Task.sleep(nanoseconds: 50_000_000)

            NotificationDispatcher(name).post(payload)

            try? await Task.sleep(nanoseconds: 50_000_000)

            _ = watcher
        }
    }
}
