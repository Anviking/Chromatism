//
//  JLKeywordScopeTests.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-08-02.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit
import XCTest

class JLKeywordScopeTests: XCTestCase {
    
    let string = NSString(contentsOfURL: NSBundle(forClass: ObjectiveC.self).URLForResource("demo", withExtension: "txt")!, encoding: NSUTF8StringEncoding, error: nil)
    var attributedString: NSMutableAttributedString!
    
    var keywords = "Array|AutoreleasingUnsafePointer|BidirectionalReverseView|Bit|Bool|CFunctionPointer|COpaquePointer|CVaListPointer|Character|CollectionOfOne|ConstUnsafePointer|ContiguousArray|Dictionary|DictionaryGenerator|DictionaryIndex|Double|EmptyCollection|EmptyGenerator|EnumerateGenerator|FilterCollectionView|FilterCollectionViewIndex|FilterGenerator|FilterSequenceView|Float|Float80|FloatingPointClassification|GeneratorOf|GeneratorOfOne|GeneratorSequence|HeapBuffer|HeapBuffer|HeapBufferStorage|HeapBufferStorageBase|ImplicitlyUnwrappedOptional|IndexingGenerator|Int|Int16|Int32|Int64|Int8|IntEncoder|LazyBidirectionalCollection|LazyForwardCollection|LazyRandomAccessCollection|LazySequence|Less|MapCollectionView|MapSequenceGenerator|MapSequenceView|MirrorDisposition|ObjectIdentifier|OnHeap|Optional|PermutationGenerator|QuickLookObject|RandomAccessReverseView|Range|RangeGenerator|RawByte|Repeat|ReverseBidirectionalIndex|ReverseRandomAccessIndex|SequenceOf|SinkOf|Slice|StaticString|StrideThrough|StrideThroughGenerator|StrideTo|StrideToGenerator|String|Index|UTF8View|Index|UnicodeScalarView|IndexType|GeneratorType|UTF16View|UInt|UInt16|UInt32|UInt64|UInt8|UTF16|UTF32|UTF8|UnicodeDecodingResult|UnicodeScalar|Unmanaged|UnsafeArray|UnsafeArrayGenerator|UnsafeMutableArray|UnsafePointer|VaListBuilder|Header|Zip2|ZipGenerator2".componentsSeparatedByString("|")

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        attributedString = NSMutableAttributedString(string: string)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }

    func testOrdinaryPattern() {
        // This is an example of a performance test case.
        let pattern = "\\b(" + join("|", keywords) + ")\\b"
        let scope = JLRegexScope(pattern: pattern, tokenTypes: .Keyword)
        scope.attributedString = attributedString
        scope.theme = .Default
        self.measureBlock() {
            scope.perform()
        }
    }
    
    func testKeywordPattern() {
        // This is an example of a performance test case.
        let scope = JLKeywordScope(keywords: keywords, tokenType: .Keyword)
        scope.attributedString = attributedString
        scope.theme = .Default
        self.measureBlock() {
            scope.perform()
        }
    }

}
