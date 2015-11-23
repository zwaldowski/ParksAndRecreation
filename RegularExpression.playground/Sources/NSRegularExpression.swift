//
//  NSRegularExpression.swift
//
//  Created by Zachary Waldowski on 7/16/15.
//  Copyright (c) 2015 Big Nerd Ranch. Some rights reserved. Licensed under MIT.
//

import Foundation

public struct MatchGroup {
    
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
    
    var ranges: LazyMapCollection<Range<Int>, Range<String.Index>?> {
        return (1 ..< result.numberOfRanges).lazy.map {
            self.result.rangeAtIndex($0.successor()).sameRangeIn(self.string)
        }
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
    
}