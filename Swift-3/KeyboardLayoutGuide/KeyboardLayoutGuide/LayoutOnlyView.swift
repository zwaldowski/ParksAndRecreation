//
//  LayoutOnlyView.swift
//  KeyboardLayoutGuide
//
//  Created by Zachary Waldowski on 5/3/16.
//  Copyright © 2015-2016. Licensed under MIT. Some rights reserved.
//

import UIKit

/// A view to use when not rendering, i.e., for purely composing other views.
class LayoutOnlyView: UIView {

    // @c CATransformLayer is documented to never draw. This serves as a
    // performance optimization.
    override class var layerClass: AnyClass {
        return CATransformLayer.self
    }

    // Overridden to have no effect because the layer is never rendered,
    // otherwise Core Animation will moan in the log
    override var backgroundColor: UIColor? {
        get {
            return nil
        }
        set {
            // nop
        }
    }

    // See @c backgroundColor
    override var isOpaque: Bool {
        get {
            return false
        }
        set {
            // nop
        }
    }

}
