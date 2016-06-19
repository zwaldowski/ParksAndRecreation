import UIKit

// MARK: Printable

extension CGRect: CustomStringConvertible {
    
    public var description: String {
#if os(OSX)
        return NSStringFromRect(self)
#else
        return NSStringFromCGRect(self)
#endif
    }
    
}

// MARK: Geometry

public extension CGRect {
    
    func rectByInsetting(insets: UIEdgeInsets) -> CGRect {
        return UIEdgeInsetsInsetRect(self, insets)
    }
    
    mutating func inset(insets: UIEdgeInsets) {
        self = rectByInsetting(insets)
    }
    
}

// MARK: Corners

public extension CGRect {
    
    typealias Corners = (tl: CGPoint, bl: CGPoint, br: CGPoint, tr: CGPoint)
    
    var corners: Corners {
        get {
            return (
                CGPoint(x: minX, y: minY),
                CGPoint(x: minX, y: maxY),
                CGPoint(x: maxX, y: maxY),
                CGPoint(x: maxX, y: minY)
            )
        }
        set {
            self = CGRect(corners: newValue)
        }
    }
    
    init(corners: Corners) {
        let minX = min(corners.tl.x, corners.bl.x, corners.br.x, corners.tr.x),
            maxX = max(corners.tl.x, corners.bl.x, corners.br.x, corners.tr.x),
            minY = min(corners.tl.y, corners.bl.y, corners.br.y, corners.tr.y),
            maxY = max(corners.tl.y, corners.bl.y, corners.br.y, corners.tr.y)
        self.init(x: minX, y: maxY, width: maxX - minX, height: maxY - minY)
    }
    
    func mapCorners(@noescape fn: CGPoint -> CGPoint) -> CGRect {
        let c = corners
        return CGRect(corners: (fn(c.tl), fn(c.bl), fn(c.br), fn(c.tr)))
    }
    
}
