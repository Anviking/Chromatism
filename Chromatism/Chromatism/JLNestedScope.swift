//
//  JLNestedToken.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-21.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

public class JLNestedScope: JLScope {
    var incrementingToken: JLTokenizingScope.Token
    var decrementingToken: JLTokenizingScope.Token
    
    var tokenType: JLTokenType
    var hollow: Bool
    
    init(incrementingToken: JLTokenizingScope.Token, decrementingToken: JLTokenizingScope.Token, tokenType: JLTokenType, hollow: Bool) {
        self.incrementingToken = incrementingToken
        self.decrementingToken = decrementingToken
        self.hollow = hollow
        self.tokenType = tokenType
        super.init()
        multiline = true
    }
    
    func perform(indexSet: NSIndexSet, tokens: [JLTokenizingScope.TokenResult]) {
        let oldIndexSet = self.indexSet
        var newIndexSet = NSMutableIndexSet()
        
        var incrementingTokens = Dictionary<Int, JLTokenizingScope.TokenResult>()
        var depth = 0
        for result in tokens {
            if result.token.delta > 0 {
                incrementingTokens[depth] = result
            } else if let start = incrementingTokens[depth + result.token.delta] {
                process(start, decrementingToken: result, indexSet: newIndexSet)
            }
            depth += result.token.delta
        }
        
        // We only need update attributes in indexes that just was added
        var (additions, deletions) = NSIndexSetDelta(oldIndexSet, newIndexSet)
        setAttributesInIndexSet(additions)
        
        // And in indexes that has been reset by the document scope
        let intersection = indexSet.intersectionWithSet(newIndexSet)
        setAttributesInIndexSet(intersection)
        
        self.indexSet = newIndexSet
    }
    
    func incrementingTokenIsValid(token: JLTokenizingScope.TokenResult) -> Bool {
        return token.token === self.incrementingToken
    }
    
    func decrementingTokenIsValid(token: JLTokenizingScope.TokenResult) -> Bool {
        return token.token === self.decrementingToken
    }
    
    private func setAttributesInIndexSet(indexSet: NSIndexSet) {
        indexSet.enumerateRangesUsingBlock { (range, stop) in
            if let color = self.theme?[self.tokenType] {
                self.attributedString.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
            }
        }
    }
    
    private func process(incrementingToken: JLTokenizingScope.TokenResult, decrementingToken: JLTokenizingScope.TokenResult, indexSet: NSMutableIndexSet) {
        if incrementingTokenIsValid(incrementingToken) && decrementingTokenIsValid(decrementingToken) {
            let indexes = indexesForTokens(incrementingToken, decrementingToken: decrementingToken)
            if indexes.lastIndex < attributedString.length {
                indexSet += indexes
            }
        }
    }
    
    override func invalidateAttributesInIndexes(indexSet: NSIndexSet) {
        self.indexSet -= indexSet
    }
    
    
    func indexesForTokens(incrementingToken: JLTokenizingScope.TokenResult, decrementingToken: JLTokenizingScope.TokenResult) -> NSIndexSet {
        var indexSet = NSMutableIndexSet()
        if self.hollow {
            indexSet += incrementingToken.range
            indexSet += decrementingToken.range
        } else {
            indexSet += NSRange(incrementingToken.range.start ..< decrementingToken.range.end)
        }
        return indexSet
    }
}

extension NSRange {
    var end: Int {
    return location + length
    }
    
    var start: Int {
    return location
    }
}

public func ==(lhs: JLTokenizingScope.Token, rhs: JLTokenizingScope.Token) -> Bool {
    return (lhs.expression.pattern == rhs.expression.pattern && lhs.delta == rhs.delta)
}


extension NSIndexSet {
    func containsAnyIndexesInRange(range: NSRange) -> Bool {
        for index in range.start ..< range.end {
            if self.containsIndex(index) {
                return true
            }
        }
        return false
    }
}
