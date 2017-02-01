#if os(macOS)
import Cocoa
typealias Color = NSColor
#else
import UIKit
typealias Color = UIColor
#endif

// Custom enum conforming to ValueCodable.
enum ColorChoice {
    case red
    case green
    case blue
    case other(Color)
}

extension ColorChoice: ValueCodable, Equatable {

    enum Keys: String {
        case Tag, OtherColor
    }

    enum Tag: Int {
        case red, green, blue, other
    }

    func encode(with coder: NSCoder) {
        switch self {
        case .red:
            coder.encode(Tag.red.rawValue, forKey: Keys.Tag.rawValue)
        case .green:
            coder.encode(Tag.green.rawValue, forKey: Keys.Tag.rawValue)
        case .blue:
            coder.encode(Tag.blue.rawValue, forKey: Keys.Tag.rawValue)
        case .other(let color):
            coder.encode(Tag.other.rawValue, forKey: Keys.Tag.rawValue)
            coder.encode(color, forKey: Keys.OtherColor.rawValue)
        }
    }

    init?(coder: NSCoder) {
        guard let tag = Tag(rawValue: coder.decodeInteger(forKey: Keys.Tag.rawValue)) else { return nil }
        switch tag {
        case .red:
            self = .red
        case .green:
            self = .green
        case .blue:
            self = .blue
        case .other:
            guard let color = coder.decodeObject(of: Color.self, forKey: Keys.OtherColor.rawValue) else { return nil }
            self = .other(color)
        }
    }

}

func ==(lhs: ColorChoice, rhs: ColorChoice) -> Bool {
    switch (lhs, rhs) {
    case (.red, .red), (.green, .green), (.blue, .blue):
        return true
    case let (.other(lhsColor), .other(rhsColor)):
        return lhsColor == rhsColor
    default:
        return false
    }
}

// Automatic conformance via Int being bridged to NSNumber.
enum WeightClass: Int, ValueCodable {
    case fly = 112
    case bantham = 118
    case feather = 126
    case light = 135
    case welter = 147
    case middle = 160
    case heavy = 200
}

// Conformance for a Swift type.
extension UnicodeScalar: ValueCodable {

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(String(self))
    }

    public init?(coder aDecoder: NSCoder) {
        guard let scalar = aDecoder.decodeValue(of: String.self)?.unicodeScalars.first else { return nil }
        self = scalar
    }

}

// Automatic conformance via UnicodeScalar being ValueCodable.
// Ugh, but raw-value enums have to be literals
enum Zodiac: UnicodeScalar, ValueCodable {
    case aries = "♈"
    case taurus = "♉"
    case gemini = "♊"
    case cancer = "♋"
    case leo = "♌"
    case virgo = "♍"
    case libra = "♎"
    case scorpio = "♏"
    case sagittarius = "♐"
    case capricorn = "♑"
    case aquarius = "♒"
    case pisces = "♓"
}

/// Custom struct conforming to ValueCodable.
struct Person {
    let fullName: String
    let favoriteColor: ColorChoice?
    let weightClass: WeightClass
    let zodiacSign: Zodiac
}

extension Person: ValueCodable, Equatable {

    fileprivate enum Keys: String {
        case FullName, FavoriteColor, WeightClass, ZodiacSign
    }

    func encode(with coder: NSCoder) {
        coder.encode(fullName, forKey: Keys.FullName.rawValue)
        coder.encode(favoriteColor, forKey: Keys.FavoriteColor.rawValue)
        coder.encode(weightClass, forKey: Keys.WeightClass.rawValue)
        coder.encode(zodiacSign, forKey: Keys.ZodiacSign.rawValue)
    }

    init?(coder aDecoder: NSCoder) {
        guard let fullName = aDecoder.decodeValue(of: String.self, forKey: Keys.FullName.rawValue),
            let weightClass = aDecoder.decodeValue(of: WeightClass.self, forKey: Keys.WeightClass.rawValue),
            let zodiacSign = aDecoder.decodeValue(of: Zodiac.self, forKey: Keys.ZodiacSign.rawValue) else { return nil }
        self.fullName = fullName
        self.favoriteColor = aDecoder.decodeValue(of: ColorChoice.self, forKey: Keys.FavoriteColor.rawValue)
        self.weightClass = weightClass
        self.zodiacSign = zodiacSign
    }

}

func ==(lhs: Person, rhs: Person) -> Bool {
    return lhs.fullName == rhs.fullName && lhs.favoriteColor == rhs.favoriteColor && lhs.weightClass == rhs.weightClass && lhs.zodiacSign == rhs.zodiacSign
}

// MARK -

let taupe = UIColor(red: 0.28, green: 0.24, blue: 0.20, alpha: 1.0)

let value1 = Person(fullName: "Zachary Waldowski", favoriteColor: .blue, weightClass: .heavy, zodiacSign: .taurus)
let value2 = Person(fullName: "Christian Keur", favoriteColor: .other(taupe), weightClass: .welter, zodiacSign: .virgo)

let data1 = NSKeyedArchiver.archivedData(withRoot: value1)
let newValue1 = NSKeyedUnarchiver.unarchivedValue(of: Person.self, with: data1)!
print(newValue1)

let data2 = NSKeyedArchiver.archivedData(withRoot: value2)
let newValue2 = NSKeyedUnarchiver.unarchivedValue(of: Person.self, with: data2)!
print(newValue2)

let value3: IndexSet = [ 0, 1, 3, 42, 43, 99 ]
let data3 = NSKeyedArchiver.archivedData(withRoot: value3)
let newValue3 = NSKeyedUnarchiver.unarchivedValue(of: IndexSet.self, with: data3)!
print(newValue3)
