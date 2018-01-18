import Foundation

public struct StringSentencesView {

    fileprivate let base: String
    fileprivate let tokenizer: CFStringTokenizer

    fileprivate init(_ base: String) {
        self.base = base
        self.tokenizer = CFStringTokenizerCreate(nil, base as CFString, CFRange(location: 0, length: base.utf16.count), kCFStringTokenizerUnitSentence, CFLocaleGetSystem())
    }

}

extension StringSentencesView: Sequence, IteratorProtocol {

    public mutating func next() -> Substring? {
        var tokenType = CFStringTokenizerTokenType()
        var cfRange = CFRange(location: kCFNotFound, length: 0)
        repeat {
            tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
            cfRange = CFStringTokenizerGetCurrentTokenRange(tokenizer)
        } while tokenType.isEmpty && cfRange.location != kCFNotFound
        guard cfRange.location != kCFNotFound,
            let range = Range<String.Index>(NSRange(location: cfRange.location, length: cfRange.length), in: base) else { return nil }
        return base[range]
    }

}

public struct StringWordsView {

    fileprivate let base: String
    fileprivate let tokenizer: CFStringTokenizer

    fileprivate init(_ base: String) {
        self.base = base
        self.tokenizer = CFStringTokenizerCreate(nil, base as CFString, CFRange(location: 0, length: base.utf16.count), kCFStringTokenizerUnitWordBoundary, CFLocaleGetSystem())
    }

}

extension StringWordsView: Sequence, IteratorProtocol {

    public mutating func next() -> Substring? {
        var tokenType = CFStringTokenizerTokenType()
        var cfRange = CFRange(location: kCFNotFound, length: 0)
        repeat {
            tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
            cfRange = CFStringTokenizerGetCurrentTokenRange(tokenizer)
        } while (tokenType.isEmpty && cfRange.location != kCFNotFound) || tokenType.contains(.hasNonLettersMask)
        guard cfRange.location != kCFNotFound,
            let range = Range<String.Index>(NSRange(location: cfRange.location, length: cfRange.length), in: base) else { return nil }
        return base[range]
    }

}

extension String {

    public typealias SentencesView = StringSentencesView

    public var sentences: StringSentencesView {
        return StringSentencesView(self)
    }

    public typealias WordsView = StringWordsView

    public var words: StringWordsView {
        return StringWordsView(self)
    }

}
