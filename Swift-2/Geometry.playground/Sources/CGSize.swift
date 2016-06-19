import UIKit

// MARK: Printable

extension CGSize: CustomStringConvertible {
    
    public var description: String {
#if os(OSX)
        return NSStringFromSize(self)
#else
        return NSStringFromCGSize(self)
#endif
    }
    
}

// MARK: Vector arithmetic

public func +(lhs: CGSize, rhs: CGSize) -> CGSize {
    return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
}

public func -(lhs: CGSize, rhs: CGSize) -> CGSize {
    return CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
}

public func +=(inout lhs: CGSize, rhs: CGSize) { lhs = lhs + rhs }
public func -=(inout lhs: CGSize, rhs: CGSize) { lhs = lhs - rhs }

// MARK: Scalar arithmetic

public func *(lhs: CGSize, rhs: CGFloat) -> CGSize {
    return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
}

public func /(lhs: CGSize, rhs: CGFloat) -> CGSize {
    return CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
}

public func *= (inout lhs: CGSize, rhs: CGFloat) { lhs = lhs * rhs }
public func /= (inout lhs: CGSize, rhs: CGFloat) { lhs = lhs / rhs }
