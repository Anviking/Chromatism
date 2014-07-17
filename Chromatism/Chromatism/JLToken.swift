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
    var color: UIColor
    
    init(regularExpression: NSRegularExpression, color: UIColor, scope: JLScope) {
        self.regularExpression = regularExpression
        self.color = color
        super.init(scope: scope)
    }
    
    convenience init(pattern: String, color: UIColor, scope: JLScope) {
        let expression = NSRegularExpression(pattern: pattern, options: .AnchorsMatchLines, error: nil)
        self.init(regularExpression: expression, color: color, scope: scope)
    }
    
    convenience init(pattern: String, color: UIColor, scope: JLScope, contentCaptureGroup: Int) {
        self.init(pattern: pattern, color: color, scope: scope)
        self.contentCaptureGroup = contentCaptureGroup
    }
    
    override func perform(inIndexSet parentIndexSet: NSIndexSet) -> NSIndexSet {
        let indexSet = NSMutableIndexSet()
        let contentIndexSet = NSMutableIndexSet()
        parentIndexSet.enumerateRangesUsingBlock({ (range, stop) in
            self.regularExpression.enumerateMatchesInString(self.attributedString.string, options: nil, range: range, usingBlock: {(result, flags, stop) in
                let range = result.rangeAtIndex(self.captureGroup)
                indexSet.addIndexesInRange(range)
                self.attributedString.addAttribute(NSForegroundColorAttributeName, value: self.color, range: range)
                if let captureGroup = self.contentCaptureGroup {
                    contentIndexSet.addIndexesInRange(result.rangeAtIndex(captureGroup))
                }
                })
            })
        
        if contentCaptureGroup {
            performSubscopesInIndexSet(contentIndexSet)
            println(contentIndexSet)
        }
        
        return indexSet
    }
}
