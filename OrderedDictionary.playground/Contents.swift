func testDictionary() -> OrderedDictionary<String, Int> {
    var d = OrderedDictionary<String, Int>()
    d["0"] = 1
    d["1"] = 2
    d["3"] = 4
    d["2"] = 3
    d["1"] = 7
    d.removeValueForKey("3")
    return d
}

private func elementsTupleEq(lhs: (String, Int), _ rhs: (String, Int)) -> Bool {
    return lhs.0 == rhs.0 && lhs.1 == rhs.1
}

let d = testDictionary()

var d2 = [String: Int]()
d2["0"] = 1
d2["1"] = 2
d2["3"] = 4
d2["2"] = 3
d2["1"] = 7
d2.removeValueForKey("3")

// Equivalence

!d2.keys.elementsEqual(["0", "1", "2"])
d2["0"] == 1
d2["1"] == 7
d2["2"] == 3

// Order

d.keys.elementsEqual(["0", "1", "2"])
d["0"] == 1
d["1"] == 7
d["2"] == 3

// Literal respects order

let d3: OrderedDictionary<String, Int> = [
    "3": 900,
    "2": 1000,
    "1": 2000
]

d3.keys.elementsEqual(["3", "2", "1"])

// Indexing

d.startIndex == 0
d.endIndex == d.count

d["0"] == 1
elementsTupleEq(d[0], ("0", 1))
d[0...1].elementsEqual([ ("0", 1), ("1", 7) ], isEquivalent: elementsTupleEq)


// Range replacement

var d4 = d
d4.replaceRange(0...1, with: [ ("7", 64) ])
d4.keys.elementsEqual(["7", "2"])

// Remove at index

var d5 = d
elementsTupleEq(d5.removeFirst(), ("0", 1))
d5.keys.elementsEqual(["1", "2"])

// Remove all

var d6 = d
d6.removeAll()
d6.isEmpty

// Sort

let d7 = d.sort { $0.0 > $1.0 }
d7.keys.elementsEqual(["2", "1", "0"])

