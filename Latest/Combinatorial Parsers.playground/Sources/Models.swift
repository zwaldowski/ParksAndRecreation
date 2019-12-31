public enum Currency {
    case eur, gbp, usd
}

extension Currency: CustomDebugStringConvertible {

    public var debugDescription: String {
        switch self {
        case .eur:
            return "€"
        case .gbp:
            return "£"
        case .usd:
            return "$"
        }
    }

}


public struct Money {

    public var currency: Currency
    public var value: Double

    public init(currency: Currency, value: Double) {
        self.currency = currency
        self.value = value
    }

}

extension Money: CustomDebugStringConvertible {

    public var debugDescription: String {
        return "\(currency)\(value)"
    }

}

// 40.446° N, 79.982° W
public struct Coordinate {

    public var latitude: Double
    public var longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

}

public enum Location {

    case nyc, berlin, london

}

public struct Race {

    public var location: Location
    public var entranceFee: Money
    public var path: [Coordinate]

    public init(location: Location, entranceFee: Money, path: [Coordinate]) {
        self.location = location
        self.entranceFee = entranceFee
        self.path = path
    }

}
