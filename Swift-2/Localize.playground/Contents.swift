import Foundation

let s1 = NSLocalizedString("test-string", comment: "Description used for the test")
let s2 = localized("test-string", comment: "Description used for the test")
let s3 = localized("test-progress-\(4)-of-\(5)", comment: "Help text used for a positional description")

let s4 = localized("Your \(Int(0).formatted("%zd")) Friends", comment: "Numerical test describing your friends")
let s5 = localized("Your \(Int(1).formatted("%zd")) Friends", comment: "Numerical test describing your friends")
let s6 = localized("Your \(Int(2).formatted("%zd")) Friends", comment: "Numerical test describing your friends")
