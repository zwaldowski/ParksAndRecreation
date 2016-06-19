import UIKit
import Swift

// MARK: Assertions

func assertMainThread(file: StaticString = __FILE__, line: UInt = __LINE__) {
    assert(NSThread.isMainThread(), "This code must be called on the main thread.", file: file, line: line)
}

// MARK: Version Checking

public struct Version {
    public static let isiOS9 = floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_8_3
    public static let isiOS8 = floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1 && !isiOS9
    public static let isiOS7 = floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1 && !isiOS8
}
