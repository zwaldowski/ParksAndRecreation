import CoreGraphics

// MARK: Bridged constructors

public extension CGAffineTransform {
    
    init(tx: CGFloat = 0, ty: CGFloat = 0) {
        self = CGAffineTransformMakeTranslation(tx, ty)
    }
    
    init(scale: CGFloat) {
        self = CGAffineTransformMakeScale(scale, scale)
    }
    
    init(sx: CGFloat = 1, sy: CGFloat = 1) {
        self = CGAffineTransformMakeScale(sx, sy)
    }
    
    init(angle: CGFloat) {
        self = CGAffineTransformMakeRotation(angle)
    }
    
}

// MARK: Bridged properties

public extension CGAffineTransform {
    
    static var identity: CGAffineTransform { return CGAffineTransformIdentity }
    
    var isIdentity: Bool {
        return CGAffineTransformIsIdentity(self)
    }
    
    func translated(x x: CGFloat = 0, y: CGFloat = 0) -> CGAffineTransform {
        return CGAffineTransformTranslate(self, x, y)
    }
    
    func scaled(x x: CGFloat = 1, y: CGFloat = 1) -> CGAffineTransform {
        return CGAffineTransformScale(self, x, y)
    }
    
    func scaled(s: CGFloat) -> CGAffineTransform {
        return CGAffineTransformScale(self, s, s)
    }
    
    func rotated(by angle: CGFloat) -> CGAffineTransform {
        return CGAffineTransformRotate(self, angle)
    }
    
    func concatenated(transform: CGAffineTransform) -> CGAffineTransform {
        return CGAffineTransformConcat(self, transform)
    }
    
    var inverted: CGAffineTransform {
        return CGAffineTransformInvert(self)
    }
    
    var integralTransform: CGAffineTransform {
        return CGAffineTransform(a: round(a), b: round(b), c: round(c),
            d: round(d), tx: round(tx), ty: round(ty))
    }
    
}

// MARK: Constructors

public extension CGAffineTransform {
    
    init(_ transforms: CGAffineTransform...) {
        self = transforms.reduce(CGAffineTransform.identity, combine: +)
    }
    
}

// MARK: Printable

extension CGAffineTransform: CustomStringConvertible {
    
    public var description: String {
        return "CGAffineTransform(\(a), \(b), \(c), \(d), \(tx), \(ty))"
    }
    
}

// MARK: Equatable

public func ==(lhs: CGAffineTransform, rhs: CGAffineTransform) -> Bool {
    return CGAffineTransformEqualToTransform(lhs, rhs)
}

extension CGAffineTransform: Equatable { }

// MARK: Vector arithmetic

public prefix func -(t: CGAffineTransform) -> CGAffineTransform {
    return t.inverted
}

public func +(lhs: CGAffineTransform, rhs: CGAffineTransform) -> CGAffineTransform {
    return lhs.concatenated(rhs)
}

public func -(lhs: CGAffineTransform, rhs: CGAffineTransform) -> CGAffineTransform {
    return lhs + -rhs
}

public func +=(inout lhs: CGAffineTransform, rhs: CGAffineTransform) { lhs = lhs + rhs }
public func -=(inout lhs: CGAffineTransform, rhs: CGAffineTransform) { lhs = lhs - rhs }

// MARK: Transform application

public func *(lhs: CGPoint, rhs: CGAffineTransform) -> CGPoint {
    return CGPointApplyAffineTransform(lhs, rhs)
}

public func *(lhs: CGSize, rhs: CGAffineTransform) -> CGSize {
    return CGSizeApplyAffineTransform(lhs, rhs)
}

public func *(lhs: CGRect, rhs: CGAffineTransform) -> CGRect {
    return CGRectApplyAffineTransform(lhs, rhs)
}

public func *= (inout lhs: CGPoint, rhs: CGAffineTransform) { lhs = lhs * rhs }
public func *= (inout lhs: CGSize, rhs: CGAffineTransform) { lhs = lhs * rhs }
public func *= (inout lhs: CGRect, rhs: CGAffineTransform) { lhs = lhs * rhs }
