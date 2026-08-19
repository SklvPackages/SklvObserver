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

import Foundation

/// A `@MainActor`-isolated token that manages an observation on an `ObservedValue`.
/// It automatically unregisters its action when deallocated, functioning similarly to `AnyCancellable` in Combine.
@MainActor
public final class ValueObserver<Value: Equatable> {

    /// A unique string identifier used to register and unregister the action with the underlying `ObservedValue`.
    private let id = UUID().uuidString

    /// A weak reference to the observed value to prevent strong reference cycles (memory leaks).
    private weak var observed: ObservedValue<Value>?

    /// Initializes the observer and actively registers an optional action.
    /// - Parameters:
    ///   - observed: The `ObservedValue` instance to monitor.
    ///   - action: An optional closure to execute whenever the observed value changes.
    public init(_ observed: ObservedValue<Value>, action: (@MainActor (Value) -> Void)? = nil) {
        self.observed = observed
        observed.setAction(id, action: action)
    }

    /// The closure to execute when the observed value changes.
    /// Getting or setting this property delegates directly to the underlying `ObservedValue`.
    public var action: (@MainActor (Value) -> Void)? {
        get {
            observed?.action(id)
        }
        set {
            observed?.setAction(id, action: newValue)
        }
    }

    /// Safely unregisters the action from the `ObservedValue` upon deallocation.
    /// Utilizing `isolated deinit` ensures thread-safe cleanup within the strict `@MainActor` context in Swift 6.
    isolated deinit {
        observed?.setAction(id, action: nil)
    }
}
