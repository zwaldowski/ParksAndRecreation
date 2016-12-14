public struct OrderedDictionarySlice<Key: Hashable, Value>: RandomAccessCollection {
    
    private typealias Base = OrderedDictionary<Key, Value>
    
    private let keys: ArraySlice<Key>
    private let elements: Base.Hash
    
    fileprivate init(keys: ArraySlice<Key>, elements: Base.Hash) {
        self.keys = keys
        self.elements = elements
    }
    
    /// The element type: a tuple containing an individual key-value pair.
    public typealias Element = (key: Key, value: Value)
    
    public typealias Indices = CountableRange<Int>
    
    public func makeIterator() -> LazyMapIterator<IndexingIterator<ArraySlice<Key>>, Element> {
        return keys.lazy.map { ($0, self.elements[$0]!.1) }.makeIterator()
    }
    
    public var startIndex: Int {
        return keys.startIndex
    }
    
    public var endIndex: Int {
        return keys.endIndex
    }
    
    public var count: Int {
        return keys.count
    }
    
    fileprivate func checkIndex(_ index: Int) {
        guard case keys.indices = index else {
            preconditionFailure("index out of bounds")
        }
    }
    
    public subscript(position: Int) -> Element {
        checkIndex(position)
        let key = keys[position]
        let value = elements[key]!.1
        return (key, value)
    }
    
    public subscript(range: Range<Int>) -> OrderedDictionarySlice<Key, Value> {
        return OrderedDictionarySlice(keys: keys[range], elements: elements)
    }
    
}

public struct OrderedDictionary<Key: Hashable, Value> {
    
    fileprivate typealias Hash = Dictionary<Key, (Int, Value)>
    
    /// A collection containing just the keys of the dictionary.
    ///
    /// When iterated over, keys appear in this collection in the same order as they
    /// occur were added to the dictionary. Each key in the keys array has a unique
    /// value.
    ///
    ///     let countryCodes = ["BR": "Brazil", "GH": "Ghana", "JP": "Japan"]
    ///     for k in countryCodes.keys {
    ///         print(k)
    ///     }
    ///     // Prints "BR"
    ///     // Prints "GH"
    ///     // Prints "JP"
    fileprivate(set) public var keys: [Key]
    fileprivate var elements: Hash
    
    fileprivate init(keys: [Key], elements: Hash) {
        self.keys = keys
        self.elements = elements
    }
    
    /// Create an empty instance.
    public init() {
        self.init(keys: [], elements: [:])
    }
    
    /// Creates an instance with at least `minimumCapacity` worth of
    /// storage.
    ///
    /// Use this initializer to avoid intermediate reallocations when you know
    /// how many key-value pairs you are adding to the dictionary.
    public init(minimumCapacity: Int) {
        self.init(keys: [], elements: Dictionary(minimumCapacity: minimumCapacity))
        keys.reserveCapacity(minimumCapacity)
    }
    
}

extension OrderedDictionary: RandomAccessCollection {
    
    /// The element type: a tuple containing an individual key-value pair.
    public typealias Element = (key: Key, value: Value)
    
    public typealias Indices = CountableRange<Int>
    
    public func makeIterator() -> LazyMapIterator<IndexingIterator<[Key]>, Element> {
        return keys.lazy.map { ($0, self.elements[$0]!.1) }.makeIterator()
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
    
    fileprivate func checkIndex(_ index: Int) {
        guard case keys.indices = index else {
            preconditionFailure("index out of bounds")
        }
    }
    
    public subscript(position: Int) -> Element {
        get {
            checkIndex(position)
            let key = keys[position]
            let value = elements[key]!.1
            return (key, value)
        }
        set {
            checkIndex(position)
            var oldKey = newValue.0
            swap(&keys[position], &oldKey)
            _ = elements.removeValue(forKey: oldKey)
            elements[newValue.0] = (position, newValue.1)
        }
    }
    
    public subscript(range: Range<Int>) -> OrderedDictionarySlice<Key, Value> {
        return OrderedDictionarySlice(keys: keys[range], elements: elements)
    }
    
}

extension OrderedDictionary {
    
    /// A collection containing just the values of the dictionary.
    ///
    /// When iterated over, values appear in this collection in the same order as they
    /// occur in the dictionary's key-value pairs.
    ///
    ///     let countryCodes = ["BR": "Brazil", "GH": "Ghana", "JP": "Japan"]
    ///     print(countryCodes)
    ///     // Prints "["BR": "Brazil", "JP": "Japan", "GH": "Ghana"]"
    ///     for v in countryCodes.values {
    ///         print(v)
    ///     }
    ///     // Prints "Brazil"
    ///     // Prints "Japan"
    ///     // Prints "Ghana"
    public var values: LazyMapCollection<[Key], Value> {
        return keys.lazy.map { self[$0]! }
    }
    
    /// Returns the `Index` for the given key.
    /// - parameter key: hash value for which to look for an index
    /// - returns: An index, or `nil` if the key is not present in the ordered
    ///   dictionary.
    public func index(forKey key: Key) -> Int? {
        return elements[key]?.0
    }
    
    /// Accesses the value associated with the given key for reading and writing.
    ///
    /// This *key-based* subscript returns the value for the given key if the key
    /// is found in the dictionary, or `nil` if the key is not found.
    ///
    /// The following example creates a new dictionary and prints the value of a
    /// key found in the dictionary (`"Coral"`) and a key not found in the
    /// dictionary (`"Cerise"`).
    ///
    ///     var hues = ["Heliotrope": 296, "Coral": 16, "Aquamarine": 156]
    ///     print(hues["Coral"])
    ///     // Prints "Optional(16)"
    ///     print(hues["Cerise"])
    ///     // Prints "nil"
    ///
    /// When you assign a value for a key and that key already exists, the
    /// dictionary overwrites the existing value. If the dictionary doesn't
    /// contain the key, the key and value are added as a new key-value pair.
    ///
    /// Here, the value for the key `"Coral"` is updated from `16` to `18` and a
    /// new key-value pair is added for the key `"Cerise"`.
    ///
    ///     hues["Coral"] = 18
    ///     print(hues["Coral"])
    ///     // Prints "Optional(18)"
    ///
    ///     hues["Cerise"] = 330
    ///     print(hues["Cerise"])
    ///     // Prints "Optional(330)"
    ///
    /// If you assign `nil` as the value for the given key, the dictionary
    /// removes that key and its associated value.
    ///
    /// In the following example, the key-value pair for the key `"Aquamarine"`
    /// is removed from the dictionary by assigning `nil` to the key-based
    /// subscript.
    ///
    ///     hues["Aquamarine"] = nil
    ///     print(hues)
    ///     // Prints "["Coral": 18, "Heliotrope": 296, "Cerise": 330]"
    ///
    /// - Parameter key: The key to find in the dictionary.
    /// - Returns: The value associated with `key` if `key` is in the dictionary;
    ///   otherwise, `nil`.
    public subscript(key: Key) -> Value? {
        get {
            return elements[key]?.1
        }
        set {
            guard let newValue = newValue else {
                _ = removeValue(forKey: key)
                return
            }
            
            _ = updateValue(newValue, forKey: key)
        }
    }
    
    /// Updates the value stored in the dictionary for the given key, or adds a
    /// new key-value pair if the key does not exist.
    ///
    /// Use this method instead of key-based subscripting when you need to know
    /// whether the new value supplants the value of an existing key. If the
    /// value of an existing key is updated, `updateValue(_:forKey:)` returns
    /// the original value.
    ///
    ///     var hues = ["Heliotrope": 296, "Coral": 16, "Aquamarine": 156]
    ///
    ///     if let oldValue = hues.updateValue(18, forKey: "Coral") {
    ///         print("The old value of \(oldValue) was replaced with a new one.")
    ///     }
    ///     // Prints "The old value of 16 was replaced with a new one."
    ///
    /// If the given key is not present in the dictionary, this method adds the
    /// key-value pair and returns `nil`.
    ///
    ///     if let oldValue = hues.updateValue(330, forKey: "Cerise") {
    ///         print("The old value of \(oldValue) was replaced with a new one.")
    ///     } else {
    ///         print("No value was found in the dictionary for that key.")
    ///     }
    ///     // Prints "No value was found in the dictionary for that key."
    ///
    /// - Parameters:
    ///   - value: The new value to add to the dictionary.
    ///   - key: The key to associate with `value`. If `key` already exists in
    ///     the dictionary, `value` replaces the existing associated value. If
    ///     `key` isn't already a key of the dictionary, the `(key, value)` pair
    ///     is added.
    /// - Returns: The value that was replaced, or `nil` if a new key-value pair
    ///   was added.
    public mutating func updateValue(_ value: Value, forKey key: Key) -> Value? {
        if let oldElement = elements.removeValue(forKey: key) {
            elements[key] = (oldElement.0, value)
            return oldElement.1
        } else {
            elements[key] = (keys.endIndex, value)
            keys.append(key)
            return nil
        }
    }
    
    /// Removes the given key and its associated value from the dictionary.
    ///
    /// If the key is found in the dictionary, this method returns the key's
    /// associated value. On removal, this method invalidates all indices with
    /// respect to the dictionary.
    ///
    ///     var hues = ["Heliotrope": 296, "Coral": 16, "Aquamarine": 156]
    ///     if let value = hues.removeValue(forKey: "Coral") {
    ///         print("The value \(value) was removed.")
    ///     }
    ///     // Prints "The value 16 was removed."
    ///
    /// If the key isn't found in the dictionary, `removeValue(forKey:)` returns
    /// `nil`.
    ///
    ///     if let value = hues.removeValueForKey("Cerise") {
    ///         print("The value \(value) was removed.")
    ///     } else {
    ///         print("No value found for that key.")
    ///     }
    ///     // Prints "No value found for that key.""
    ///
    /// - Parameter key: The key to remove along with its associated value.
    /// - Returns: The value that was removed, or `nil` if the key was not
    ///   present in the dictionary.
    ///
    /// - Complexity: O(*n*), where *n* is the number of key-value pairs in the
    ///   dictionary.
    public mutating func removeValue(forKey key: Key) -> Value? {
        guard let result = elements.removeValue(forKey: key) else { return nil }
        keys.remove(at: result.0)
        return result.1
    }
    
}

extension OrderedDictionary {
    
    /// Removes all key-value pairs from the dictionary.
    ///
    /// Calling this method invalidates all indices with respect to the
    /// dictionary.
    ///
    /// - Parameter keepCapacity: Whether the dictionary should keep its
    ///   underlying storage. If you pass `true`, the operation preserves the
    ///   storage capacity that the collection has, otherwise the underlying
    ///   storage is released.  The default is `false`.
    ///
    /// - Complexity: O(*n*), where *n* is the number of key-value pairs in the
    ///   dictionary.
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
        for (index, (key, value)) in list.enumerated() {
            elements[key] = (index, value)
        }
    }
    
}

extension OrderedDictionary: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    
    fileprivate func makeDescription(debug: Bool) -> String {
        guard !isEmpty else { return "[:]" }
        var result = debug ? "OrderedDictionary([" : "["
        var first = true
        for (k, v) in self {
            if first {
                first = false
            } else {
                result += ", "
            }
            
            if debug {
                debugPrint(k, terminator: "", to: &result)
            } else {
                print(k, terminator: "", to: &result)
            }
            
            result += ": "
            
            if debug {
                debugPrint(v, terminator: "", to: &result)
            } else {
                print(v, terminator: "", to: &result)
            }
        }
        result += debug ? "])" : "]"
        return result
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
        return Mirror(self, unlabeledChildren: self, displayStyle: .dictionary)
    }
}

