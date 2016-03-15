//
//  NSRegularExpression.swift
//
//  Created by Zachary Waldowski on 7/16/15.
//  Copyright (c) 2015 Big Nerd Ranch. Some rights reserved. Licensed under MIT.
//

import Foundation

public struct MatchGroup: CollectionType, CustomReflectable, CustomStringConvertible, CustomDebugStringConvertible {
    
    private let result: NSTextCheckingResult
    private let source: String

    private init(result: NSTextCheckingResult, within source: String) {
        self.result = result
        self.source = source
    }
    
    public var range: Range<String.Index> {
        // From NSRegularExpression: "A result must have at least one range, but
        // may optionally have more (for example, to represent capture groups).
        // The range at index 0 always matches the range property."
        return result.range.sameRangeIn(source)!
    }

    private func substringForRange(range: NSRange) -> String? {
        return range.sameRangeIn(source).map { source[$0] }
    }

    public var startIndex: Int {
        return 1
    }

    public var endIndex: Int {
        return result.numberOfRanges
    }

    public subscript(i: Int) -> String? {
        let range = result.rangeAtIndex(i)
        return substringForRange(range)
    }

    public var ranges: LazyMapCollection<Range<Int>, Range<String.Index>?> {
        return indices.lazy.map {
            self.result.rangeAtIndex($0).sameRangeIn(self.source)
        }
    }
    
    public var description: String {
        return substringForRange(result.range) ?? ""
    }
    
    public var debugDescription: String {
        return "range: \(range), text: \"\(String(self))\""
    }
    
    public func customMirror() -> Mirror {
        return Mirror(self, children: [
            "range": String(range),
            "substring": String(self)
        ], displayStyle: .Struct)
    }
    
}

extension String {

    private func searchRange(range: Range<String.Index>?) -> NSRange {
        return range.map { NSRange($0, within: self) } ?? NSRange(0 ..< utf16.count)
    }

    public func match(regex: NSRegularExpression, range: Range<String.Index>? = nil, options: NSMatchingOptions = []) -> MatchGroup? {
        return regex.firstMatchInString(self, options: options, range: searchRange(range)).map {
            MatchGroup(result: $0, within: self)
        }
    }

    public func numberOfMatches(regex: NSRegularExpression, range: Range<String.Index>? = nil, options: NSMatchingOptions = []) -> Int {
        return regex.numberOfMatchesInString(self, options: options, range: searchRange(range))
    }

    public func matches(regex: NSRegularExpression, range: Range<String.Index>? = nil, options: NSMatchingOptions = []) -> [MatchGroup] {
        return regex.matchesInString(self, options: options, range: searchRange(range)).map {
            MatchGroup(result: $0, within: self)
        }
    }

    public func splitMatches(regex: NSRegularExpression, range: Range<String.Index>? = nil, options: NSMatchingOptions = []) -> [String] {
        let matches = self.matches(regex, range: range, options: options)
        var start = range?.startIndex ?? startIndex
        let end = range?.endIndex ?? endIndex
        var splits = [String]()
        splits.reserveCapacity(matches.count + 1)
        for match in matches {
            splits.append(self[start..<match.range.startIndex])
            start = match.range.endIndex
        }
        splits.append(self[start..<end])
        return splits
    }
    
}
