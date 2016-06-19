//: ## Geometry Extensions

import UIKit
import XCPlayground

let demoView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 100))
demoView.translatesAutoresizingMaskIntoConstraints = false
demoView.backgroundColor = UIColor.redColor()

let angle = CGFloat(M_PI_2) // toRadians(90)

//: ### `CATransform3D`
//:
//: Initializers
CATransform3D(tx: 12)
CATransform3D(sx: 1.5, sy: 1.5)
CATransform3D(scale: 1.5)
CATransform3D(angle: angle, x: 12, y: 0, z: 0)
CATransform3D(CATransform3D(scale: 2), CATransform3D(ty: 12))
CATransform3D(CGAffineTransform(scale: 2), CGAffineTransform(ty: 12))

//: Properties
CATransform3D.identity.isIdentity
CATransform3D(sx: 1.5, sy: 1.5, sz: 1).affineTransform

//: Transformations and Equatable
CATransform3D.identity.translated(x: 12) == CATransform3D(tx: 12)
CATransform3D.identity.scaled(1.5) == CATransform3D(scale: 1.5)
CATransform3D.identity.rotated(by: CGFloat(M_PI_2), x: 24, y: 0, z: 0) == CATransform3D(angle: CGFloat(M_PI_2), x: 24, y: 0, z: 0)

//: Arithmetic
-CATransform3D(scale: 2) == CATransform3D(scale: 0.5)
let add1 = CATransform3D(tx: 12) + CATransform3D(scale: 2)
let subtract1 = CATransform3D(tx: 12) - CATransform3D(scale: 2)
let add2 = CATransform3D(tx: 12) + CGAffineTransform(scale: 2)

//: ### `CGAffineTransform`
//:
//: Initializers
let baseTransform1 = CGAffineTransform(scale: 2)
let baseTransform2 = CGAffineTransform(tx: 12)
let baseTransform3 = CGAffineTransform(sx: 1.5)
CGAffineTransform(baseTransform1, baseTransform2)

//: Printing
String(baseTransform1)

//: Properties
CGAffineTransform.identity.isIdentity

//: Transformations and Equatable
CGAffineTransform.identity.translated(x: 12) == CGAffineTransform(tx: 12)
CGAffineTransform.identity.scaled(1.5) == CGAffineTransform(scale: 1.5)
CGAffineTransform.identity.rotated(by: angle) == CGAffineTransform(scale: angle)

//: Arithmetic
-CGAffineTransform(scale: 2) == CGAffineTransform(scale: 0.5)
CGAffineTransform(tx: 12) + CGAffineTransform(scale: 2)
CGAffineTransform(tx: 12) - CGAffineTransform(scale: 2)

//: Application
let applyTransform = CGAffineTransform(scale: 2)
CGRect(x: 12, y: 12, width: 24, height: 48) * applyTransform
CGPoint(x: 12, y: 12) * applyTransform
CGSize(width: 24, height: 48) * applyTransform

//: ### `CGPoint`

let basePoint = CGPoint(x: 16, y: 24)
let altPoint = CGPoint(x: 24, y: 16)

//: Printing
String(basePoint)

//: Vector arithmetic
basePoint + altPoint
basePoint - altPoint
basePoint + altPoint
basePoint - altPoint

//: Scalar arithmetic
basePoint * 2
basePoint / 2

//: Trigonometry
basePoint...altPoint
basePoint.midpoint(altPoint)

//: ### CGRect

let baseRect = CGRect(x: 32, y: 32, width: 512, height: 128)

//: Printing
String(baseRect)

//: Rect insetting
let insetRect = demoView.frame.rectByInsetting(UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12))

//: Corner manipulations
let corners = baseRect.corners
let rectWithCorners = CGRect(corners: corners)
let newRect = baseRect.mapCorners { $0 + CGPoint(x: 12, y: 12) }

//: ### `CGSize`

let baseSize = CGSize(width: 48, height: 96)
let altSize = CGSize(width: 96, height: 48)

//: Printing
String(baseSize)

//: Vector arithmetic
baseSize + altSize
baseSize - altSize
baseSize + altSize
baseSize - altSize

//: Scalar arithmetic
baseSize * 2
baseSize / 2

//: ### `UIEdgeInsets`
//:
//: Extrema
let leftInsets = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
let rightInsets = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
min(leftInsets, rightInsets)
max(leftInsets, rightInsets)
min(leftInsets, rightInsets, edges: .Top)
max(leftInsets, rightInsets, edges: .Top)

//: Rect insetting
let inset1 = baseRect.rectByInsetting(UIEdgeInsets(top: 2, left: 2, bottom: 4, right: 4))
