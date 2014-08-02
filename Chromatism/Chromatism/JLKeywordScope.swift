//
//  JLKeywordScope.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-08-02.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

class JLKeywordScope: JLRegexScope {
    init(keywords: [String], prefix: String, suffix: String, tokenType: JLTokenType) {
        let pattern = prefix + Branch(character: "", array: keywords).description + suffix
        let expression = NSRegularExpression(pattern: pattern, options: nil, error: nil)
        super.init(regularExpression: expression, tokenTypes: [tokenType])
    }
    
    /// Create a JLKeywordScope with prefix and suffix of word boundaries (\\b)
    convenience init (keywords: [String], tokenType: JLTokenType) {
        self.init(keywords: keywords, prefix: "\\b", suffix: "\\b", tokenType: tokenType)
    }
    
    /// Create a JLKeywordScope with a space-separated keyword string, with \\b prefix and suffix
    convenience init(keywords: String, tokenType: JLTokenType) {
        self.init(keywords: keywords.componentsSeparatedByString(" "), tokenType: tokenType)
    }
}

private protocol Node {
    var pattern: String {get}
}

private struct Leaf: Node {
    init() {}
    var pattern: String { return "" }
}

private struct Branch: Node, Printable {
    var children = [Node]()
    var character: String
    
    func perform(string: NSString, range: Range<Int>) {
        for i in range {
            
        }
    }
    
    init(character: String, array: [String]) {
        self.character = character
        var dictionary = [String: [String]]()
        for string in array {
            if countElements(string) > 0 {
                let firstCharacter = String(string[string.startIndex ... string.startIndex])
                let remainingString = string[string.startIndex.successor() ..< string.endIndex]
                if var array = dictionary[firstCharacter] {
                    array += remainingString
                    dictionary[firstCharacter] = array
                } else {
                    dictionary[firstCharacter] = [remainingString]
                }
            } else {
                // This means end of a match
                children += Leaf()
            }
        }
        for (key, value) in dictionary {
            children += Branch(character: key, array: value)
        }
        
    }
    
    var pattern: String {
    var array = children.map { $0.pattern }
    array.sort { countElements($0) < countElements($1) }
        
    switch array.count {
        case 0: return character + ""
        case 1: return character + array[0]
        default: return character + "(?:" + join("|", array) + ")"
    }
    }
    
    var description: String {
    return pattern
    }
}
