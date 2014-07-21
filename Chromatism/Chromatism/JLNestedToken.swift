//
//  JLNestedToken.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-21.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

// This class shows that there is a fundamental problem with JLScope. It two tokens matches next to each other the indexSet will merge them to one. Concidering relying on the attributedString instead.
class JLNestedToken: JLScope {
    
    var incrementingToken: JLToken
    var decrementingToken: JLToken
    
    init(incrementingToken: JLToken, decrementingToken: JLToken) {
        self.incrementingToken = incrementingToken
        self.decrementingToken = decrementingToken
        super.init()
    }
    

    override func perform(attributedString: NSMutableAttributedString, parentIndexSet: NSIndexSet) {
        
        indexSet -= parentIndexSet
        incrementingToken.perform(attributedString, parentIndexSet: parentIndexSet)
        decrementingToken.perform(attributedString, parentIndexSet: parentIndexSet)
        
        var tokens: [Result] = []
        incrementingToken.indexSet.enumerateRangesUsingBlock { (range, _) in
            tokens += Result(delta: 1, range: range)
        }
        
        decrementingToken.indexSet.enumerateRangesUsingBlock { (range, _) in
            tokens += Result(delta: -1, range: range)
        }
        
        // Sort array with the first result first
        tokens.sort { $0.range.location < $1.range.location }
        
        var startIndexes = [Int: Int]()
        var depth = 0
        for result in tokens {
            if result.delta > 0 {
                startIndexes[depth] = result.range.location
            } else if let startIndex = startIndexes[depth + result.delta] {
                let endIndex = NSMaxRange(result.range)
                let range = NSMakeRange(startIndex, endIndex - startIndex)
                self.indexSet.addIndexesInRange(range)
                if let color = self.colorDictionary?[incrementingToken.tokenType] {
                    attributedString.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
                }
            }
            depth += result.delta
        }
    }
    
    struct Result: Printable {
        var range: NSRange
        var delta: Int // Set to +1 to increment by one level, or -1 to decrement
        
        init(delta:Int, range: NSRange) {
            self.range = range
            self.delta = delta
        }
        
        var description: String { return "∆\(delta) \(range)"}
    }
   
}
