//
//  JLNestedToken.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-21.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

// This class shows that there is a fundamental problem with JLScope. It two tokens matches next to each other the indexSet will merge them to one. Concidering relying on the attributedString instead.
public class JLNestedToken: JLScope {
    
    var incrementingExpression: NSRegularExpression
    var decrementingExpression: NSRegularExpression
    
    var tokenTypes: [Scope: JLTokenType]
    
    public init(incrementingPattern: String, decrementingPattern: String, tokenTypes: [Scope: JLTokenType]) {
        self.incrementingExpression = NSRegularExpression(pattern: incrementingPattern, options: nil, error: nil)
        self.decrementingExpression = NSRegularExpression(pattern: decrementingPattern, options: nil, error: nil)
        self.tokenTypes = tokenTypes
        super.init()
    }
    
    var matches: [Token] = []
    
    override func perform(attributedString: NSMutableAttributedString, parentIndexSet: NSIndexSet) {
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
        
        func surroundingTokenPair(range: NSRange) -> (incrementingToken: Token, decrementingToken: Token)? {
            let tokens = tokensClosestToRange(range)
            if let previousToken = tokens.previous {
                if let nextToken = tokens.next {
                    if previousToken.delta > 0 && nextToken.delta < 0 {
                        return (previousToken, nextToken)
                    }
                }
            }
            return nil
        }
        
        
        indexSet -= parentIndexSet
        matches = matches.filter { !(parentIndexSet.containsIndexesInRange($0.range)) }
        
        // Find Matches
        parentIndexSet.enumerateRangesUsingBlock { (range, _) in
            var array: [Token] = []
            self.incrementingExpression.enumerateMatchesInString(attributedString.string, options: nil, range: range, usingBlock: { (result, _, _) in
                array += Token(delta: 1, result: result)
                })
            self.decrementingExpression.enumerateMatchesInString(attributedString.string, options: nil, range: range, usingBlock: { (result, _, _) in
                array += Token(delta: -1, result: result)
                })
            self.matches += array
            if let (start, end) = surroundingTokenPair(range) {
                self.process(start, decrementingToken: end, attributedString: attributedString)
            }
        }
        
        matches.sort { $0.range.location < $1.range.location }
        
        var incrementingTokens = [Int: Token]()
        var depth = 0
        for token in matches {
            if token.delta > 0 {
                incrementingTokens[depth] = token
            } else if let start = incrementingTokens[depth + token.delta] {
                process(start, decrementingToken: token, attributedString: attributedString)
            }
            depth += token.delta
        }
    }
    
    private func process(incrementingToken: Token, decrementingToken: Token, attributedString: NSMutableAttributedString) {
        for (scope, type) in self.tokenTypes {
            let range = rangeForScope(scope, incrementingToken: incrementingToken, decrementingToken: decrementingToken)
            if let color = self.theme?[type] {
                attributedString.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
            }
        }
    }
    
    private func rangeForScope(scope: Scope, incrementingToken: Token, decrementingToken: Token) -> NSRange {
        let start = incrementingToken.range
        let end = decrementingToken.range
        
        switch scope {
        case .All:
            return NSRange(start.location ..< end.location + end.length)
        case .Incrementing(let captureGroup):
            return incrementingToken.result.rangeAtIndex(captureGroup)
        case .Decrementing(let captureGroup):
            println("Decrementing[0]: \(decrementingToken.result.range)")
            return decrementingToken.result.rangeAtIndex(captureGroup)
        case .Between:
            return NSRange(start.end ..< end.start)
        default:
            return 0
        }
    }
    
    override func attributedStringDidChange(range: NSRange, delta: Int)  {
        for (index, token) in enumerate(matches.reverse()) {
            if token.range.location < range.end { break }
            token.range = NSMakeRange(token.range.location + delta, range.length)
            
        }
        super.attributedStringDidChange(range, delta: delta)
    }
    
    
    class Token: Printable {
        var range: NSRange
        var delta: Int // Set to +1 to increment by one level, or -1 to decrement
        var result: NSTextCheckingResult
        
        init(delta:Int, result: NSTextCheckingResult) {
            self.range = result.range
            self.delta = delta
            self.result = result
        }
        
        var description: String { return "∆\(delta) \(range)"}
    }
    
    public enum Scope: Hashable, Equatable {
        case All, Incrementing(Int), Decrementing(Int), Between
        
        public var hashValue: Int {
        let bitsPerComponent = 8
            switch self {
            case All:
                return 1
            case Incrementing(let captureGroup):
                return captureGroup << (1 * bitsPerComponent)
            case Decrementing(let captureGroup):
                return captureGroup << (2 * bitsPerComponent)
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
