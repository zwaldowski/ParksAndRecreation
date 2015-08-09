import UIKit

// MARK: Geometry

public extension CGRect {
    
    var center: CGPoint {
        get {
            return CGPoint(x: midX, y: midY)
        }
        set {
            origin = CGPoint(x: newValue.x - (width / 2), y: newValue.y - (height / 2))
        }
    }
    
    func rectForEdge(edge: CGRectEdge, thickness thick: CGFloat = 1.0) -> CGRect {
        switch edge {
        case .MinXEdge:
            return CGRect(x: minX, y: minY, width: thick, height: height)
        case .MinYEdge:
            return CGRect(x: minX, y: minY, width: width, height: thick)
        case .MaxXEdge:
            return CGRect(x: maxX - thick, y: minY, width: thick, height: height)
        case .MaxYEdge:
            return CGRect(x: minX, y: maxY - thick, width: width, height: thick)
        }
    }
    
    mutating func divide(atDistance: CGFloat, fromEdge edge: CGRectEdge = .MinYEdge) -> CGRect {
        let (slice, remainder) = rectsByDividing(atDistance, fromEdge: edge)
        self = remainder
        return slice
    }
    
}

// MARK: Integral Repositioning

public extension CGRect {
    
    private func originCentered(aboutPoint mid: CGPoint, centerX: Bool = true, centerY: Bool = true, scale: CGFloat) -> CGPoint {
        return CGPoint(x: centerX ? rround(mid.x - (width / 2), scale: scale) : minX,
            y: centerY ? rround(mid.y - (height / 2), scale: scale) : minY)
    }
    
    func integerRect(scale: CGFloat) -> CGRect {
        if isNull { return self }
        return CGRect(x: rfloor(minX, scale: scale),
                      y: rfloor(minY, scale: scale),
                      width: rceilSmart(maxX, scale: scale) - minX,
                      height: rceilSmart(maxY, scale: scale) - minY)
    }
    
    func rectCentered(inRect bounds: CGRect, scale: CGFloat) -> CGRect {
        return CGRect(origin: originCentered(aboutPoint: bounds.center, scale: scale), size: size)
    }
    
    func rectCentered(xInRect bounds: CGRect, scale: CGFloat) -> CGRect {
        return CGRect(origin: originCentered(aboutPoint: bounds.center, centerY: false, scale: scale), size: size)
    }
    
    func rectCentered(yInRect bounds: CGRect, scale: CGFloat) -> CGRect {
        return CGRect(origin: originCentered(aboutPoint: bounds.center, centerX: false, scale: scale), size: size)
    }
    
    func rectCentered(about point: CGPoint, scale: CGFloat) -> CGRect {
        return CGRect(origin: originCentered(aboutPoint: point, scale: scale), size: size)
    }
    
}

// MARK: On view

public extension UIView {
    
    func integerRect(rect: CGRect) -> CGRect { return rect.integerRect(scale) }
    func rectCentered(rect: CGRect, inRect bounds: CGRect) -> CGRect { return rect.rectCentered(inRect: bounds, scale: scale) }
    func rectCentered(rect: CGRect, xInRect bounds: CGRect) -> CGRect { return rect.rectCentered(xInRect: bounds, scale: scale) }
    func rectCentered(rect: CGRect, yInRect bounds: CGRect) -> CGRect { return rect.rectCentered(yInRect: bounds, scale: scale) }
    func rectCentered(rect: CGRect, about point: CGPoint) -> CGRect { return rect.rectCentered(about: point, scale: scale) }
    
}

public extension UIViewController {
    
    func integerRect(rect: CGRect) -> CGRect { return rect.integerRect(view.scale) }
    func rectCentered(rect: CGRect, inRect bounds: CGRect) -> CGRect { return rect.rectCentered(inRect: bounds, scale: view.scale) }
    func rectCentered(rect: CGRect, xInRect bounds: CGRect) -> CGRect { return rect.rectCentered(xInRect: bounds, scale: view.scale) }
    func rectCentered(rect: CGRect, yInRect bounds: CGRect) -> CGRect { return rect.rectCentered(yInRect: bounds, scale: view.scale) }
    func rectCentered(rect: CGRect, about point: CGPoint) -> CGRect { return rect.rectCentered(about: point, scale: view.scale) }
    
}
