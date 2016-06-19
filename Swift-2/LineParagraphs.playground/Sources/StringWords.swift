import CoreFoundation

extension String {

    public struct WordGenerator: GeneratorType {
        private let source: String
        private let tokenizer: CFStringTokenizer

        private init(_ source: String) {
            self.source = source
            self.tokenizer = CFStringTokenizerCreate(nil, source as CFStringRef, CFRange(location: 0, length: source.utf16.count), kCFStringTokenizerUnitWordBoundary, CFLocaleGetSystem())
        }

        public mutating func next() -> Range<String.Index>? {
            var tokenType = CFStringTokenizerTokenType.None
            repeat {
                tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
            } while (tokenType == .None && CFStringTokenizerGetCurrentTokenRange(tokenizer).location != kCFNotFound) || tokenType.contains(.HasNonLettersMask)
            return CFStringTokenizerGetCurrentTokenRange(tokenizer).unsafeSameCharactersIn(source)
        }
    }

    public struct Words: SequenceType {
        private let source: String

        private init(_ source: String) {
            self.source = source
        }

        public func generate() -> WordGenerator {
            return .init(source)
        }
    }

    public var words: Words {
        return .init(self)
    }

}

extension String.WordGenerator: SequenceType {

    public func generate() -> String.WordGenerator {
        return .init(source)
    }

    public var substrings: LazyMapSequence<String.WordGenerator, String> {
        return lazy.map { self.source[$0] }
    }

}

extension String.Words {

    public var substrings: LazyMapSequence<String.Words, String> {
        return lazy.map { self.source[$0] }
    }
    
}
