//
//  JLScopeTests.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-14.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit
import XCTest

class JLScopeTests: XCTestCase {
    
    var attributedString = NSMutableAttributedString(string: "Hello World")

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
        XCTAssert(true, "Pass")
        
        let scopeA = JLScope(attributedString: attributedString)
        let scopeB = JLScope(attributedString: attributedString)
        
        // Subscopes of Scope A
        let subscopeA = JLScope(scope: scopeA)
        let subscopeB = JLScope(scope: scopeA)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
