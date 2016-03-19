import QuartzCore

// MARK: Bridged initializers

public extension CATransform3D {
    
    init(_ transform: CGAffineTransform) {
        self = CATransform3DMakeAffineTransform(transform)
    }
    
    init(tx: CGFloat = 0, ty: CGFloat = 0, tz: CGFloat = 0) {
        self = CATransform3DMakeTranslation(tx, ty, tz)
    }
    
    init(scale: CGFloat) {
        self = CATransform3DMakeScale(scale, scale, scale)
    }
    
    init(sx: CGFloat = 1, sy: CGFloat = 1, sz: CGFloat = 1) {
        self = CATransform3DMakeScale(sx, sy, sz)
    }
    
    init(angle: CGFloat, x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0) {
        self = CATransform3DMakeRotation(angle, x, y, z)
    }
    
}

// MARK: Bridged properties

public extension CATransform3D {
    
    static var identity: CATransform3D { return CATransform3DIdentity }
    
    var isIdentity: Bool {
        return CATransform3DIsIdentity(self)
    }
    
    var affineTransform: CGAffineTransform? {
        if !CATransform3DIsAffine(self) { return nil }
        return CATransform3DGetAffineTransform(self)
    }
    
}

// MARK: Constructors

public extension CATransform3D {
    
    init<Sequence: SequenceType where Sequence.Generator.Element == CATransform3D>(transforms: Sequence) {
        self = transforms.reduce(CATransform3D.identity, combine: +)
    }
    
    init<Sequence: SequenceType where Sequence.Generator.Element == CGAffineTransform>(transforms: Sequence) {
        self.init(transforms: transforms.lazy.map(CATransform3D.init))
    }
    
    init(_ transforms: CATransform3D...) {
        self.init(transforms: transforms)
    }
    
    init(_ transforms: CGAffineTransform...) {
        self.init(transforms: transforms)
    }
    
}

// MARK: Transformations

public extension CATransform3D {
    
    func translated(x x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0) -> CATransform3D {
        return CATransform3DTranslate(self, x, y, z)
    }
    
    func scaled(x x: CGFloat = 1, y: CGFloat = 1, z: CGFloat = 1) -> CATransform3D {
        return CATransform3DScale(self, x, y, z)
    }
    
    func scaled(s: CGFloat) -> CATransform3D {
        return CATransform3DScale(self, s, s, s)
    }
    
    func rotated(by angle: CGFloat, x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0) -> CATransform3D {
        return CATransform3DRotate(self, angle, x, y, z)
    }
    
    func concatenated(transform: CATransform3D) -> CATransform3D {
        return CATransform3DConcat(self, transform)
    }
    
    var inverted: CATransform3D {
        return CATransform3DInvert(self)
    }
    
}

// MARK: Printable

extension CATransform3D: CustomStringConvertible {
    
    public var description: String {
        return "CATransform3D(\(m11), \(m12), \(m13), \(m14), \(m21), \(m22), \(m23), \(m24), \(m31), \(m32), \(m33), \(m34), \(m41), \(m42), \(m43), \(m44))"
    }
    
}

// MARK: Equatable

public func ==(lhs: CATransform3D, rhs: CATransform3D) -> Bool {
    return CATransform3DEqualToTransform(lhs, rhs)
}

extension CATransform3D: Equatable { }

// MARK: Vector arithmetic

public prefix func -(t: CATransform3D) -> CATransform3D {
    return t.inverted
}

public func +(lhs: CATransform3D, rhs: CATransform3D) -> CATransform3D {
    return lhs.concatenated(rhs)
}

public func -(lhs: CATransform3D, rhs: CATransform3D) -> CATransform3D {
    return lhs + -rhs
}

public func +(lhs: CGAffineTransform, rhs: CATransform3D) -> CATransform3D {
    return CATransform3D(lhs) + rhs
}

public func -(lhs: CGAffineTransform, rhs: CATransform3D) -> CATransform3D {
    return CATransform3D(lhs) - rhs
}

public func +(lhs: CATransform3D, rhs: CGAffineTransform) -> CATransform3D {
    return lhs + CATransform3D(rhs)
}

public func -(lhs: CATransform3D, rhs: CGAffineTransform) -> CATransform3D {
    return lhs - CATransform3D(lhs)
}

public func += (inout lhs: CATransform3D, rhs: CATransform3D) { lhs = lhs + rhs }
public func += (inout lhs: CATransform3D, rhs: CGAffineTransform) { lhs = lhs + rhs }
public func -= (inout lhs: CATransform3D, rhs: CATransform3D) { lhs = lhs - rhs }
public func -= (inout lhs: CATransform3D, rhs: CGAffineTransform) { lhs = lhs - rhs }
