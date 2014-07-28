//
//  JLNestedToken.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-21.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

public class JLNestedToken: JLScope {
    
    public class Token: Equatable {
        var delta: Int // Set to +1 to increment by one level, or -1 to decrement
        var expression: NSRegularExpression
        
        init(pattern: String, delta: Int) {
            self.delta = delta
            self.expression = NSRegularExpression(pattern: pattern, options: nil, error: nil)
        }
    }
    
    public class Descriptor {
        var incrementingToken: Token
        var decrementingToken: Token
        
        var tokenTypes = [Scope: JLTokenType]()
        
        init(incrementingToken: Token, decrementingToken: Token, tokenType: JLTokenType, hollow: Bool) {
            self.incrementingToken = incrementingToken
            self.decrementingToken = decrementingToken
            if hollow {
                tokenTypes[.Incrementing(0)] = tokenType
                tokenTypes[.Decrementing(0)] = tokenType
            } else {
                tokenTypes[.All] = tokenType
            }
        }
        
        
    }
    
    var descriptors: [Descriptor] = []
    let tokens: [Token]
    
    public init(tokens: [Token]) {
        self.tokens = tokens
        super.init()
        
        multiline = true
    }
    
    subscript(descriptors: Descriptor...) -> JLNestedToken {
        self.descriptors = descriptors
        return self
    }

    public convenience  init(incrementing: [String], decrementing:[String]) {
        var tokens = [Token]()
        for string in incrementing {
            tokens += Token(pattern: string, delta: 1)
        }
        
        for string in decrementing {
            tokens += Token(pattern: string, delta: -1)
        }
        
        self.init(tokens: tokens)
        
        multiline = true
    }

    public convenience init(incrementingPattern: String, decrementingPattern: String, tokenType: JLTokenType, hollow: Bool) {
        let a = Token(pattern: incrementingPattern, delta: 1)
        let b = Token(pattern: decrementingPattern, delta: -1)
        let descriptor = Descriptor(incrementingToken: a, decrementingToken: b, tokenType: tokenType, hollow: hollow)
        self.init(tokens: [a, b])
        self.descriptors += descriptor
    }
    
    
    var matches: [TokenResult] = []
    
    override func perform(indexSet: NSIndexSet) {
        func tokensClosestToRange(range: NSRange) -> (previous: TokenResult?, next: TokenResult?) {
            if self.matches.count == 0 { return (nil, nil) }
            var previousToken: TokenResult? = self.matches[self.matches.startIndex]
            var nextToken: TokenResult?
            
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
        
        func surroundingTokenPair(range: NSRange) -> (incrementingToken: TokenResult, decrementingToken: TokenResult)? {
            let tokens = tokensClosestToRange(range)
            if let previousToken = tokens.previous {
                if let nextToken = tokens.next {
                    if previousToken.token.delta > 0 && nextToken.token.delta < 0 {
                        return (previousToken, nextToken)
                    }
                }
            }
            return nil
        }
        
        self.indexSet = NSMutableIndexSet()
        
        // Find Matches
        var foundTokenIndexes = NSMutableIndexSet()
        indexSet.enumerateRangesUsingBlock { (range, _) in
            for token in self.tokens {
                var array: [TokenResult] = []
                token.expression.enumerateMatchesInString(self.attributedString.string, options: nil, range: range, usingBlock: { (result, _, _) in
                    if !foundTokenIndexes.containsAnyIndexesInRange(result.range) {
                        array += TokenResult(result: result, token: token)
                        foundTokenIndexes.addIndexesInRange(result.range)
                    }
                    })
                
                self.matches += array
                self.matches.sort { $0.range.location < $1.range.location }
                if let (start, end) = surroundingTokenPair(range) {
                    self.process(start, decrementingToken: end, attributedString: self.attributedString)
                }
            }
        }
        
        
        matches.sort { $0.range.location < $1.range.location }
        var incrementingTokens = [Int: TokenResult]()
        
        var depth = 0
        for result in matches {
            if result.token.delta > 0 {
                incrementingTokens[depth] = result
            } else if let start = incrementingTokens[depth + result.token.delta] {
                process(start, decrementingToken: result, attributedString: attributedString)
            }
            depth += result.token.delta
        }
    }
    
    private func process(incrementingToken: TokenResult, decrementingToken: TokenResult, attributedString: NSMutableAttributedString) {
        
        for descriptor in descriptors {
            if incrementingToken.token === descriptor.incrementingToken && decrementingToken.token === descriptor.decrementingToken {
                for (scope, type) in descriptor.tokenTypes {
                    let range = rangeForScope(scope, incrementingToken: incrementingToken, decrementingToken: decrementingToken)
                    if let color = self.theme?[type] {
                        if range.location >= 0 && range.end <= attributedString.length {
                            attributedString.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
                            indexSet += range
                        }
                    }
                }
            }
        }
    }
    
    private func rangeForScope(scope: Scope, incrementingToken: TokenResult, decrementingToken: TokenResult) -> NSRange {
        let start = incrementingToken.range
        let end = decrementingToken.range
        
        switch scope {
        case .All:
            return NSRange(start.location ..< end.location + end.length)
        case .Incrementing(let captureGroup):
            return incrementingToken.ranges[captureGroup]
        case .Decrementing(let captureGroup):
            return decrementingToken.ranges[captureGroup]
        case .Between:
            return NSRange(start.end ..< end.start)
        default:
            return 0
        }
    }
    
    override func shiftIndexesAtLoaction(location: Int, by delta: Int) {
        
        for (index, token) in enumerate(matches.reverse()) {
            if token.range.location < location { break }
            token.shiftRanges(delta)
        }
        
        super.shiftIndexesAtLoaction(location, by: delta)
    }
    
    override func invalidateAttributesInIndexes(indexSet: NSIndexSet) {
        self.indexSet -= indexSet
        matches = matches.filter { !(indexSet.containsIndexesInRange($0.range)) }
    }
    
    class TokenResult: Printable {
        var range: NSRange { return ranges[0] }
        var ranges: [NSRange]
        var token: Token
        
        init(result: NSTextCheckingResult, token: Token) {
            self.ranges = []
            self.token = token
            var i = 0
            while i < result.numberOfRanges {
                ranges += result.rangeAtIndex(i)
                i++
            }
        }
        
        func shiftRanges(delta: Int) {
            ranges = ranges.map { return NSMakeRange($0.location + delta, $0.length)}
        }
        
        var description: String { return "∆\(token.delta) \(range)"}
    }
    
    public enum Scope: Hashable, Equatable {
        case All, Incrementing(Int), Decrementing(Int), Between
        
        public var hashValue: Int {
        let bitsPerComponent = 8
            switch self {
            case All:
                return 1
            case Incrementing(let captureGroup):
                return captureGroup + 1 << (1 * bitsPerComponent)
            case Decrementing(let captureGroup):
                return captureGroup + 1 << (2 * bitsPerComponent)
            case Between:
                return 1 << (3 * bitsPerComponent)
            default:
                return 0
            }
        }
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

public func ==(lhs: JLNestedToken.Scope, rhs: JLNestedToken.Scope) -> Bool {
    return (lhs.hashValue == rhs.hashValue)
}

public func ==(lhs: JLNestedToken.Token, rhs: JLNestedToken.Token) -> Bool {
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
