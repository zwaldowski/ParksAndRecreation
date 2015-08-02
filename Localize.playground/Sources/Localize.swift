import Foundation

private typealias LocalizationSegment = (String, [NSString])

private func +(lhs: LocalizationSegment, rhs: LocalizationSegment) -> LocalizationSegment {
    return (lhs.0 + rhs.0, lhs.1 + rhs.1)
}

private func +(lhs: LocalizationSegment, rhs: LocalizableText) -> LocalizationSegment {
    return lhs + rhs.localizationSegments
}

private extension LocalizableText {
    
    private var localizationSegments: LocalizationSegment {
        switch self {
        case .Tree(let segments):
            return segments.reduce(("", []), combine: +)
        case .Segment(let element):
            return (element, [])
        case .Expression(let value):
            return ("%@", [ value ])
        }
    }
    
}

public func localize(text: LocalizableText, tableName: String? = nil, bundle: NSBundle = NSBundle.mainBundle(), value: String = "", comment: String) -> String {
    let (key, strings) = text.localizationSegments
    let format = bundle.localizedStringForKey(key, value: value, table: tableName)
    guard !strings.isEmpty else { return format }
    
    let args = strings.map {
        Unmanaged.passRetained($0).toOpaque()
        } as [CVarArgType]
    let formatted = String(format: format, arguments: args)
    for ptr in args {
        Unmanaged<NSString>.fromOpaque(ptr as! COpaquePointer).release()
    }
    return formatted
}
