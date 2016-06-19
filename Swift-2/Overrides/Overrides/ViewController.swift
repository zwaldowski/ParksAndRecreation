//
//  ViewController.swift
//  Overrides
//
//  Created by Zachary Waldowski on 10/9/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

import UIKit
import Foundation
import Darwin.POSIX.sys.types
import Darwin.sys.sysctl

private extension UIUserInterfaceSizeClass {
    
    var localizedDescription: String {
        switch self {
        case .Unspecified:
            return NSLocalizedString("Unknown", comment: "Description for unknown size class")
        case .Compact:
            return NSLocalizedString("Compact", comment: "Description for compact size class")
        case .Regular:
            return NSLocalizedString("Regular", comment: "Description for regular size class")
        }
    }
    
}

private extension NSRegularExpression {
    
    func matchGroup(forResult result: NSTextCheckingResult, inString string: String, index: Int) -> String {
        return replacementStringForResult(result, inString: string, offset: 0, template: "$\(index)")
    }
    
}

private func getsysctl(byName key: String) throws -> String {
    var size = size_t()
    guard sysctlbyname(key, nil, &size, nil, 0) == 0 else {
        throw POSIXError(rawValue: errno)!
    }
    guard size > 0 else { return "" }

    var array = [CChar](count: Int(size), repeatedValue: 0)
    guard sysctlbyname(key, &array, &size, nil, 0) == 0 else {
        throw POSIXError(rawValue: errno)!
    }
    guard size > 0 else { return "" }

    return String.fromCStringRepairingIllFormedUTF8(&array).0!
}

private struct ModelIdentifier {
    let name: String
    let major: Int
    let minor: Int
    
    static let matcher = try! NSRegularExpression(pattern: "((^[A-Za-z]+)(\\d+),(\\d+)(?:\\D*)$)", options: [])
    
    init?(string: String) {
        let matcher = ModelIdentifier.matcher
        guard let match = matcher.firstMatchInString(string, options: [], range: NSRange(0 ..< string.utf16.count)) else {
            return nil
        }

        name = matcher.matchGroup(forResult: match, inString: string, index: 2)
        
        if let majorInt = Int(matcher.matchGroup(forResult: match, inString: string, index: 3)) {
            major = majorInt
        } else {
            return nil
        }
        
        if let minorInt = Int(matcher.matchGroup(forResult: match, inString: string, index: 4)) {
            minor = minorInt
        } else {
            return nil
        }
    }
}

private extension UIDevice {
    
    var modelIdentifier: ModelIdentifier? {
        if let identifier = try? getsysctl(byName: "hw.machine") {
            return ModelIdentifier(string: identifier)
        }
        return nil
    }
    
    var localizedMarketingName: String {
        guard let model = modelIdentifier else {
            return localizedModel
        }

        let suffix: String
        if model.name == "iPad" {
            switch (model.major, model.minor) {
            case (2, 1), (2, 2), (2, 3), (2, 4): suffix = "2"
            case (3, 1), (3, 2), (3, 3): suffix = "(mid-2013)"
            case (3, 4), (3, 5), (3, 6): suffix = "(late 2013)"
            case (2, 5), (2, 6), (2, 7): suffix = "mini"
            case (4, 1), (4, 2): suffix = "Air"
            case (4, 4), (4, 5): suffix = "mini with Retina Display"
            default: return localizedModel
            }
        } else if model.name == "iPhone" {
            switch (model.major, model.minor) {
            case (3, _): return "4"
            case (4, _): return "4S"
            case (5, 1), (5, 2): return "5"
            case (5, 3), (5, 4): return "5c"
            case (6, _): return "5s"
            case (7, 1): return "6 Plus"
            case (7, 2): return "6"
            default: return localizedModel
            }
        } else if model.name == "iPod" {
            switch (model.major, model.minor) {
            case (5, _): return "(fifth generation)"
            default: return localizedModel
            }
        } else {
            return localizedModel
        }

        return "\(localizedModel) \(suffix)"
    }
}

class DemoViewController: UIViewController {
    @IBOutlet var sizeClassLabel: UILabel!
    @IBOutlet var deviceLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        deviceLabel.text = UIDevice.currentDevice().localizedMarketingName
        sizeClassLabel.text = traitCollection.horizontalSizeClass.localizedDescription
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        sizeClassLabel.text = traitCollection.horizontalSizeClass.localizedDescription
    }

}

