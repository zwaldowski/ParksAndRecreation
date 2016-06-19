import CoreFoundation

extension String {

    public struct SentenceGenerator: GeneratorType {
        private let source: String
        private let tokenizer: CFStringTokenizer

        private init(_ source: String) {
            self.source = source
            self.tokenizer = CFStringTokenizerCreate(nil, source as CFStringRef, CFRange(location: 0, length: source.utf16.count), kCFStringTokenizerUnitSentence, CFLocaleGetSystem())
        }

        public mutating func next() -> Range<String.Index>? {
            var tokenType = CFStringTokenizerTokenType.None
            repeat {
                tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
            } while tokenType == .None && CFStringTokenizerGetCurrentTokenRange(tokenizer).location != kCFNotFound
            return CFStringTokenizerGetCurrentTokenRange(tokenizer).unsafeSameCharactersIn(source)
        }
    }

    public struct Sentences: SequenceType {
        private let source: String

        private init(_ source: String) {
            self.source = source
        }

        public func generate() -> SentenceGenerator {
            return .init(source)
        }
    }

    public var sentences: Sentences {
        return .init(self)
    }

}

extension String.SentenceGenerator: SequenceType {

    public func generate() -> String.SentenceGenerator {
        return .init(source)
    }

    public var substrings: LazyMapSequence<String.SentenceGenerator, String> {
        return lazy.map { self.source[$0] }
    }

}

extension String.Sentences {

    public var substrings: LazyMapSequence<String.Sentences, String> {
        return lazy.map { self.source[$0] }
    }
    
}
