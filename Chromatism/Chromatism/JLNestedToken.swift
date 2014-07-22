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
        
        indexSet -= parentIndexSet
        matches = matches.filter { !(parentIndexSet.containsIndexesInRange($0.range)) }
        
        func tokensClosestToRange(range: NSRange) -> (previous: Token?, next: Token?) {
            if self.matches.count == 0 { return (nil, nil) }
            var previousToken: Token? = self.matches[self.matches.startIndex]
            var nextToken: Token?
            
            for token in self.matches {
                if token.range.location < range.location {
                    previousToken = token
                } else if token.range.end > range.end {
                    nextToken = token
                    break
                }
            }
            
            return (previousToken, nextToken)
        }
        
        func rangeOfSurroundingTokenPair(range: NSRange) -> NSRange? {
            let tokens = tokensClosestToRange(range)
            if let previousToken = tokens.previous {
                if let nextToken = tokens.next {
                    if previousToken.delta > 0 && nextToken.delta < 0 {
                        return NSMakeRange(previousToken.range.location, nextToken.range.end - previousToken.range.location)
                    }
                }
            }
            return nil
        }
        
        parentIndexSet.enumerateRangesUsingBlock { (range, _) in
            var array: [Token] = []
            self.incrementingExpression.enumerateMatchesInString(attributedString.string, options: nil, range: range, usingBlock: { (result, _, _) in
                array += Token(delta: 1, range: range)
                })
            self.decrementingExpression.enumerateMatchesInString(attributedString.string, options: nil, range: range, usingBlock: { (result, _, _) in
                array += Token(delta: -1, range: range)
                })
            self.matches += array
            if let range = rangeOfSurroundingTokenPair(range) {
                if let color = self.colorDictionary?[self.tokenType] {
                    attributedString.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
                }
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
                    attributedString.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
                }
            }
            depth += result.delta
        }
    }
    
    override func attributedStringDidChange(range: NSRange, delta: Int)  {
        for (index, result) in enumerate(matches.reverse()) {
            if result.range.location < range.end { break }
            println("Shifting: \(result) by delta: \(delta)")
            result.range = NSMakeRange(result.range.location + delta, range.length)
            
        }
        super.attributedStringDidChange(range, delta: delta)
    }
    
    
    class Token: Printable {
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
