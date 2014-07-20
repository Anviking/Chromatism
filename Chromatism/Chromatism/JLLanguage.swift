//
//  JLLanguage.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-17.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

class JLLanguage {
    let documentScope: JLScope
    let lineScope: JLScope
    
    @required init() {
        documentScope = JLScope()
        lineScope = JLScope()
        
        lineScope.clearWithTextColorBeforePerform = true
        documentScope => [
            lineScope
        ]
    }
    
    class C: JLLanguage {
        
        var blockComments = JLToken(pattern: "/\\*.*?\\*/", options: .DotMatchesLineSeparators, tokenType: .Comment)
        var lineComments = JLToken(pattern: "//(.*)", tokenType: .Comment)
        
        var preprocessor = JLToken(pattern: "^#.*+$", tokenType: .Preprocessor)
        var strings = JLToken(pattern: "(\"|@\")[^\"\\n]*(@\"|\")", tokenType: .String)
        var numbers = JLToken(pattern: "(?<=\\s)\\d+", tokenType: .Number)
        var functions = JLToken(pattern: "\\w+\\s*(?>\\(.*\\)", tokenType: .OtherMethodNames)
        
        var keywords = "true false yes no YES TRUE FALSE bool BOOL nil id void self NULL if else strong weak nonatomic atomic assign copy typedef enum auto break case const char continue do default double extern float for goto int long register return short signed sizeof static struct switch typedef union unsigned volatile while nonatomic atomic nonatomic readonly super".componentsSeparatedByString(" ")
        @lazy var keywordToken: JLToken = { JLToken(keywords: self.keywords, tokenType: .Keyword) }()
        
        init() {
            super.init()
            documentScope => [
                blockComments,
                lineScope => [
                    lineComments,
                    preprocessor => [strings],
                    strings,
                    numbers,
                    functions,
                    keywordToken
                ]
            ]
        }
    }
    
    class ObjectiveC: C {
        init() {
            
        }
    }
}

// Operator for "add subscope". Can be nested, since it returns the left value.
operator infix => { associativity right}
func => (left: JLScope, right: [JLScope]) -> JLScope {
    left.subscopes = right
    return left
}

