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
    
    convenience init(pattern: String, options: NSRegularExpression.Options = .anchorsMatchLines, tokenTypes: JLTokenType...) {
        let expression: NSRegularExpression?
        do {
            expression = try NSRegularExpression(pattern: pattern, options: options)
        } catch _ {
            expression = nil
        }
        print(pattern)
        self.init(regularExpression: expression!, tokenTypes: tokenTypes)
    }
    
    override public func perform(_ parentIndexSet: inout IndexSet) {
        (parentIndexSet as NSIndexSet).enumerateRanges({ (range, stop) in
            self.regularExpression.enumerateMatches(in: self.attributedString.string, options: [], range: range, using: {(result, flags, stop) in
                    self.process(result!, attributedString: self.attributedString)
                })
            })
        
        performSubscopes(attributedString, indexSet: indexSet)
    }
    
    private func process(_ result: NSTextCheckingResult, attributedString: NSMutableAttributedString) {
        for (index, type) in self.tokenTypes.enumerated() {
            if let color = self.theme?[type] {
                if result.numberOfRanges > index {
                    let range = result.rangeAt(index)
                    attributedString.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
                    indexSet.insert(integersIn: range.toRange()!)
                }
            }
        }
    }
    
    override public var description: String {
        return "JLToken"
    }
}
