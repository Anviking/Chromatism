//
//  JLLanguage.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-17.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

public enum JLLanguageType {
    case C, ObjectiveC, Swift, Other(JLLanguage)
    
    
    /**
        Warning: Will probably be changed in the future to take arguments
    
        :returns: A functional JLLanguage object.
    */
    func language() -> JLLanguage {
        switch self {
        case C:                     return JLLanguage.C()
        case ObjectiveC:            return JLLanguage.ObjectiveC()
        case Swift:                 return JLLanguage.Swift()
        case Other(let language):   return language
        default:                    return JLLanguage()
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
        var blockComments = JLTokenizingScope(incrementingPattern: "/\\*", decrementingPattern: "\\*/", tokenType: .Comment, hollow: false)
        var lineComments = JLToken(pattern: "//(.*)", tokenTypes: .Comment)
        var preprocessor = JLToken(pattern: "^#.*+$", tokenTypes: .Preprocessor)
        var strings = JLToken(pattern: "(\"|@\")[^\"\\n]*(@\"|\")", tokenTypes: .String)
        var angularImports = JLToken(pattern: "<.*?>", tokenTypes: .String)
        var numbers = JLToken(pattern: "(?<=\\s)\\d+", tokenTypes: .Number)
        var functions = JLToken(pattern: "\\w+\\s*(?>\\(.*\\)", tokenTypes: .OtherMethodNames)
        
        var keywords = JLToken(keywords: "true false YES NO TRUE FALSE bool BOOL nil id void self NULL if else strong weak nonatomic atomic assign copy typedef enum auto break case const char continue do default double extern float for goto int long register return short signed sizeof static struct switch typedef union unsigned volatile while nonatomic atomic nonatomic readonly super".componentsSeparatedByString(" "), tokenTypes: .Keyword)
        
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
        var squareBrackets: JLTokenizingScope
        var dictionaryLiteral = JLTokenizingScope(incrementingPattern: "\\@\\{", decrementingPattern: "\\}", tokenType: .OtherMethodNames, hollow: true)
        
        public init() {
            let openBracket = JLTokenizingScope.Token(pattern: "\\[", delta: 1)
            let closeBracket = JLTokenizingScope.Token(pattern: "\\]", delta: -1)
            let arrayOpen = JLTokenizingScope.Token(pattern: "\\@\\[", delta: 1)
            
            let method = JLNestedScope(incrementingToken: openBracket, decrementingToken: closeBracket, tokenType: .None, hollow: true)
            let arrayLiteral = JLNestedScope(incrementingToken: arrayOpen, decrementingToken: closeBracket, tokenType: .OtherMethodNames, hollow: true)
            squareBrackets = JLTokenizingScope(tokens: [arrayOpen, openBracket, closeBracket])
            
            super.init()
            
            documentScope[
                blockComments,
                dictionaryLiteral,
                lineComments,
                preprocessor[strings, angularImports],
                strings,
                squareBrackets[arrayLiteral, method],
                numbers,
                functions,
                keywords,
                dotNotation,
                objcKeywords,
                otherClassNames
            ]
        }
    }
    
    public class Swift: JLLanguage {
        var blockComments = JLTokenizingScope(incrementingPattern: "/\\*", decrementingPattern: "\\*/", tokenType: .Comment, hollow: false)
        var lineComments = JLToken(pattern: "//(.*)", tokenTypes: .Comment)
        var keywords = JLToken(pattern: "\\b(class|protocol|init|required|@optional|public|internal|private)\\b", tokenTypes: .Keyword )
        var swiftTypes = JLToken(pattern: "\\b(Array|AutoreleasingUnsafePointer|BidirectionalReverseView|Bit|Bool|CFunctionPointer|COpaquePointer|CVaListPointer|Character|CollectionOfOne|ConstUnsafePointer|ContiguousArray|Dictionary|DictionaryGenerator|DictionaryIndex|Double|EmptyCollection|EmptyGenerator|EnumerateGenerator|FilterCollectionView|FilterCollectionViewIndex|FilterGenerator|FilterSequenceView|Float|Float80|FloatingPointClassification|GeneratorOf|GeneratorOfOne|GeneratorSequence|HeapBuffer|HeapBuffer|HeapBufferStorage|HeapBufferStorageBase|ImplicitlyUnwrappedOptional|IndexingGenerator|Int|Int16|Int32|Int64|Int8|IntEncoder|LazyBidirectionalCollection|LazyForwardCollection|LazyRandomAccessCollection|LazySequence|Less|MapCollectionView|MapSequenceGenerator|MapSequenceView|MirrorDisposition|ObjectIdentifier|OnHeap|Optional|PermutationGenerator|QuickLookObject|RandomAccessReverseView|Range|RangeGenerator|RawByte|Repeat|ReverseBidirectionalIndex|ReverseRandomAccessIndex|SequenceOf|SinkOf|Slice|StaticString|StrideThrough|StrideThroughGenerator|StrideTo|StrideToGenerator|String|Index|UTF8View|Index|UnicodeScalarView|IndexType|GeneratorType|UTF16View|UInt|UInt16|UInt32|UInt64|UInt8|UTF16|UTF32|UTF8|UnicodeDecodingResult|UnicodeScalar|Unmanaged|UnsafeArray|UnsafeArrayGenerator|UnsafeMutableArray|UnsafePointer|VaListBuilder|Header|Zip2|ZipGenerator2)\\b", tokenTypes: .OtherMethodNames)
        
        public init() {

            super.init()
            documentScope[
                blockComments,
                lineComments,
                keywords,
                swiftTypes
            ]
        }
    }
}


