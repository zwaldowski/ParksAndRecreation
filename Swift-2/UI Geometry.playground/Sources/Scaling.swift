import UIKit

private func rroundBy<T: GeometricMeasure>(value: T, _ scale: T = T.identity, _ function: T -> T) -> T {
    return (scale > T.identity) ? (function(value * scale) / scale) : function(value)
}

public func rround(value: CGFloat, scale: CGFloat = CGFloat.identity) -> CGFloat { return rroundBy(value, scale, round) }
public func rceil(value: CGFloat, scale: CGFloat = CGFloat.identity) -> CGFloat { return rroundBy(value, scale, ceil) }
public func rfloor(value: CGFloat, scale: CGFloat = CGFloat.identity) -> CGFloat { return rroundBy(value, scale, floor) }

func rceilSmart(value: CGFloat, scale: CGFloat = CGFloat.identity) -> CGFloat {
    return rroundBy(value, scale) { v in
        let vFloor = floor(v)
        if vFloor ~== v { return vFloor }
        return ceil(v)
    }
}

public extension UIView {
    
    func rround(value: CGFloat) -> CGFloat { return rroundBy(value, scale, round) }
    func rceil(value: CGFloat) -> CGFloat { return rroundBy(value, scale, ceil) }
    func rfloor(value: CGFloat) -> CGFloat { return rroundBy(value, scale, floor) }
    
}

public extension UIViewController {
    
    func rround(value: CGFloat) -> CGFloat { return rroundBy(value, view.scale, round) }
    func rceil(value: CGFloat) -> CGFloat { return rroundBy(value, view.scale, ceil) }
    func rfloor(value: CGFloat) -> CGFloat { return rroundBy(value, view.scale, floor) }
    
}

// MARK: Rotations

public func toRadians<T: GeometricMeasure>(value: T) -> T {
    return (value * T(M_PI)) / T(180.0)
}

public func toDegrees<T: GeometricMeasure>(value: T) -> T {
    return ((value * T(180.0)) / T(M_PI))
}
