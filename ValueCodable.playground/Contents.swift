import Foundation

enum Test: String {
    case Foo, Bar, Baz
}

enum ColorChoice {
    case Red
    case Green
    case Blue
    case Other(String)
}

extension ColorChoice: ValueCodable {

    private enum Keys: String {
        case Tag, OtherText
    }

    private enum Tag: Int {
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
        case .Other(let text):
            coder.encodeInteger(Tag.Other.rawValue, forKey: Keys.Tag.rawValue)
            coder.encodeObject(text, forKey: Keys.OtherText.rawValue)
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
            guard let text = coder.decodeObjectForKey(Keys.OtherText.rawValue) as? String else { return nil }
            self = .Other(text)
        }
    }

}

struct Person {
    let fullName: String
    let favoriteColor: ColorChoice
}

extension Person: ValueCodable {

    private enum Keys: String {
        case FullName, FavoriteColor
    }

    func encode(with coder: NSCoder) {
        coder.encodeObject(fullName, forKey: Keys.FullName.rawValue)
        coder.encodeValue(favoriteColor, forKey: Keys.FavoriteColor.rawValue)
    }

    init?(coder aDecoder: NSCoder) {
        guard let fullName = aDecoder.decodeObjectForKey(Keys.FullName.rawValue) as? String,
            favoriteColor = aDecoder.decodeValue(ofType: ColorChoice.self, forKey: Keys.FavoriteColor.rawValue) else { return nil }
        self.fullName = fullName
        self.favoriteColor = favoriteColor
    }

}

let value1 = Person(fullName: "Zachary Waldowski", favoriteColor: .Red)
let value2 = Person(fullName: "Christian Keur", favoriteColor: .Other("Taupe"))

let data1 = NSKeyedArchiver.archivedData(withRootValue: value1)
let newValue1 = try! NSKeyedUnarchiver.unarchivedRootValue(ofType: Person.self, withData: data1)!
print(newValue1)

let data2 = NSKeyedArchiver.archivedData(withRootValue: value2)
let newValue2 = try! NSKeyedUnarchiver.unarchivedRootValue(ofType: Person.self, withData: data2)!
print(newValue2)
