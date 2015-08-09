import UIKit

infix operator ~== { associativity none precedence 130 }
infix operator !~== { associativity none precedence 130 }

public protocol GeometricMeasure: AbsoluteValuable, Comparable {
    init(_: Double)
    func *(lhs: Self, rhs: Self) -> Self
    func /(lhs: Self, rhs: Self) -> Self
    static var identity: Self { get }
    static var accuracy: Self { get }
}

extension Float: GeometricMeasure {
    public static let identity = Float(1)
    public static let accuracy = FLT_EPSILON
}

extension Double: GeometricMeasure {
    public static let identity = Double(1)
    public static let accuracy = DBL_EPSILON
}

extension CGFloat: GeometricMeasure {
    public static var identity: CGFloat { return CGFloat(CGFloat.NativeType.identity) }
    public static var accuracy: CGFloat { return CGFloat(CGFloat.NativeType.accuracy) }
}

// MARK: Approximately Equatable

public func ~==<T: GeometricMeasure>(lhs: T, rhs: T) -> Bool {
    return T.abs(rhs - lhs) <= T.accuracy
}

public func ~== <T: GeometricMeasure>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case (.Some(let lhs), .Some(let rhs)):
        return lhs ~== rhs
    case (.None, .None):
        return true
    case (_, _):
        return false
    }
}

public func !~==<T: GeometricMeasure>(lhs: T, rhs: T) -> Bool {
    return !(lhs ~== rhs)
}

public func !~==<T: GeometricMeasure>(lhs: T?, rhs: T?) -> Bool {
    return !(lhs ~== rhs)
}
