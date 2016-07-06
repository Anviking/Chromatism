//
//  JLNestedToken.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-21.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

protocol JLNestedScopeDelegate {
    func nestedScopeDidPerform(_ scope: JLNestedScope, additions: IndexSet)
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
    
    private var oldIndexSet = IndexSet()
    
    func perform(_ indexSet: IndexSet, tokens: [JLTokenizingScope.TokenResult]) {
        var newIndexSet = IndexSet()
        
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
                    if indexes.last < attributedString.length {
                        newIndexSet += indexes
                    }
                }
            }
            depth += result.token.delta
        }
        
        // We only need update attributes in indexes that just was added
        // And in indexes that has been reset by the document scope
        let additions = NSIndexSetDelta(oldIndexSet, newSet: newIndexSet).additions
        let intersection = indexSet.intersection(newIndexSet)
        setAttributesInIndexSet(intersection + additions)
        
        //println("\(incrementingToken.expression.pattern) - Additions: \(additions)")
        
        delegate?.nestedScopeDidPerform(self, additions: additions)
        performSubscopes(attributedString, indexSet: intersection)
        print("Intersection: \(intersection)")
        
        self.indexSet = newIndexSet
        oldIndexSet = newIndexSet
    }
    
    func incrementingTokenIsValid(_ token: JLTokenizingScope.TokenResult) -> Bool {
        return token.token === self.incrementingToken
    }
    
    func decrementingTokenIsValid(_ token: JLTokenizingScope.TokenResult) -> Bool {
        return token.token === self.decrementingToken
    }
    
    private func setAttributesInIndexSet(_ indexSet: IndexSet) {
        for range in indexSet.rangeView() {
            if let color = self.theme?[self.tokenType] {
                self.attributedString.addAttribute(NSForegroundColorAttributeName, value: color, range: NSRange(Range(range)))
            }
        }
    }
    
    override func invalidateAttributesInIndexes(_ indexSet: IndexSet) {
        self.indexSet -= indexSet
    }
    
    override func shiftIndexesAtLoaction(_ location: Int, by delta: Int) {
        oldIndexSet.shift(startingAt: location, by: delta)
        indexSet.shift(startingAt: location, by: delta)
    }
    
    
    func indexesForTokens(_ incrementingToken: JLTokenizingScope.TokenResult, decrementingToken: JLTokenizingScope.TokenResult, hollow: Bool) -> IndexSet {
        var indexSet = IndexSet()
        if hollow {
            indexSet.insert(integersIn: incrementingToken.range.toRange()!)
            indexSet.insert(integersIn: decrementingToken.range.toRange()!)
        } else {
            indexSet += (incrementingToken.range.start ..< decrementingToken.range.end)
        }
        return indexSet as IndexSet
    }
}

