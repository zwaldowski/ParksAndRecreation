//
//  OverrideRootViewController.swift
//  Overrides
//
//  Created by Zachary Waldowski on 10/9/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

import UIKit

class OverrideRootViewController: UIViewController {
    
    func overrideSizeClass(forWidth width: CGFloat) -> UIUserInterfaceSizeClass {
        return width > 666 ? .Regular : .Compact
    }
    
    override func overrideTraitCollectionForChildViewController(childViewController: UIViewController) -> UITraitCollection? {
        let window: UIWindow? = {
            if childViewController.isViewLoaded() {
                return childViewController.view.window
            } else if isViewLoaded() {
                return view.window
            } else if let delegate = UIApplication.sharedApplication().delegate {
                // Ugly workaround: http://stackoverflow.com/questions/28901893/why-is-main-window-of-type-double-optional
                return delegate.window??.`self`()
            }
            return nil
        }()
        
        let width = window?.bounds.width ?? UIScreen.mainScreen().bounds.width
        let horizontalSizeClass = overrideSizeClass(forWidth: width)
        
        if traitCollection.horizontalSizeClass == horizontalSizeClass {
            return traitCollection
        }
        
        return UITraitCollection(traitsFromCollections: [
            traitCollection,
            UITraitCollection(horizontalSizeClass: horizontalSizeClass)
        ])
    }
    
}
