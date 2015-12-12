import UIKit

public struct RecursingGenerator<Element>: GeneratorType {

    public typealias More = Element -> [Element]?
    private var head: Element?
    private var remaining = ContiguousArray<Element>()
    private var more: More

    public init(firstElement head: Element, moreElements more: More) {
        self.head = head
        self.more = more
    }

    public mutating func next() -> Element? {
        let next = head

        if let nextValues = next.flatMap(more) where !nextValues.isEmpty {
            remaining.appendContentsOf(nextValues)
        }

        head = remaining.isEmpty ? nil : remaining.removeFirst()

        return next
    }

}

extension UIView {

    var allSubviews: AnySequence<UIView> {
        return AnySequence {
            RecursingGenerator(firstElement: self) { view in
                view.subviews
            }
        }
    }

}

extension UIViewController {

    var allViewControllers: AnySequence<UIViewController> {
        return AnySequence {
            RecursingGenerator(firstElement: self) { vc in
                if let presented = vc.presentedViewController {
                    return [ presented ] + vc.childViewControllers
                } else {
                    return vc.childViewControllers
                }
            }
        }
    }

}

extension CALayer {

    var allSublayers: AnySequence<CALayer> {
        return AnySequence {
            RecursingGenerator(firstElement: self) { layer in
                layer.sublayers
            }
        }
    }

}

let v = UIView()
Array(v.allSubviews)

let v2 = UIView()
let vs1 = UIView()
let vs2 = UIView()
let vs3 = UIView()
let vc1 = UIView()
vs3.addSubview(vc1)
v2.addSubview(vs1)
v2.addSubview(vs2)
v2.addSubview(vs3)
Array(v2.allSubviews)
