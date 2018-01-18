func testDictionary() -> OrderedDictionary<String, Int> {
    var d = OrderedDictionary<String, Int>()
    d["0"] = 1
    d["1"] = 2
    d["3"] = 4
    d["2"] = 3
    d["1"] = 7
    d.removeValue(forKey: "3")
    return d
}

let d = testDictionary()

var d2 = [String: Int]()
d2["0"] = 1
d2["1"] = 2
d2["3"] = 4
d2["2"] = 3
d2["1"] = 7
d2.removeValue(forKey: "3")

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
d[0] == ("0", 1)
d[0 ..< 2].elementsEqual([ (key: "0", value: 1), (key: "1", value: 7) ], by: ==)

// Remove all

var d4 = d
d4.removeAll()
d4.isEmpty
