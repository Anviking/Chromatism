//
//  JLKeywordScope.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-08-02.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

class JLKeywordScope: JLRegexScope {
    init(keywords: [String], prefix: String, suffix: String, tokenTypes: [JLTokenType]) {
        let pattern = prefix + Branch(array: keywords).description + suffix
        println(pattern)
        let expression = NSRegularExpression(pattern: pattern, options: nil, error: nil)
        super.init(regularExpression: expression, tokenTypes: tokenTypes)
    }
    
    convenience init (keywords: [String], tokenTypes: JLTokenType...) {
        self.init(keywords: keywords, prefix: "\\b", suffix: "\\b", tokenTypes: tokenTypes)
    }
}

private protocol Node {
    var pattern: String {get}
}
extension String: Node {
    var pattern: String {
        return NSRegularExpression.escapedPatternForString(self) as String
    }
}

private struct Branch: Node, Printable {
    var children = [String: Node]()
    init(array: [String]) {
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
                children[""] = string
            }
        }
        for (key, value) in dictionary {
            if array.count == 1 {
                children[key] = value[0]
            } else {
                children[key] = Branch(array: value)
            }
        }
        
    }
    
    var pattern: String {
    var array = [String]()
        for (key, value) in children {
            array += "\(key)\(value.pattern)"
        }
        
        if children.count == 1 {
            return join("|", array)
        }
        
        return "(?:" + join("|", array) + ")"
    }
    
    var description: String {
    return pattern
    }
}
