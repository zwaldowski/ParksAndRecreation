//
//  ViewController.swift
//  KeyboardLayoutGuide
//
//  Created by Zachary Waldowski on 8/23/15.
//  Copyright © 2015. Licensed under MIT. Some rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var redView: UIView!
    @IBOutlet var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let newGuide = keyboardLayoutGuide.dynamicType.init()
        print(newGuide)
        
        NSLayoutConstraint.activateConstraints([
            redView.bottomAnchor.constraintEqualToAnchor(keyboardLayoutGuide.bottomAnchor)
        ])
    }

    @IBAction func dismissKeyboard(sender: UITapGestureRecognizer) {
        textField.resignFirstResponder()
    }

}
