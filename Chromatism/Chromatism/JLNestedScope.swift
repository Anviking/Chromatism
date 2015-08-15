//
//  JLNestedToken.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-21.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

protocol JLNestedScopeDelegate {
    func nestedScopeDidPerform(scope: JLNestedScope, additions: NSIndexSet)
}

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
    
    private var oldIndexSet = NSMutableIndexSet()
    
    func perform(indexSet: NSIndexSet, tokens: [JLTokenizingScope.TokenResult]) {
        let newIndexSet = NSMutableIndexSet()
        
        var incrementingTokens = Dictionary<Int, JLTokenizingScope.TokenResult>()
        var depth = 0
        for result in tokens {
            if result.token.delta > 0 {
                incrementingTokens[depth] = result
            } else if let start = incrementingTokens[depth + result.token.delta] {
                let incrementingToken = start
                let decrementingToken = result
                if incrementingTokenIsValid(incrementingToken) && decrementingTokenIsValid(decrementingToken) {
                    let indexes = indexesForTokens(incrementingToken, decrementingToken: decrementingToken, hollow: hollow)
                    if indexes.lastIndex < attributedString.length {
                        newIndexSet += indexes
                    }
                }
            }
            depth += result.token.delta
        }
        
        // We only need update attributes in indexes that just was added
        // And in indexes that has been reset by the document scope
        let additions = NSIndexSetDelta(oldIndexSet, newSet: newIndexSet).additions
        let intersection = indexSet.intersectionWithSet(newIndexSet)
        setAttributesInIndexSet(intersection + additions)
        
        //println("\(incrementingToken.expression.pattern) - Additions: \(additions)")
        
        delegate?.nestedScopeDidPerform(self, additions: additions)
        performSubscopes(attributedString, indexSet: intersection)
        print("Intersection: \(intersection)")
        
        self.indexSet = newIndexSet
        oldIndexSet = newIndexSet.mutableCopy() as! NSMutableIndexSet
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
    
    override func invalidateAttributesInIndexes(indexSet: NSIndexSet) {
        self.indexSet -= indexSet
    }
    
    override func shiftIndexesAtLoaction(location: Int, by delta: Int) {
        oldIndexSet.shiftIndexesStartingAtIndex(location, by: delta)
        indexSet.shiftIndexesStartingAtIndex(location, by: delta)
    }
    
    
    func indexesForTokens(incrementingToken: JLTokenizingScope.TokenResult, decrementingToken: JLTokenizingScope.TokenResult, hollow: Bool) -> NSIndexSet {
        let indexSet = NSMutableIndexSet()
        if hollow {
            indexSet += incrementingToken.range
            indexSet += decrementingToken.range
        } else {
            indexSet += NSRange(incrementingToken.range.start ..< decrementingToken.range.end)
        }
        return indexSet
    }
}

