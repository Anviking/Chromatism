//
//  JLTokenizingScope.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-28.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

/**
This class keeps track of "tokens" in the attributed string. This enables subscopes of type JLNestedScope to efficiently match tokens in to pairs.
*/
public class JLTokenizingScope: JLScope {
    
    /**
    Simple class to be used with JLTokenizingScope. It represents a type of symbol in the attributed string that can be nested to form scopes.
    
    Two tokens that represent open- and close-paranthesis could be created with
    
    :code: Token("\\(", delta: 1), Token("\\)", delta: -1) :endcode:
    */
    public class Token: Equatable {
        var delta: Int /// Set to +1 to increment by one level, or -1 to decrement
        var expression: RegularExpression
        
        init(pattern: String, delta: Int) {
            self.delta = delta
            self.expression = try! RegularExpression(pattern: pattern, options: [])
        }
    }
    
    let tokens: [Token]
    
    public init(tokens: [Token]) {
        self.tokens = tokens
        super.init()
        
        multiline = true
    }
    
    public convenience  init(incrementing: [String], decrementing:[String]) {
        var tokens = [Token]()
        for string in incrementing {
            tokens.append(Token(pattern: string, delta: 1))
        }
        
        for string in decrementing {
            tokens.append(Token(pattern: string, delta: -1))
        }
        
        self.init(tokens: tokens)
        
        multiline = true
    }
    
    /**
    Returns an instance with one fully set-up JLNestedScope as subscope.
    */
    public convenience init(incrementingPattern: String, decrementingPattern: String, tokenType: JLTokenType, hollow: Bool) {
        let a = Token(pattern: incrementingPattern, delta: 1)
        let b = Token(pattern: decrementingPattern, delta: -1)
        let descriptor = JLNestedScope(incrementingToken: a, decrementingToken: b, tokenType: tokenType, hollow: hollow)
        self.init(tokens: [a, b])
        self.subscopes = [descriptor]
    }
    
    
    var matches = [TokenResult]()
    private var deletions = [TokenResult]()
    
    override public func perform(_ indexSet: inout IndexSet) {
        self.indexSet = IndexSet()
        
        // Find Matches
        var array = [TokenResult]()
        let foundTokenIndexes = NSMutableIndexSet()
        for range in indexSet.rangeView() {
            for token in self.tokens {
                token.expression.enumerateMatches(in: self.attributedString.string, options: [], range: NSRange(Range(range)), using: { (result, _, _) in
                    if !foundTokenIndexes.contains(in: result!.range) {
                        array.append(TokenResult(result: result!, token: token))
                        foundTokenIndexes.add(in: result!.range)
                    }
                    })
            }
        }
        
        
        matches += array
        matches.sort { $0.range.location < $1.range.location }
        
//        oldLineIndexes =
        
        for scope in subscopes {
            if let scope = scope as? JLNestedScope {
                scope.theme = theme
                scope.perform(indexSet, tokens: matches)
                self.indexSet += scope.indexSet
            }
        }
    }
    
    
    override func shiftIndexesAtLoaction(_ location: Int, by delta: Int) {
        
        for (_, token) in Array(matches.reversed()).enumerated() {
            if token.range.location < location { break }
            token.shiftRanges(delta)
        }
        
        super.shiftIndexesAtLoaction(location, by: delta)
    }
    
    override func invalidateAttributesInIndexes(_ indexSet: IndexSet) {
        self.indexSet -= indexSet
        matches = matches.filter { !(indexSet.contains(integersIn: $0.range.toRange() ?? 0..<0)) }
    }
    
    public class TokenResult: CustomStringConvertible {
        var range: NSRange { return ranges[0] }
        var ranges: [NSRange]
        var token: Token
        
        init(result: TextCheckingResult, token: Token) {
            self.ranges = []
            self.token = token
            var i = 0
            while i < result.numberOfRanges {
                ranges.append(result.range(at: i))
                i += 1
            }
        }
        
        func shiftRanges(_ delta: Int) {
            ranges = ranges.map { return NSMakeRange($0.location + delta, $0.length)}
        }
        
        public var description: String { return "∆\(token.delta) \(range)"}
    }
}

public func ==(lhs: JLTokenizingScope.Token, rhs: JLTokenizingScope.Token) -> Bool {
    return (lhs.expression.pattern == rhs.expression.pattern && lhs.delta == rhs.delta)
}

private extension IndexSet {
    func containsAnyIndexesInRange(_ range: NSRange) -> Bool {
        for index in range.start ..< range.end {
            if self.contains(index) {
                return true
            }
        }
        return false
    }
}


