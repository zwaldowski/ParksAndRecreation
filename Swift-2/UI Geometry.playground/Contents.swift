//: ## Geometry Extensions

import UIKit
import XCPlayground

let demoView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 100))
demoView.translatesAutoresizingMaskIntoConstraints = false
demoView.backgroundColor = UIColor.redColor()

//: ### CGRect

let baseRect = CGRect(x: 32, y: 32, width: 512, height: 128)

//: Geometry
baseRect.center

//: Separator rect: get a hairline for a given rect edge
let separatorRect1 = baseRect.rectForEdge(.MinXEdge)
let separatorRect2 = baseRect.rectForEdge(.MinYEdge)
let separatorRect3 = baseRect.rectForEdge(.MaxXEdge)
let separatorRect4 = baseRect.rectForEdge(.MaxYEdge)
let separatorRect5 = baseRect.rectForEdge(.MaxYEdge, thickness: demoView.hairline)

//: Mutating version of rect divide (for iterative processes)
var dividingRect = baseRect
let slice1 = dividingRect.dividing(atDistance: 24, fromEdge: .MinYEdge)
let slice2 = dividingRect.dividing(atDistance: 24, fromEdge: .MinYEdge)
let slice3 = dividingRect.dividing(atDistance: 24, fromEdge: .MinYEdge)
let slice4 = dividingRect.dividing(atDistance: 24, fromEdge: .MinYEdge)
let slice5 = dividingRect.dividing(atDistance: 24, fromEdge: .MinYEdge)
let slice6 = dividingRect.dividing(atDistance: 24, fromEdge: .MinYEdge)
dividingRect

//: Integration
let toCenterIn = CGRect(x: 25, y: 25, width: 75, height: 75)
let fiddlyRect = CGRect(x: 12.5, y: 19, width: 14.25, height: 11)

fiddlyRect.integerRect(1)
fiddlyRect.integerRect(2)
fiddlyRect.rectCentered(inRect: toCenterIn, scale: 2)
fiddlyRect.rectCentered(xInRect: toCenterIn, scale: 2)
fiddlyRect.rectCentered(yInRect: toCenterIn, scale: 2)
fiddlyRect.rectCentered(about: fiddlyRect.origin, scale: 2)

//: ### Geometric scaling
//:
//: Though Swift has more robust operators and methods for UIKit geometry, there
//: are problems it still doesn't solve.
//:
//: Scale geometric values for use with screen display
let rounded1 = demoView.rround(1.5)
let rounded2 = demoView.rround(4/3)
let rounded3 = demoView.rround(1.75)

//: ### Comparison utilities
//: Approximately compare geometric values to compensate for floating point error
1.9999999999999999 ~== 2.0

//: Degree/radian conversion
toRadians(-90) ~== -M_PI_2
toRadians(90) ~== M_PI_2
toRadians(180) ~== M_PI
toRadians(270) ~== 3 * M_PI_2
toRadians(360) ~== 2 * M_PI
toRadians(450) ~== 5 * M_PI_2

toDegrees(M_PI_2)
toDegrees(M_PI)
toDegrees(M_PI_2 * 3)

//: ### `UIEdgeInsets`
//:
//: Initializer with common edges
let insets1 = UIEdgeInsets(width: 22, edges: .Top)

//: Edge removal
let insets2 = UIEdgeInsets(width: 12)
let insets3 = insets2.horizontalInsets
let insets4 = insets2.verticalInsets

//: Cardinal rotation
let toBeRotatedInsets = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
let rotatedInsets1 = toBeRotatedInsets.insetsByRotating(toRadians(-90))
let rotatedInsets2 = toBeRotatedInsets.insetsByRotating(toRadians(0))
let rotatedInsets3 = toBeRotatedInsets.insetsByRotating(toRadians(90))
let rotatedInsets4 = toBeRotatedInsets.insetsByRotating(toRadians(180))
let rotatedInsets5 = toBeRotatedInsets.insetsByRotating(toRadians(270))
let rotatedInsets6 = toBeRotatedInsets.insetsByRotating(toRadians(360))
let rotatedInsets7 = toBeRotatedInsets.insetsByRotating(toRadians(450))

//: ### `UIUserInterfaceLayoutDirection`
//:
//: Extension-safe API of `UIApplication`
UIUserInterfaceLayoutDirection.standardUserInterfaceLayoutDirection

//: ### `UIView`
//:
//: Scale of the window the view is in (always 1 when not in "Full Simulator")
demoView.scale
//:
//: Uses `scale` to determine a good thickness for a content separator
demoView.hairline
