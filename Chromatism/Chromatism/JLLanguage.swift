//
//  JLLanguage.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-17.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

public enum JLLanguageType {
    case c, objectiveC, swift, other(JLLanguage)
    
    
    /**
     Warning: Will probably be changed in the future to take arguments
     
     - returns: A functional JLLanguage object.
     */
    func language() -> JLLanguage {
        switch self {
        case c:                     return JLLanguage.C()
        case objectiveC:            return JLLanguage.ObjectiveC()
        case swift:                 return JLLanguage.Swift()
        case other(let language):   return language
        }
    }
    
    /* Does not appear to be working yet
     var languageClass: JLLanguage.Type {
     switch self {
     case C:                     return JLLanguage.C.self
     case ObjectiveC:            return JLLanguage.ObjectiveC.self
     case Other(let language):   return language
     default:                    return JLLanguage.self
     }
     }
     */
}

public class JLLanguage {
    let documentScope = JLDocumentScope()
    
    public required init() {
        
    }
    
    public class C: JLLanguage {
        var blockComments = JLTokenizingScope(incrementingPattern: "/\\*", decrementingPattern: "\\*/", tokenType: .comment, hollow: false)
        var lineComments = JLRegexScope(pattern: "//(.*)", tokenTypes: .comment)
        var preprocessor = JLRegexScope(pattern: "^#.*+$", tokenTypes: .preprocessor)
        var strings = JLRegexScope(pattern: "(\"|@\")[^\"\\n]*(@\"|\")", tokenTypes: .string)
        var angularImports = JLRegexScope(pattern: "<.*?>", tokenTypes: .string)
        var numbers = JLRegexScope(pattern: "(?<=\\s)\\d+", tokenTypes: .number)
        var functions = JLRegexScope(pattern: "\\w+\\s*(?>\\(.*\\))", tokenTypes: .otherMethodNames)
        
        var keywords = JLKeywordScope(keywords: "true false YES NO TRUE FALSE bool BOOL nil id void self NULL if else strong weak nonatomic atomic assign copy typedef enum auto break case const char continue do default double extern float for goto int long register return short signed sizeof static struct switch typedef union unsigned volatile while nonatomic atomic nonatomic readonly super", tokenType: .keyword)
        
        public required init() {
            super.init()
            _ = documentScope[
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
        var dotNotation = JLRegexScope(pattern: "\\.\\w+", tokenTypes: .otherProperties)
        
        // Note about project class names: When symbolication is supported this pattern should be changed to .OtherClassNames
        var projectClassNames = JLRegexScope(pattern: "\\b[A-Z]{3}[a-zA-Z]*\\b", tokenTypes: .projectClassNames)
        var NSUIClassNames = JLRegexScope(pattern: "\\b(NS|UI)[A-Z][a-zA-Z]+\\b", tokenTypes: .otherClassNames)
        // http://www.learn-cocos2d.com/2011/10/complete-list-objectivec-20-compiler-directives/
        var objcKeywords = JLKeywordScope(keywords: "class defs protocol required optional interface public package protected private property end implementation synthesize dynamic end throw try catch finally synchronized autoreleasepool selector encode compatibility_alias".components(separatedBy: " "), prefix:"@", suffix:"\\b", tokenType: .keyword)
        var squareBrackets: JLTokenizingScope
        var dictionaryLiteral = JLTokenizingScope(incrementingPattern: "\\@\\{", decrementingPattern: "\\}", tokenType: .otherMethodNames, hollow: true)
        var methodCallArguments = JLRegexScope(pattern: "\\b\\w+(:|(?=\\]))", tokenTypes: .otherMethodNames)
        
        public required init() {
            let openBracket = JLTokenizingScope.Token(pattern: "\\[", delta: 1)
            let closeBracket = JLTokenizingScope.Token(pattern: "\\]", delta: -1)
            let arrayOpen = JLTokenizingScope.Token(pattern: "\\@\\[", delta: 1)
            
            let method = JLNestedScope(incrementingToken: openBracket, decrementingToken: closeBracket, tokenType: .none, hollow: false)
            let arrayLiteral = JLNestedScope(incrementingToken: arrayOpen, decrementingToken: closeBracket, tokenType: .otherMethodNames, hollow: true)
            squareBrackets = JLTokenizingScope(tokens: [arrayOpen, openBracket, closeBracket])
            
            super.init()
            
            _ = documentScope[
                blockComments,
                dictionaryLiteral,
                lineComments,
                preprocessor[strings, angularImports],
                squareBrackets[
                    arrayLiteral,
                    method[
                        strings,
                        numbers,
                        functions,
                        keywords,
                        dotNotation,
                        objcKeywords,
                        NSUIClassNames,
                        projectClassNames
                    ]
                ],
                strings,
                numbers,
                functions,
                keywords,
                dotNotation,
                objcKeywords,
                NSUIClassNames,
                projectClassNames
            ]
        }
    }
    
    public class Swift: JLLanguage {
        var blockComments = JLTokenizingScope(incrementingPattern: "/\\*", decrementingPattern: "\\*/", tokenType: .comment, hollow: false)
        var lineComments = JLRegexScope(pattern: "//(.*)", tokenTypes: .comment)
        var keywords = JLKeywordScope(keywords: "class protocol init required public internal import private nil super var let func override deinit return true false", tokenType: .keyword)
        var atKeywords = JLKeywordScope(keywords: ["optional", "UIApplicationMain"], prefix: "@", suffix: "\\b", tokenType: .keyword)
        var projectClassNames = JLRegexScope(pattern: "\\b[A-Z]{3}[a-zA-Z]+\\b", tokenTypes: .projectClassNames)
        var NSUIClassNames = JLRegexScope(pattern: "\\b(NS|UI)[A-Z][a-zA-Z]+\\b", tokenTypes: .otherClassNames)
        var swiftTypes = JLKeywordScope(keywords: "Array AutoreleasingUnsafePointer BidirectionalReverseView Bit Bool CFunctionPointer COpaquePointer CVaListPointer Character CollectionOfOne ConstUnsafePointer ContiguousArray Dictionary DictionaryGenerator DictionaryIndex Double EmptyCollection EmptyGenerator EnumerateGenerator FilterCollectionView FilterCollectionViewIndex FilterGenerator FilterSequenceView Float Float80 FloatingPointClassification GeneratorOf GeneratorOfOne GeneratorSequence HeapBuffer HeapBuffer HeapBufferStorage HeapBufferStorageBase ImplicitlyUnwrappedOptional IndexingGenerator Int Int16 Int32 Int64 Int8 IntEncoder LazyBidirectionalCollection LazyForwardCollection LazyRandomAccessCollection LazySequence Less MapCollectionView MapSequenceGenerator MapSequenceView MirrorDisposition ObjectIdentifier OnHeap Optional PermutationGenerator QuickLookObject RandomAccessReverseView Range RangeGenerator RawByte Repeat ReverseBidirectionalIndex Printable ReverseRandomAccessIndex SequenceOf SinkOf Slice StaticString StrideThrough StrideThroughGenerator StrideTo StrideToGenerator String Index UTF8View Index UnicodeScalarView IndexType GeneratorType UTF16View UInt UInt16 UInt32 UInt64 UInt8 UTF16 UTF32 UTF8 UnicodeDecodingResult UnicodeScalar Unmanaged UnsafeArray UnsafeArrayGenerator UnsafeMutableArray UnsafePointer VaListBuilder Header Zip2 ZipGenerator2", tokenType: .otherClassNames)
        var dotNotation = JLRegexScope(pattern: "\\.\\w+", tokenTypes: .otherProperties)
        var functions = JLRegexScope(pattern: "\\b(println)(?=\\()", tokenTypes: .otherMethodNames)
        var strings = JLRegexScope(pattern: "(\"|@\")[^\"\\n]*(@\"|\")", tokenTypes: .string)
        var numbers = JLRegexScope(pattern: "(?<=\\s)\\d+", tokenTypes: .number)
        var interpolation = JLRegexScope(pattern: "(?<=\\\\\\().*?(?=\\))", tokenTypes: .text)
        
        
        required   public init() {
            
            super.init()
            _ = documentScope[
                    blockComments,
                    lineComments,
                    keywords,
                    atKeywords,
                    strings[
                        interpolation
                    ],
                    numbers,
                    swiftTypes,
                    dotNotation,
                    NSUIClassNames,
                    functions,
                    projectClassNames
            ]
        }
    }
}


