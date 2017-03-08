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
        return true
    }

    @IBAction private func togglePalette(sender: UISwitch) {
        guard let tabBarController = window?.rootViewController as? AccessoryTabBarController else { return }
        let paletteViewController: UIViewController? = sender.isOn ? tabBarController.storyboard?.instantiateViewController(withIdentifier: "Root:Palette") : nil
        tabBarController.setPaletteViewController(paletteViewController, animated: true)
    }

}
