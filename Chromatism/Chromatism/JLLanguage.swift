//
//  JLLanguage.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-17.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

public class JLLanguage {
    let documentScope = JLDocumentScope()
    
    public class C: JLLanguage {
        
        var blockComments = JLNestedToken(incrementingPattern: "/\\*", decrementingPattern: "\\*/", tokenTypes: [.All: .Comment])
        var lineComments = JLToken(pattern: "//(.*)", tokenTypes: .Comment)
        var preprocessor = JLToken(pattern: "^#.*+$", tokenTypes: .Preprocessor)
        var strings = JLToken(pattern: "(\"|@\")[^\"\\n]*(@\"|\")", tokenTypes: .String)
        var angularImports = JLToken(pattern: "<.*?>", tokenTypes: .String)
        var numbers = JLToken(pattern: "(?<=\\s)\\d+", tokenTypes: .Number)
        var functions = JLToken(pattern: "\\w+\\s*(?>\\(.*\\)", tokenTypes: .OtherMethodNames)
        
        var keywords = JLToken(keywords: "true false yes no YES TRUE FALSE bool BOOL nil id void self NULL if else strong weak nonatomic atomic assign copy typedef enum auto break case const char continue do default double extern float for goto int long register return short signed sizeof static struct switch typedef union unsigned volatile while nonatomic atomic nonatomic readonly super".componentsSeparatedByString(" "), tokenTypes: .Keyword)
        
        public init() {
            super.init()
            documentScope[
                blockComments,
                lineComments,
                preprocessor[strings, angularImports],
                strings,
                numbers,
                functions,
                keywords
            ]
        }
    }
    
    public class ObjectiveC: C {
        var dotNotation = JLToken(pattern: "\\.\\w+", tokenTypes: .OtherMethodNames)
        var otherClassNames = JLToken(pattern: "\\b[A-Z]{3}[a-zA-Z]*\\b", tokenTypes: .OtherClassNames)
        
        // http://www.learn-cocos2d.com/2011/10/complete-list-objectivec-20-compiler-directives/
        var objcKeywords = JLToken(pattern: "@(class|defs|protocol|required|optional|interface|public|package|protected|private|property|end|implementation|synthesize|dynamic|end|throw|try|catch|finally|synchronized|autoreleasepool|selector|encode|compatibility_alias)\\b", tokenTypes: .Keyword )
        var methodCalls = JLNestedToken(incrementingPattern: "(?<!\\@)\\[", decrementingPattern: "[\\s:|\\]]([\\d\\w]+)\\]", tokenTypes: [.Decrementing(1): .OtherMethodNames])
        
        public init() {
            super.init()
            documentScope[
                blockComments,
                methodCalls,
                lineComments,
                preprocessor[strings, angularImports],
                strings,
                numbers,
                functions,
                keywords,
                dotNotation,
                objcKeywords,
                otherClassNames
            ]
        }
    }
}


