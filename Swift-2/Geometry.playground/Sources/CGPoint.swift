import UIKit

// MARK: Printable

extension CGPoint: CustomStringConvertible {
    
    public var description: String {
#if os(OSX)
        return NSStringFromPoint(self)
#else
        return NSStringFromCGPoint(self)
#endif
    }
    
}

// MARK: Vector arithmetic

public prefix func -(p: CGPoint) -> CGPoint {
    return CGPoint(x: -p.x, y: -p.y)
}

public func +(lhs:CGPoint, rhs:CGPoint) -> CGPoint {
    return CGPoint(x:lhs.x + rhs.x, y:lhs.y + rhs.y)
}

public func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return lhs + -rhs
}

public func +=(inout lhs: CGPoint, rhs: CGPoint) { lhs = lhs + rhs }
public func -=(inout lhs: CGPoint, rhs: CGPoint) { lhs = lhs - rhs }

public func *(lhs: CGPoint, rhs: CGPoint) -> CGFloat {
    return (lhs.x * rhs.x) + (lhs.y * rhs.y)
}

public func /(lhs: CGPoint, rhs: CGPoint) -> CGFloat {
    return (lhs.x * rhs.x) - (lhs.y * rhs.y)
}

// MARK: Scalar arithmetic

public func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
}

public func /(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
}

public func *= (inout lhs:CGPoint, rhs:CGFloat) { lhs = lhs * rhs }
public func /= (inout lhs:CGPoint, rhs:CGFloat) { lhs = lhs / rhs }

// MARK: Trigonometry

public func ...(a: CGPoint, b: CGPoint) -> CGFloat {
    let distance = a - b
    return sqrt(distance * distance)
}

public extension CGPoint {
    
    public func midpoint(other: CGPoint) -> CGPoint {
        return CGPoint(x: (x + other.x) / 2, y: (y + other.y) / 2)
    }
    
}
