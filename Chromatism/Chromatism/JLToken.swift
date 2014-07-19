//
//  JLToken.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-14.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit
class JLToken: JLScope {
    
    var regularExpression: NSRegularExpression
    var captureGroup = 0
    var contentCaptureGroup: Int?
    var tokenType: JLTokenType
    
    init(regularExpression: NSRegularExpression, tokenType: JLTokenType, scope: JLScope) {
        self.regularExpression = regularExpression
        self.tokenType = tokenType
        super.init(scope: scope)
    }
    
    convenience init(pattern: String, tokenType: JLTokenType, scope: JLScope) {
        let expression = NSRegularExpression(pattern: pattern, options: .AnchorsMatchLines, error: nil)
        self.init(regularExpression: expression, tokenType: tokenType, scope: scope)
    }
    
    convenience init(pattern: String, tokenType: JLTokenType, scope: JLScope, contentCaptureGroup: Int) {
        self.init(pattern: pattern, tokenType: tokenType, scope: scope)
        self.contentCaptureGroup = contentCaptureGroup
    }
    
    override func perform(attributedString: NSMutableAttributedString, delegate: JLScopeDelegate, parentIndexSet: NSIndexSet) {
        let indexSet = NSMutableIndexSet()
        let contentIndexSet = NSMutableIndexSet()
        parentIndexSet.enumerateRangesUsingBlock({ (range, stop) in
            self.regularExpression.enumerateMatchesInString(attributedString.string, options: nil, range: range, usingBlock: {(result, flags, stop) in
                let range = result.rangeAtIndex(self.captureGroup)
                indexSet.addIndexesInRange(range)
                if let captureGroup = self.contentCaptureGroup {
                    contentIndexSet.addIndexesInRange(result.rangeAtIndex(captureGroup))
                }
                })
            })
        
        if contentCaptureGroup {
            performSubscopes(attributedString, delegate: delegate, indexSet: contentIndexSet)
            println(contentIndexSet)
        }
        
        delegate.scope(self, didPerformInAttributedString: attributedString, parentIndexSet: parentIndexSet, resultIndexSet: indexSet)
        
        self.indexSet = indexSet
    }
}
