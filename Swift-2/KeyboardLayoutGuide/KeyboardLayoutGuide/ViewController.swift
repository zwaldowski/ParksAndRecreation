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
        
        NSLayoutConstraint.activateConstraints([
            NSLayoutConstraint(item: redView, attribute: .Bottom, relatedBy: .Equal, toItem: keyboardLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0)
        ])
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        view.endEditing(true)
    }

    @IBAction func dismissKeyboard(sender: UITapGestureRecognizer) {
        textField.resignFirstResponder()
    }

}
