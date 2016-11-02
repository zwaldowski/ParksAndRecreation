/// An ordered collection of key-value pairs with hash-based mapping from
/// `Key` to `Value`.
public struct OrderedDictionary<Key: Hashable, Value> {
    /// A key-value pair
    public typealias Element = Hash.Element

    /// An ordered list containing just the keys of `self`.
    fileprivate(set) public var keys: [Key]

    fileprivate typealias Hash = [Key: Value]
    fileprivate var elements: Hash

    fileprivate init(keys: [Key], elements: Hash) {
        self.keys = keys
        self.elements = elements
    }

    /// Create an empty instance.
    public init() {
        self.init(keys: [], elements: [:])
    }
}

extension OrderedDictionary: RandomAccessCollection {

    public typealias Indices = CountableRange<Int>

    public func makeIterator() -> LazyMapIterator<IndexingIterator<[Key]>, Element> {
        return keys.lazy.map { ($0, self.elements[$0]!) }.makeIterator()
    }

    public var startIndex: Int {
        return keys.startIndex
    }

    public var endIndex: Int {
        return keys.endIndex
    }

    public var count: Int {
        return elements.count
    }

    public subscript(position: Int) -> Element {
        get {
            guard case keys.indices = position, let value = elements[keys[position]] else {
                preconditionFailure("index out of bounds")
            }
            return (keys[position], value)
        }
        set {
            guard case keys.indices = position , elements.removeValue(forKey: keys[position]) != nil else {
                preconditionFailure("index out of bounds")
            }

            keys[position] = newValue.0
            elements[newValue.0] = newValue.1
        }
    }

    public subscript(range: Range<Int>) -> LazyMapRandomAccessCollection<ArraySlice<Key>, (Key, Value)> {
        return keys[range].lazy.map { ($0, self.elements[$0]!) }
    }

}

extension OrderedDictionary {

    /// An ordered collection containing just the values of `self`.
    public var values: LazyMapCollection<[Key], Value> {
        return keys.lazy.map { self.elements[$0]! }
    }

    /// Returns the `Index` for the given key.
    /// - parameter key: hash value for which to look for an index
    /// - returns: An index, or `nil` if the key is not present in the ordered
    ///   dictionary.
    public func index(forKey key: Key) -> Int? {
        let hash = key.hashValue
        return keys.index(where: { $0.hashValue == hash })
    }

    public subscript(key: Key) -> Value? {
        get {
            return elements[key]
        }
        set {
            if let newValue = newValue {
                if elements.updateValue(newValue, forKey: key) == nil {
                    keys.append(key)
                }
            } else {
                _ = removeValue(forKey: key)
            }
        }
    }

    /// Update the value stored in the dictionary for the given key, or, if the
    /// key does not exist, add a new key-value pair to the dictionary.
    ///
    /// - parameter value: New value to substitute in the dictionary.
    /// - parameter key: Hash value for which to look up replacement
    /// - returns: The value that was replaced, or `nil` if a new pair was added.
    public mutating func updateValue(_ value: Value, forKey key: Key) -> Value? {
        let ret = elements.updateValue(value, forKey: key)
        if ret == nil {
            keys.append(key)
        }
        return ret
    }

    /// Remove a given key and its associated value from the dictionary.
    /// - parameter key: Key for which to look for a value to remove
    /// - returns: The value that was removed, or `nil` if the key was not
    ///   present in the ordered dictionary.
    public mutating func removeValue(forKey key: Key) -> Value? {
        guard let ret = elements.removeValue(forKey: key), let index = index(forKey: key) else { return nil }
        keys.remove(at: index)
        return ret
    }

}

extension OrderedDictionary {

    /// Remove all elements.
    /// - parameter keepCapacity: If `true`, is a non-binding request to
    ///   avoid releasing storage, which can be a useful optimization
    ///   when `self` is going to be grown again.
    public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        keys.removeAll(keepingCapacity: keepCapacity)
        elements.removeAll(keepingCapacity: keepCapacity)
    }

}

extension OrderedDictionary: ExpressibleByDictionaryLiteral {

    /// Create an instanace with `list`.
    ///
    /// The order of elements in the dictionary literal is preserved.
    ///
    /// - parameter list: An ordered list of key/value pairs.
    public init(dictionaryLiteral list: (Key, Value)...) {
        self.init(keys: list.map { $0.0 }, elements: Hash(minimumCapacity: list.count))
        for (key, value) in list {
            elements[key] = value
        }
    }

}

extension OrderedDictionary: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    fileprivate func makeDescription(debug: Bool) -> String {
        if isEmpty { return "[:]" }
        let contents = isEmpty ? ":" : lazy.map {
            var string = ""
            if debug {
                debugPrint("\($0.0): \($0.1)", terminator: "", to: &string)
            } else {
                print("\($0.0): \($0.1)", terminator: "", to: &string)
            }
            return string
        }.joined(separator: ", ")
        return "[\(contents)]"
    }

    /// A textual representation of `self`.
    public var description: String {
        return makeDescription(debug: false)
    }

    /// A textual representation of `self`, suitable for debugging.
    public var debugDescription: String {
        return makeDescription(debug: true)
    }

    /// Return the `Mirror` for `self`.
    ///
    /// - note: The `Mirror` will be unaffected by mutations of `self`.
    /// - returns: An introspection `Mirror`.
    public var customMirror: Mirror {
        return Mirror(self, unlabeledChildren: elements, displayStyle: .dictionary)
    }
}
