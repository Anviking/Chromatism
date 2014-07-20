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
    
    let blue = UIColor.blueColor()
    let green = UIColor.greenColor()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLaziness() {
        var attributedString = NSMutableAttributedString(string: "[Hello World]")
        let colors = JLColorTheme.Default.dictionary
        let documentScope = JLScope()
        documentScope.colorDictionary = colors
        JLToken(pattern: "\\[.*\\]", tokenType: .Comment, scope: documentScope)
        
        let lineScope = JLScope(scope: documentScope)
        lineScope.clearWithTextColorBeforePerform = true
        JLToken(pattern: "World", tokenType: .Keyword, scope: lineScope)
        
        documentScope.perform(attributedString)
        attributedString.expect(.Default, expectations:[("[Hello World]", .Comment)])
        
        attributedString.deleteCharactersInRange(NSMakeRange(attributedString.length - 1, 1))
        
        documentScope.perform(attributedString)
        
        attributedString.expect(.Default, expectations:[("[Hello ", .Text), ("World", .Keyword)])
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
