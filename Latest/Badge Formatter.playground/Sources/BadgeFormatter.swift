import Foundation

public final class BadgeFormatter: Formatter {

    private let suffix: String

    public enum Style {
        case outlinedSquare
        case outlinedRound
        case filledSquare
        case filledRound
    }

    public init(style: Style) {
        switch style {
        case .outlinedSquare:
            self.suffix = "\u{20dd}"
        case .outlinedRound:
            self.suffix = "\u{20de}"
        case .filledSquare:
            self.suffix = "\u{20dd}\u{25cf}"
        case .filledRound:
            self.suffix = "\u{20de}\u{25a0}"
        }
        super.init()
    }

    public required init?(coder: NSCoder) {
        guard let suffix = coder.decodeObject(of: NSString.self, forKey: "suffix") as String? else { return nil }
        self.suffix = suffix
        super.init(coder: coder)
    }

    override public func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(suffix, forKey: "suffix")
    }

    public func string<Number: SignedNumeric & Comparable>(for number: Number) -> String {
        if number < 0 {
            return "\u{2212}\(suffix)"
        } else if number >= 10 {
            return "+\(suffix)"
        } else {
            return "\(number)\(suffix)"
        }
    }

    public func string(for number: NSNumber) -> String {
        return string(for: Int(truncating: number))
    }

    private static let allowedCharacters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!+<=>?\u{00D7}\u{00F7}\u{2212}\u{25b2}\u{25b6}\u{25bc}\u{25c0}\u{2713}\u{2717}")

    public func string(for character: Character) -> String {
        guard let scalar = character.unicodeScalars.first,
            BadgeFormatter.allowedCharacters.contains(scalar) else { return String(character) }
        return "\(scalar)\(suffix)"
    }

    override public func string(for obj: Any?) -> String? {
        switch obj {
        case let number as Int:
            return string(for: number)
        case let number as Double:
            return string(for: number)
        case let character as Character:
            return string(for: character)
        case let string as String:
            return string.first.map(self.string)
        case let scalar as UnicodeScalar:
            return string(for: Character(scalar))
        default:
            return nil
        }
    }

    public var checkmark: String { return "\u{2713}\(suffix)" }
    public var crossmark: String { return "\u{2717}\(suffix)" }
    public var upArrow: String { return "\u{25b2}\(suffix)" }
    public var rightArrow: String { return "\u{25b6}\(suffix)" }
    public var downArrow: String { return "\u{25bc}\(suffix)" }
    public var leftArrow: String { return "\u{25c0}\(suffix)" }

}
