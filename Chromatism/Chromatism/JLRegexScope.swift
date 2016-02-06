//
//  JLToken.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-14.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

public class JLRegexScope: JLScope {
    
    var regularExpression: NSRegularExpression
    
    /// Allows you to specify specific tokenTypes for different capture groups. Index 0 means the whole match, following indexes represent capture groups.
    public var tokenTypes: [JLTokenType]
    
    
    init(regularExpression: NSRegularExpression, tokenTypes: [JLTokenType]) {
        self.regularExpression = regularExpression
        self.tokenTypes = tokenTypes
        super.init()
    }
    
    convenience init(pattern: String, options: NSRegularExpressionOptions = .AnchorsMatchLines, tokenTypes: JLTokenType...) {
        let expression: NSRegularExpression?
        do {
            expression = try NSRegularExpression(pattern: pattern, options: options)
        } catch _ {
            expression = nil
        }
        print(pattern)
        self.init(regularExpression: expression!, tokenTypes: tokenTypes)
    }
    
    override func perform(parentIndexSet: NSIndexSet) {
        parentIndexSet.enumerateRangesUsingBlock({ (range, stop) in
            self.regularExpression.enumerateMatchesInString(self.attributedString.string, options: [], range: range, usingBlock: {(result, flags, stop) in
                    self.process(result!, attributedString: self.attributedString)
                })
            })
        
        performSubscopes(attributedString, indexSet: indexSet.mutableCopy() as! NSMutableIndexSet)
    }
    
    private func process(result: NSTextCheckingResult, attributedString: NSMutableAttributedString) {
        for (index, type) in self.tokenTypes.enumerate() {
            if let color = self.theme?[type] {
                if result.numberOfRanges > index {
                    let range = result.rangeAtIndex(index)
                    attributedString.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
                    indexSet.addIndexesInRange(range)
                }
            }
        }
    }
    
    override public var description: String {
        return "JLToken"
    }
}
