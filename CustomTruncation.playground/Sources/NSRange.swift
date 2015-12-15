//
//  NSRange.swift
//
//  Created by Zachary Waldowski on 7/16/15.
//  Copyright (c) 2015 Big Nerd Ranch. Some rights reserved. Licensed under MIT.
//

import Foundation
import Swift

extension String.UTF16View {
    
    var range: NSRange {
        return NSRange(indices, within: self)
    }
    
}

public extension NSRange {
    
    init(_ utf16Range: Range<String.UTF16View.Index>, within utf16: String.UTF16View) {
        location = utf16.startIndex.distanceTo(utf16Range.startIndex)
        length = utf16Range.count
    }
    
    init(_ range: Range<String.Index>, within characters: String) {
        let utf16 = characters.utf16
        let utfStart = range.startIndex.samePositionIn(utf16)
        let utfEnd = range.endIndex.samePositionIn(utf16)
        self.init(utfStart ..< utfEnd, within: utf16)
    }
    
    func toOptional() -> NSRange? {
        guard location != NSNotFound else { return nil }
        return self
    }
    
    func sameRangeIn(characters: String) -> Range<String.Index>? {
        guard location != NSNotFound else { return nil }
        
        let utfStart = characters.utf16.startIndex.advancedBy(location, limit: characters.utf16.endIndex)
        guard utfStart != characters.utf16.endIndex else { return nil }
        
        let utfEnd = utfStart.advancedBy(length, limit: characters.utf16.endIndex)
        
        guard let start = utfStart.samePositionIn(characters),
            end = utfEnd.samePositionIn(characters) else { return nil }
        
        return start ..< end
    }
    
}
