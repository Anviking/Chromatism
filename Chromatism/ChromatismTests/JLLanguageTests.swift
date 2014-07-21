//
//  JLLanguageTests.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-21.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit
import XCTest

class JLLanguageTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        let a = JLScope()
        let b = JLScope()
        let c = JLScope()
        let d = JLScope()
        let e = JLScope()
        let f = JLScope()
        let g = JLScope()
        let h = JLScope()
        
        a => [
            b => [c,d],
            e => [f],
            g,
            h
        ]
        
        XCTAssertEqualObjects(a.subscopes, [b,e,g,h], "")
        XCTAssertEqualObjects(b.subscopes, [c,d], "")
        XCTAssertEqualObjects(e.subscopes, [f], "")
        XCTAssertEqual(g.subscopes.count, 0, "")
        XCTAssertEqual(h.subscopes.count, 0, "")
        
    }
}
