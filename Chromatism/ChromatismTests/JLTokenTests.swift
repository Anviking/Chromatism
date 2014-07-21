//
//  JLTokenTests.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-14.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit
import XCTest

class JLTokenTests: XCTestCase {
    
    var attributedString = "//Hello World!\nHello".text
    let commentColor = JLColorTheme.Default.dictionary[.Comment]!
    let worldColor = JLColorTheme.Default.dictionary[.Keyword]!
    

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let documentScope = JLScope()
        documentScope.colorDictionary = JLColorTheme.Default.dictionary
        let comment = JLToken(pattern: "//(.*)", tokenType: .Comment)
        comment.contentCaptureGroup = 1
        let world = JLToken(pattern: "World", tokenType: .Keyword)
        
        documentScope => [ comment => [world] ]
        
        documentScope.perform(attributedString)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testContentCaptureGroup() {
        let expectedString = "//Hello ".comment + "World".keyword + "!".comment + "\nHello".text
        XCTAssertEqualObjects(expectedString, attributedString)
    }

    func testTokenizationPerformance() {
        // This is an example of a performance test case.
        self.measureBlock() {
            
        }
    }

}