#if os(OSX)
import Cocoa
typealias Color = NSColor
#else
import UIKit
typealias Color = UIColor
#endif

// Custom enum conforming to ValueCodable.
enum ColorChoice {
    case Red
    case Green
    case Blue
    case Other(Color)
}

extension ColorChoice: ValueCodable, Equatable {

    enum Keys: String {
        case Tag, OtherColor
    }

    enum Tag: Int {
        case Red, Green, Blue, Other
    }

    func encode(with coder: NSCoder) {
        switch self {
        case .Red:
            coder.encodeInteger(Tag.Red.rawValue, forKey: Keys.Tag.rawValue)
        case .Green:
            coder.encodeInteger(Tag.Green.rawValue, forKey: Keys.Tag.rawValue)
        case .Blue:
            coder.encodeInteger(Tag.Blue.rawValue, forKey: Keys.Tag.rawValue)
        case .Other(let color):
            coder.encodeInteger(Tag.Other.rawValue, forKey: Keys.Tag.rawValue)
            coder.encodeObject(color, forKey: Keys.OtherColor.rawValue)
        }
    }

    init?(coder: NSCoder) {
        guard let tag = Tag(rawValue: coder.decodeIntegerForKey(Keys.Tag.rawValue)) else { return nil }
        switch tag {
        case .Red:
            self = .Red
        case .Green:
            self = .Green
        case .Blue:
            self = .Blue
        case .Other:
            guard let color = coder.decodeObjectOfClass(Color.self, forKey: Keys.OtherColor.rawValue) else { return nil }
            self = .Other(color)
        }
    }

}

func ==(lhs: ColorChoice, rhs: ColorChoice) -> Bool {
    switch (lhs, rhs) {
    case (.Red, .Red), (.Green, .Green), (.Blue, .Blue):
        return true
    case let (.Other(lhsColor), .Other(rhsColor)):
        return lhsColor == rhsColor
    default:
        return false
    }
}

// Automatic conformance via Int being bridged to NSNumber.
enum WeightClass: Int, ValueCodable {
    case Fly = 112
    case Bantham = 118
    case Feather = 126
    case Light = 135
    case Welter = 147
    case Middle = 160
    case Heavy = 200
}

// Conformance for a Swift type.
extension UnicodeScalar: ValueCodable {

    public func encode(with aCoder: NSCoder) {
        aCoder.encodeValue(String(self))
    }

    public init?(coder aDecoder: NSCoder) {
        guard let scalar = aDecoder.decodeValue(ofType: String.self)?.unicodeScalars.first else { return nil }
        self = scalar
    }

}

// Automatic conformance via UnicodeScalar being ValueCodable.
// Ugh, but raw-value enums have to be literals
enum Zodiac: UnicodeScalar, ValueCodable {
    case Aries = "♈"
    case Taurus = "♉"
    case Gemini = "♊"
    case Cancer = "♋"
    case Leo = "♌"
    case Virgo = "♍"
    case Libra = "♎"
    case Scorpio = "♏"
    case Sagittarius = "♐"
    case Capricorn = "♑"
    case Aquarius = "♒"
    case Pisces = "♓"
}

/// Custom struct conforming to ValueCodable.
struct Person {
    let fullName: String
    let favoriteColor: ColorChoice
    let weightClass: WeightClass
    let zodiacSign: Zodiac
}

extension Person: ValueCodable, Equatable {

    private enum Keys: String {
        case FullName, FavoriteColor, WeightClass, ZodiacSign
    }

    func encode(with coder: NSCoder) {
        coder.encodeValue(fullName, forKey: Keys.FullName.rawValue)
        coder.encodeValue(favoriteColor, forKey: Keys.FavoriteColor.rawValue)
        coder.encodeValue(weightClass, forKey: Keys.WeightClass.rawValue)
        coder.encodeValue(zodiacSign, forKey: Keys.ZodiacSign.rawValue)
    }

    init?(coder aDecoder: NSCoder) {
        guard let fullName = aDecoder.decodeValue(ofType: String.self, forKey: Keys.FullName.rawValue),
            favoriteColor = aDecoder.decodeValue(ofType: ColorChoice.self, forKey: Keys.FavoriteColor.rawValue),
            weightClass = aDecoder.decodeValue(ofType: WeightClass.self, forKey: Keys.WeightClass.rawValue),
            zodiacSign = aDecoder.decodeValue(ofType: Zodiac.self, forKey: Keys.ZodiacSign.rawValue) else { return nil }
        self.fullName = fullName
        self.favoriteColor = favoriteColor
        self.weightClass = weightClass
        self.zodiacSign = zodiacSign
    }

}

func ==(lhs: Person, rhs: Person) -> Bool {
    return lhs.fullName == rhs.fullName && lhs.favoriteColor == rhs.favoriteColor && lhs.weightClass == rhs.weightClass && lhs.zodiacSign == rhs.zodiacSign
}

// MARK -

let taupe = UIColor(red: 0.28, green: 0.24, blue: 0.20, alpha: 1.0)

let value1 = Person(fullName: "Zachary Waldowski", favoriteColor: .Blue, weightClass: .Heavy, zodiacSign: .Taurus)
let value2 = Person(fullName: "Christian Keur", favoriteColor: .Other(taupe), weightClass: .Welter, zodiacSign: .Virgo)

let data1 = NSKeyedArchiver.archivedData(withValue: value1)
let newValue1 = NSKeyedUnarchiver.unarchivedValue(ofType: Person.self, withData: data1)!
print(newValue1)

let data2 = NSKeyedArchiver.archivedData(withValue: value2)
let newValue2 = NSKeyedUnarchiver.unarchivedValue(ofType: Person.self, withData: data2)!
print(newValue2)
