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
    return String(format: format, arguments: strings.map {
        let ref = Unmanaged.passRetained($0)
        ref.autorelease()
        return ref.toOpaque()
    })
}
