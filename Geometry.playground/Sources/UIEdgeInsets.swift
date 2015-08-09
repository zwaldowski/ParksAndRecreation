import UIKit.UIGeometry

extension UIEdgeInsets: CustomStringConvertible {
    
    public var description: String {
        return NSStringFromUIEdgeInsets(self)
    }
    
}

public func min(lhs: UIEdgeInsets, _ rhs: UIEdgeInsets, edges: UIRectEdge = .All) -> UIEdgeInsets {
    return UIEdgeInsets(top: edges.contains(.Top) ? min(lhs.top, rhs.top) : lhs.top,
        left: edges.contains(.Left) ? min(lhs.left, rhs.left) : lhs.left,
        bottom: edges.contains(.Bottom) ? min(lhs.bottom, rhs.bottom) : lhs.bottom,
        right: edges.contains(.Right) ? min(lhs.right, rhs.right) : lhs.right)
}

public func max(lhs: UIEdgeInsets, _ rhs: UIEdgeInsets, edges: UIRectEdge = .All) -> UIEdgeInsets {
    return UIEdgeInsets(top: edges.contains(.Top) ? max(lhs.top, rhs.top) : lhs.top,
        left: edges.contains(.Left) ? max(lhs.left, rhs.left) : lhs.left,
        bottom: edges.contains(.Bottom) ? max(lhs.bottom, rhs.bottom) : lhs.bottom,
        right: edges.contains(.Right) ? max(lhs.right, rhs.right) : lhs.right)
}

public func clamp(value: UIEdgeInsets, lower: UIEdgeInsets, upper: UIEdgeInsets, edges: UIRectEdge = .All) -> UIEdgeInsets {
    return max(min(value, upper, edges: edges), lower, edges: edges)
}
