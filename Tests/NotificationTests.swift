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
@testable import SklvObserver

@Suite("Notification Tests") @MainActor
struct NotificationTests {

    @Test("Notification Delivery")
    func testNotificationDelivery() async throws {
        let testName = Notification.Name("testNotificationDelivery")
        let key = "data"
        let value = 12345678

        let dispatcher = NotificationDispatcher(name: testName)

        await confirmation { confirm in
            let watcher = NotificationWatcher(name: testName)
            watcher.action = { userInfo in
                let data = userInfo?[key] as? Int

                #expect(data == value)
                confirm()
            }

            dispatcher.post([key: value])
        }
    }

    @Test("Watcher Deinit")
    func testWatcherDeinit() {
        let testName = Notification.Name("testWatcherDeinit")
        var count = 0

        let dispatcher = NotificationDispatcher(name: testName)

        do {
            let watcher = NotificationWatcher(name: testName)
            watcher.action = { _ in
                count += 1
            }

            dispatcher.post()
            #expect(count == 1)
        }

        dispatcher.post()
        #expect(count == 1)
    }
}
