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
    @IBOutlet var blueView: UIView!
    @IBOutlet var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let auxiliaryKeyboardLayoutGuide = KeyboardLayoutGuide()
        view.addLayoutGuide(auxiliaryKeyboardLayoutGuide)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: redView, attribute: .bottom, relatedBy: .equal, toItem: keyboardLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: blueView, attribute: .bottom, relatedBy: .equal, toItem: auxiliaryKeyboardLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)
        ])

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        view.endEditing(true)
    }

    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        textField.resignFirstResponder()
    }

}
