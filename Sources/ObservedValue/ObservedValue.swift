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

/// A `@MainActor`-isolated property wrapper alternative that allows observing changes to a specific value.
/// It is specifically designed to be a lightweight, thread-safe replacement for Combine's `CurrentValueSubject`.
@MainActor
public final class ObservedValue<Value: Equatable> {

    /// A dictionary storing the registered observer closures, keyed by unique string identifiers.
    private var actions = [String: @MainActor (Value) -> Void]()

    /// Initializes the observed object with a starting value.
    /// - Parameter value: The initial value to be stored.
    public init(_ value: Value) {
        self.value = value
    }

    /// The underlying value being observed.
    /// Setting a new value automatically triggers all registered observer actions,
    /// provided the new value is different from the old one.
    public var value: Value {
        didSet {
            // Swift implicitly provides 'oldValue' inside the didSet block.
            // We only trigger the actions if the value has actually changed.
            guard oldValue != value else { return }

            for action in actions.values {
                action(value)
            }
        }
    }

    /// Retrieves an existing observer action associated with a specific identifier.
    /// - Parameter id: The unique string identifier for the action.
    /// - Returns: The closure associated with the identifier, or `nil` if not found.
    public func action(_ id: String) -> (@MainActor (Value) -> Void)? {
        actions[id]
    }

    /// Registers, updates, or removes an observer action for a specific identifier.
    /// - Parameters:
    ///   - id: The unique string identifier for the action.
    ///   - action: The closure to be executed when the value changes. Pass `nil` to remove an existing action.
    public func setAction(_ id: String, action: (@MainActor (Value) -> Void)?) {
        actions[id] = action
    }
}
