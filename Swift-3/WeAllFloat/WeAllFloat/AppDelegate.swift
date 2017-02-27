//
//  AppDelegate.swift
//  WeAllFloat
//
//  Created by Zachary Waldowski on 2/23/17.
//  Copyright © 2017 Big Nerd Ranch. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        if let tabBarController = window?.rootViewController as? AccessoryTabBarController {
            tabBarController.setPaletteViewController(tabBarController.storyboard?.instantiateViewController(withIdentifier: "Root:Palette"), animated: false)
        }

        return true
    }

}
