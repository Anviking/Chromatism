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
        var angularImports = JLToken(pattern: "<.*?>", tokenType: .String)
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
                    preprocessor => [strings, angularImports],
                    strings,
                    numbers,
                    functions,
                    keywordToken
                ]
            ]
        }
    }
    
    class ObjectiveC: C {
        // Long time since I wrote these regexes. They should probably be updated
        var dotNotation = JLToken(pattern: "\\.\\w+", tokenType: .OtherMethodNames)
        var methodCalls = JLToken(pattern: "(\\w+)\\]", tokenType: .OtherMethodNames, captureGroup: 1)
        var methodCallParts = JLToken(pattern: "(\\w+)\\]", tokenType: .OtherMethodNames, captureGroup: 1)
        var otherClassNames = JLToken(pattern: "\\b[A-Z]{3}[a-zA-Z]*\\b", tokenType: .OtherClassNames)
        
        // http://www.learn-cocos2d.com/2011/10/complete-list-objectivec-20-compiler-directives/
        var objcKeywords = JLToken(pattern: "@(class|defs|protocol|required|optional|interface|public|package|protected|private|property|end|implementation|synthesize|dynamic|end|throw|try|catch|finally|synchronized|autoreleasepool|selector|encode|compatibility_alias)\\b", tokenType: .Keyword )
        init() {
            super.init()
            lineScope.subscopes += [dotNotation, methodCalls, methodCallParts, objcKeywords, otherClassNames]
        }
    }
}


// Operator for "set subscopes". Can be nested, since it returns the left value.
operator infix => { associativity right}
func => (left: JLScope, right: [JLScope]) -> JLScope {
    left.subscopes = right
    return left
}



