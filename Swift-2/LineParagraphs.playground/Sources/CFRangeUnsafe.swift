import CoreFoundation

extension CFRange {

    func unsafeSameCharactersIn(source: String) -> Range<String.Index>? {
        guard location != kCFNotFound else { return nil }

        let utfStart = String.UTF16Index(_offset: location)
        let utfEnd = String.UTF16Index(_offset: location + length)

        guard let start = utfStart.samePositionIn(source),
            end = utfEnd.samePositionIn(source) else { return nil }

        return start..<end
    }

}
