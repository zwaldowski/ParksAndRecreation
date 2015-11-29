//
//  NSRegularExpression.swift
//
//  Created by Zachary Waldowski on 7/16/15.
//  Copyright (c) 2015 Big Nerd Ranch. Some rights reserved. Licensed under MIT.
//

import Foundation

public struct MatchGroup: CustomReflectable, CustomStringConvertible, CustomDebugStringConvertible {
    
    private let result: NSTextCheckingResult
    private let string: String
    
    private init(result: NSTextCheckingResult, within characters: String) {
        self.result = result
        self.string = characters
    }
    
    public var range: Range<String.Index> {
        // From NSRegularExpression: "A result must have at least one range, but
        // may optionally have more (for example, to represent capture groups).
        // The range at index 0 always matches the range property."
        return result.range.sameRangeIn(string)!
    }
    
    public var substring: String {
        return string[range]
    }
    
    public var ranges: LazyMapCollection<Range<Int>, Range<String.Index>?> {
        return (1 ..< result.numberOfRanges).lazy.map { [result, string] in
            let range = result.rangeAtIndex($0.successor())
            return range.sameRangeIn(string)
        }
    }
    
    public var substrings: LazyMapCollection<Range<Int>, String?> {
        return (1 ..< result.numberOfRanges).lazy.map { [result, string] in
            let range = result.rangeAtIndex($0.successor())
            return range.sameRangeIn(string).map { string[$0] }
        }
    }
    
    public var description: String {
        return "range: \(range), substring: \"\(substring)\""
    }
    
    public var debugDescription: String {
        return String(result)
    }
    
    public func customMirror() -> Mirror {
        return Mirror(self, children: [
            "range": String(range),
            "substring": substring
        ], displayStyle: .Struct, ancestorRepresentation: .Suppressed)
    }
    
}

public extension NSRegularExpression {
    
    private func searchRange(range: Range<String.Index>?, within characters: String) -> NSRange {
        return range.map {
            NSRange($0, within: characters)
        } ?? NSRange(location: 0, length: characters.utf16.count)
    }
    
    func firstMatch(within string: String, options: NSMatchingOptions = [], range: Range<String.Index>? = nil) -> MatchGroup? {
        return firstMatchInString(string, options: options, range: searchRange(range, within: string)).map {
            MatchGroup(result: $0, within: string)
        }
    }
    
    func numberOfMatches(within string: String, options: NSMatchingOptions = [], range: Range<String.Index>? = nil) -> Int {
        return numberOfMatchesInString(string, options: options, range: searchRange(range, within: string))
    }
    
    func matches(within string: String, options: NSMatchingOptions = [], range: Range<String.Index>? = nil) -> LazyMapCollection<[NSTextCheckingResult], MatchGroup> {
        let matches = matchesInString(string, options: options, range: searchRange(range, within: string))
        return matches.lazy.map {
            MatchGroup(result: $0, within: string)
        }
    }
    
    func splitMatches(within string: String, options: NSMatchingOptions = [], range: Range<String.Index>? = nil) -> [String] {
        let matches = self.matches(within: string, options: options, range: range)
        var start = range?.startIndex ?? string.startIndex
        let end = range?.endIndex ?? string.endIndex
        var splits = [String]()
        splits.reserveCapacity(matches.count + 1)
        for match in matches {
            splits.append(string[start..<match.range.startIndex])
            start = match.range.endIndex
        }
        splits.append(string[start..<end])
        return splits
    }
    
}