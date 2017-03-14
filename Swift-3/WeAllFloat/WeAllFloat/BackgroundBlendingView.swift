//
//  BackgroundBlendingView.swift
//  WeAllFloat
//
//  Created by Zachary Waldowski on 3/1/17.
//  Copyright © 2017 Big Nerd Ranch. All rights reserved.
//

import UIKit

final class BackgroundBlendingView: UIView {

    // @c CATransformLayer is documented to never draw. This serves as a
    // performance optimization.
    override final class var layerClass: AnyClass {
        return CATransformLayer.self
    }

    enum BlendMode: String {
        // Porter-Duff compositing operations
        // http://www.w3.org/TR/2014/CR-compositing-1-20140220/#porterduffcompositingoperators
        case clear = "clear"
        case copy = "copy"
        case sourceOver = "sourceOver"
        case sourceIn = "sourceIn"
        case sourceOut = "sourceOut"
        case sourceAtop = "sourceAtop"
        case destination = "dest"
        case destinationOver = "destOver"
        case destinationIn = "destIn"
        case destinationOut = "destOut"
        case destinationAtop = "destAtop"
        case xor = "xor"
        case plusDarker = "plusD"
        case plusLighter = "plusL"

        // Separable blend-modes
        // http://www.w3.org/TR/2014/CR-compositing-1-20140220/#blendingseparable
        case multiply = "multiply"
        case screen = "screenBlendMode"
        case overlay = "overlayBlendMode"
        case darken = "darkenBlendMode"
        case lighten = "lightenBlendMode"
        case colorDodge = "colorDodgeBlendMode"
        case colorBurn = "colorBurnBlendMode"
        case softLight = "softLightBlendMode"
        case hardLight = "hardLightBlendMode"
        case difference = "differenceBlendMode"
        case exclusion = "exclusionBlendMode"
    }

    typealias Filter = (BlendMode, UIColor)

    private let blendingLayers: [CALayer]

    init(filters: Filter...) {
        blendingLayers = filters.map { (filter, color) in
            let sublayer = CALayer()
            sublayer.backgroundColor = color.cgColor
            sublayer.compositingFilter = filter.rawValue
            return sublayer
        }
        super.init(frame: .zero)
        blendingLayers.forEach(layer.addSublayer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    // Overridden to have no effect because the layer is never rendered,
    // otherwise Core Animation will moan in the log
    override open var backgroundColor: UIColor? {
        get {
            return nil
        }
        set {
            // nop
        }
    }

    // See @c backgroundColor
    override open var isOpaque: Bool {
        get {
            return false
        }
        set {
            // nop
        }
    }

    override func layoutSublayers(of layer: CALayer) {
        guard layer === self.layer else { return }
        for sublayer in blendingLayers {
            sublayer.frame = layer.bounds
        }
    }

}
