//
//  PaletteViewController.swift
//  WeAllFloat
//
//  Created by Zachary Waldowski on 2/26/17.
//  Copyright © 2017 Big Nerd Ranch. All rights reserved.
//

import UIKit

final class PaletteViewController: UIViewController {

    @IBOutlet private var heightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.translatesAutoresizingMaskIntoConstraints = false

        print("Palette view did load")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("Palette view will appear")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        print("Palette view did appear")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        print("Palette view will disappear")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        print("Palette view did disappear")
    }

    @IBAction func shrink(_ sender: UIButton) {
        setPreferredHeightAnimated(32) { _ in
            sender.isEnabled = false
        }
    }

    private func setPreferredHeightAnimated(_ height: CGFloat, completion: ((Bool) -> Void)?) {
        heightConstraint.constant = 32

        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0, options: .beginFromCurrentState, animations: view.layoutIfNeeded, completion: completion)
    }

}

private extension PaletteViewController {

    @IBAction func unwindFromExpandedPalette(sender: UIStoryboardSegue) {}

}
