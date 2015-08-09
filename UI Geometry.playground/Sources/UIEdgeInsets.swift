import UIKit.UIGeometry

public extension UIEdgeInsets {
    
    init(width: CGFloat, edges: UIRectEdge = .All) {
        self.init(top: edges.contains(.Top) ? width : 0,
            left: edges.contains(.Left) ? width : 0,
            bottom: edges.contains(.Bottom) ? width : 0,
            right: edges.contains(.Right) ? width : 0)
    }
    
    private func insetsByRemovingEdges(edges: UIRectEdge) -> UIEdgeInsets {
        return UIEdgeInsets(top: edges.contains(.Top) ? 0 : top,
            left: edges.contains(.Left) ? 0 : left,
            bottom: edges.contains(.Bottom) ? 0 : bottom,
            right: edges.contains(.Right) ? 0 : right)
    }
    
    var horizontalInsets: UIEdgeInsets {
        return insetsByRemovingEdges([ .Top, .Bottom ])
    }
    
    var verticalInsets: UIEdgeInsets {
        return insetsByRemovingEdges([ .Left, .Right ])
    }
    
    func insetsByRotating(angleCG: CGFloat) -> UIEdgeInsets {
        let unit = M_PI * 2
        let toUnit = Double(angleCG) % unit
        let angle = toUnit < 0 ? toUnit + unit : toUnit
        if angle ~== M_PI_2 {
            return UIEdgeInsets(top: left, left: bottom, bottom: right, right: top)
        } else if angle ~== M_PI {
            return UIEdgeInsets(top: bottom, left: right, bottom: top, right: left)
        } else if angle ~== 3 * M_PI_2 {
            return UIEdgeInsets(top: right, left: top, bottom: left, right: bottom)
        }
        return self
    }
    
}
