public struct OrderedDictionary<Key: Hashable, Value> {

    public typealias Element = Hash.Element

    public typealias Keys = [Key]
    public private(set) var keys: Keys

    private typealias Hash = [Key: Value]
    private var elements: Hash

    private init(keys: Keys, elements: Hash) {
        self.keys = keys
        self.elements = elements
    }

}

extension OrderedDictionary {

    public init(minimumCapacity: Int) {
        keys = Keys()
        keys.reserveCapacity(minimumCapacity)
        elements = Hash(minimumCapacity: minimumCapacity)
    }

}

extension OrderedDictionary: CollectionType {

    private func toItems<T: CollectionType where T.Generator.Element == Key>(keys: T) -> LazyMapCollection<T, Element> {
        return keys.lazy.map { ($0, self.elements[$0]!) }
    }

    public func generate() -> LazyMapGenerator<IndexingGenerator<[Key]>, Element> {
        return toItems(keys).generate()
    }

    public var startIndex: Int { return keys.startIndex }
    public var endIndex: Int { return keys.startIndex }

    public subscript (bounds: Range<Int>) -> LazyMapCollection<Keys.SubSequence, Element> {
        return toItems(keys[bounds])
    }

    public var isEmpty: Bool {
        return elements.isEmpty
    }

    public var count: Int {
        return elements.count
    }

}

extension OrderedDictionary: MutableIndexable {

    public subscript(position: Keys.Index) -> Element {
        get {
            guard case keys.indices = position, let value = elements[keys[position]] else {
                preconditionFailure("index out of bounds")
            }
            return (keys[position], value)
        }
        set {
            guard case keys.indices = position where elements.removeValueForKey(keys[position]) != nil else {
                preconditionFailure("index out of bounds")
            }

            keys[position] = newValue.0
            elements[newValue.0] = newValue.1
        }
    }

}

extension OrderedDictionary {

    public func indexForKey(key: Key) -> Int? {
        let hash = key.hashValue
        return keys.indexOf({ $0.hashValue == hash })
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
                _ = removeValueForKey(key)
            }
        }
    }

    public mutating func updateElement(element: Element, atIndex position: Int) -> Element? {
        guard case keys.indices = position, let oldValue = elements.removeValueForKey(keys[position]) else {
            preconditionFailure("index out of bounds")
        }

        let oldKey = keys[position]
        keys[position] = element.0
        elements[element.0] = element.1
        return (oldKey, oldValue)
    }

    public mutating func updateValue(value: Value, forKey key: Key) -> Value? {
        let ret = elements.updateValue(value, forKey: key)
        if ret == nil {
            keys.append(key)
        }
        return ret
    }

    public mutating func removeValueForKey(key: Key) -> Value? {
        guard let ret = elements.removeValueForKey(key), index = indexForKey(key) else { return nil }
        keys.removeAtIndex(index)
        return ret
    }

}

extension OrderedDictionary: RangeReplaceableCollectionType {

    public init() {
        keys = Keys()
        elements = Hash()
    }

    public mutating func replaceRange<C : CollectionType where C.Generator.Element == Element>(subRange: Range<Int>, with newElements: C) {
        let oldKeys = keys[subRange]

        let newKeys = newElements.lazy.map { $0.0 }
        keys.replaceRange(subRange, with: newKeys)

        for oldKey in oldKeys {
            elements.removeValueForKey(oldKey)
        }

        for (newKey, value) in newElements {
            elements[newKey] = value
        }
    }

    public mutating func insert(newElement: Element, atIndex i: Int) {
        var i = i
        if let indexInKeys = indexForKey(newElement.0) {
            keys.removeAtIndex(indexInKeys)
            if i > indexInKeys {
                i += i.predecessor()
            }
        }

        keys.insert(newElement.0, atIndex: i)
        elements[newElement.0] = newElement.1
    }

    public mutating func reserveCapacity(n: Int) {
        keys.reserveCapacity(n)
    }

    public mutating func removeAtIndex(i: Int) -> Element {
        let key = keys.removeAtIndex(i)
        let value = elements.removeValueForKey(key)
        return (key, value!)
    }

    public mutating func removeFirst() -> Element {
        let key = keys.removeFirst()
        let value = elements.removeValueForKey(key)
        return (key, value!)
    }

    public mutating func removeAll(keepCapacity keepCapacity: Bool = false) {
        keys.removeAll(keepCapacity: keepCapacity)
        elements.removeAll(keepCapacity: keepCapacity)
    }

}

extension OrderedDictionary: DictionaryLiteralConvertible {

    public init(dictionaryLiteral list: Element...) {
        keys = list.map { $0.0 }
        elements = Hash(minimumCapacity: list.count)
        for (key, value) in list {
            elements[key] = value
        }
    }

}

extension OrderedDictionary {

    public var values: LazyMapCollection<Keys, Value> {
        return keys.lazy.map { self.elements[$0]! }
    }

    public mutating func sortInPlace(@noescape isOrderedBefore: (Element, Element) -> Bool) {
        keys.sortInPlace { (key1, key2) -> Bool in
            switch (self.elements.indexForKey(key1), self.elements.indexForKey(key2)) {
            case (.Some(let el1), .Some(let el2)):
                return isOrderedBefore(self.elements[el1], self.elements[el2])
            case (.None, .Some):
                return true
            default:
                return false
            }
        }
    }

    public func sort(@noescape isOrderedBefore: (Element, Element) -> Bool) -> OrderedDictionary<Key, Value> {
        var new = self
        new.sortInPlace(isOrderedBefore)
        return new
    }

}

extension OrderedDictionary where Key: Comparable {

    public mutating func sortInPlace() {
        sortInPlace { (el1, el2) -> Bool in
            el1.0 < el2.0
        }
    }

    public func sort() -> OrderedDictionary<Key, Value> {
        var new = self
        new.sortInPlace()
        return new
    }

}

extension OrderedDictionary: CustomStringConvertible, CustomDebugStringConvertible {

    private func makeDescription(debug debug: Bool) -> String {
        if isEmpty { return "[:]" }

        var result = "["
        var first = true
        for (key, value) in self {
            if first {
                first = false
            } else {
                result += ", "
            }
            if debug {
                debugPrint(key, terminator: "", toStream: &result)
            } else {
                print(key, terminator: "", toStream: &result)
            }
            result += ": "
            if debug {
                debugPrint(value, terminator: "", toStream: &result)
            } else {
                print(value, terminator: "", toStream: &result)
            }
        }
        result += "]"
        return result
    }

    public var description: String {
        return makeDescription(debug: false)
    }

    public var debugDescription: String {
        return makeDescription(debug: false)
    }
    
}

extension OrderedDictionary: CustomReflectable {
    
    public func customMirror() -> Mirror {
        return Mirror(self, unlabeledChildren: self, displayStyle: .Dictionary)
    }
    
}
