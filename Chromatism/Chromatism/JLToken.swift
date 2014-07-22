//
//  JLToken.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-14.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit
public class JLToken: JLScope {
    
    var regularExpression: NSRegularExpression
    var captureGroup = 0
    var contentCaptureGroup: Int?
    var tokenType: JLTokenType
    
    init(regularExpression: NSRegularExpression, tokenType: JLTokenType) {
        self.regularExpression = regularExpression
        self.tokenType = tokenType
        super.init()
    }
    
    convenience init(pattern: String, tokenType: JLTokenType) {
        self.init(pattern: pattern, options: .AnchorsMatchLines, tokenType: tokenType)
    }
    
    convenience init(pattern: String, tokenType: JLTokenType, captureGroup: Int) {
        self.init(pattern: pattern, tokenType: tokenType)
        self.captureGroup = captureGroup
    }
    
    convenience init(pattern: String, options: NSRegularExpressionOptions, tokenType: JLTokenType) {
        let expression = NSRegularExpression(pattern: pattern, options: options, error: nil)
        self.init(regularExpression: expression, tokenType: tokenType)
    }
    
    convenience init(pattern: String, tokenType: JLTokenType, scope: JLScope, contentCaptureGroup: Int) {
        self.init(pattern: pattern, tokenType: tokenType)
        self.contentCaptureGroup = contentCaptureGroup
    }
    
    convenience init(keywords: [String], tokenType: JLTokenType) {
        let pattern = "\\b(%" + join("|", keywords) + ")\\b"
        self.init(pattern: pattern, tokenType: tokenType)
    }
    
    override func perform(attributedString: NSMutableAttributedString, parentIndexSet: NSIndexSet) {
        let indexSet = self.indexSet - parentIndexSet
        let contentIndexSet = NSMutableIndexSet()
        parentIndexSet.enumerateRangesUsingBlock({ (range, stop) in
            self.regularExpression.enumerateMatchesInString(attributedString.string, options: nil, range: range, usingBlock: {(result, flags, stop) in
                
                var range = result.rangeAtIndex(self.captureGroup)
                
                indexSet.addIndexesInRange(range)

                
                if let color = self.theme?[self.tokenType] {
                    attributedString.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
                }
                
                if let captureGroup = self.contentCaptureGroup {
                    contentIndexSet.addIndexesInRange(result.rangeAtIndex(captureGroup))
                }
                })
            })
        
        if contentCaptureGroup {
            performSubscopes(attributedString, indexSet: contentIndexSet)
        } else if subscopes.count > 0{
            performSubscopes(attributedString, indexSet: indexSet.mutableCopy() as NSMutableIndexSet)
        }
        
        self.indexSet = indexSet
    }
    
    override public var description: String {
        return "JLToken"
    }
}
