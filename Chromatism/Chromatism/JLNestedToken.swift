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
    
    var incrementingExpression: NSRegularExpression
    var decrementingExpression: NSRegularExpression
    let identifier: String
    
    var tokenType: JLTokenType
    
    init(identifier: String, incrementingPattern: String, decrementingPattern: String, tokenType: JLTokenType) {
        self.incrementingExpression = NSRegularExpression(pattern: incrementingPattern, options: nil, error: nil)
        self.decrementingExpression = NSRegularExpression(pattern: decrementingPattern, options: nil, error: nil)
        self.tokenType = tokenType
        self.identifier = identifier
        super.init()
    }
    
    var matches: [Token] = []
    
    override func perform(attributedString: NSMutableAttributedString, parentIndexSet: NSIndexSet) {
        
        var editingInside = false
        var needsToBeRefreshed = [Token]()
        
        let compareResult = Token(delta: 0, range: NSMakeRange(Int.max, Int.max))
        indexSet.intersectionWithSet(parentIndexSet).enumerateRangesUsingBlock { (range, _) in
            var effectiveRangePointer = NSRangePointer.alloc(sizeof(NSRange))
            attributedString.attribute(self.identifier, atIndex: range.location, effectiveRange: effectiveRangePointer)
            let effectiveRange = effectiveRangePointer.memory
        }
        
        println("Refresh: \(needsToBeRefreshed)")
        
        parentIndexSet.enumerateIndexesUsingBlock { (index, _) in
            if self.indexSet.containsIndex(index) {
                //needsToBeRefreshed+=
            }
        }
        
        indexSet -= parentIndexSet
        var oldMatches = matches.filter { parentIndexSet.containsIndexesInRange($0.range) }
        //println("Outdated matches: \(oldMatches)")
        matches = matches.filter { !(parentIndexSet.containsIndexesInRange($0.range)) }
        
        
        parentIndexSet.enumerateRangesUsingBlock { (range, _) in
            var array: [Token] = []
            self.incrementingExpression.enumerateMatchesInString(attributedString.string, options: nil, range: range, usingBlock: { (result, _, _) in
                array += Token(delta: 1, range: range)
                })
            self.incrementingExpression.enumerateMatchesInString(attributedString.string, options: nil, range: range, usingBlock: { (result, _, _) in
                array += Token(delta: -1, range: range)
                })
            
            if array.count == 0 {
                
                var nextToken: Token
                let afterRange = NSMakeRange(range.end, attributedString.length - range.end)
                let nextIncrementingToken = self.incrementingExpression.firstMatchInString(attributedString.string, options: nil, range: afterRange)
                let nextDecrementingToken = self.decrementingExpression.firstMatchInString(attributedString.string, options: nil, range: afterRange)
                
                attributedString.enumerateAttribute(self.identifier, inRange: range, options: nil, usingBlock: { (object, range, stop) in
                    if object {
                        if let color = self.colorDictionary?[self.tokenType] {
                            attributedString.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
                        }
                    }
                    })
                
            } else {
                self.matches += array
            }
        }
        
        
        matches.sort { $0.range.location < $1.range.location }
        
        var startIndexes = [Int: Int]()
        var depth = 0
        println(matches)
        for result in matches {
            if result.delta > 0 {
                startIndexes[depth] = result.range.location
            } else if let startIndex = startIndexes[depth + result.delta] {
                let endIndex = NSMaxRange(result.range)
                let range = NSMakeRange(startIndex, endIndex - startIndex)
                self.indexSet.addIndexesInRange(range)
                if let color = self.colorDictionary?[tokenType] {
                    attributedString.addAttribute(identifier, value: identifier, range: range)
                    attributedString.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
                }
            }
            depth += result.delta
        }
    }
    
    override func clearAttributesInIndexSet(indexSet: NSIndexSet, attributedString: NSMutableAttributedString) {
        indexSet.enumerateRangesUsingBlock { (range, stop) in
            //attributedString.removeAttribute(self.identifier, range: range)
        }
    }
    
    class Range {
        var incrementingToken: Token
        var decrementingToken: Token
        init(incrementingToken: Token, decrementingToken: Token) {
            self.incrementingToken = incrementingToken
            self.decrementingToken = decrementingToken
        }
    }
    
    struct Token: Printable {
        var range: NSRange
        var delta: Int // Set to +1 to increment by one level, or -1 to decrement
        
        init(delta:Int, range: NSRange) {
            self.range = range
            self.delta = delta
        }
        
        var description: String { return "∆\(delta) \(range)"}
    }
    
}

extension NSRange {
    var end: Int {
    return NSMaxRange(self)
    }
}
