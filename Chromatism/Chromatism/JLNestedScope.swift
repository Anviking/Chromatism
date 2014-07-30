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
    
    private var oldSubscopeIndexSet = NSMutableIndexSet()
    private var subscopeIndexSet = NSMutableIndexSet()
    private var oldIndexSet = NSMutableIndexSet()
    
    func perform(indexSet: NSIndexSet, tokens: [JLTokenizingScope.TokenResult]) {
        var newIndexSet = NSMutableIndexSet()
        var newSubscopeIndexSet = NSMutableIndexSet()
        
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
                    
                        let subscopeResult = indexesForTokens(incrementingToken, decrementingToken: decrementingToken, hollow: false)
                        if subscopeResult.lastIndex < attributedString.length {
                            newSubscopeIndexSet += subscopeResult
                        }
                }
            }
            depth += result.token.delta
        }
        
        // We only need update attributes in indexes that just was added
        // And in indexes that has been reset by the document scope
        
        
        
        var (additions, deletions) = NSIndexSetDelta(oldIndexSet, newIndexSet)
        let intersection = indexSet.intersectionWithSet(newIndexSet)
        setAttributesInIndexSet(intersection + additions)
        
        println("\(incrementingToken.expression.pattern) - Additions: \(additions)")
        
        let subscopeAdditions = NSIndexSetDelta(oldSubscopeIndexSet, newSubscopeIndexSet).additions
        
        if subscopeAdditions.count > 0 {
            println("\(incrementingToken.expression.pattern) - Additions: \(subscopeAdditions)")
            delegate?.nestedScopeDidPerform(self, additions: subscopeAdditions)
        }
        
        let subscopeIntersection = subscopeIndexSet.intersectionWithSet(indexSet)
        println(subscopeIndexSet)
        performSubscopes(attributedString, indexSet: subscopeIndexSet + subscopeAdditions)
        
        self.indexSet = newIndexSet
        self.subscopeIndexSet = newSubscopeIndexSet
        oldIndexSet = newIndexSet.mutableCopy() as NSMutableIndexSet
        oldSubscopeIndexSet = newSubscopeIndexSet.mutableCopy() as NSMutableIndexSet
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
        subscopeIndexSet.shiftIndexesStartingAtIndex(location, by: delta)
        oldSubscopeIndexSet.shiftIndexesStartingAtIndex(location, by: delta)
    }
    
    
    func indexesForTokens(incrementingToken: JLTokenizingScope.TokenResult, decrementingToken: JLTokenizingScope.TokenResult, hollow: Bool) -> NSIndexSet {
        var indexSet = NSMutableIndexSet()
        if hollow {
            indexSet += incrementingToken.range
            indexSet += decrementingToken.range
        } else {
            indexSet += NSRange(incrementingToken.range.start ..< decrementingToken.range.end)
        }
        return indexSet
    }
}

