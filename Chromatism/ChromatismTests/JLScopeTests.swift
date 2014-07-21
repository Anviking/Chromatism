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
        var attributedString = "[Hello World]".text
        let colors = JLColorTheme.Default.dictionary
        let documentScope = JLScope()
        
        // Setup scopes
        documentScope.colorDictionary = colors
        
        let lineScope = JLScope(scope: documentScope)
        lineScope.clearWithTextColorBeforePerform = true

        
        documentScope => [
            JLToken(pattern: "\\[.*\\]", tokenType: .Comment),
            lineScope => [
                JLToken(pattern: "World", tokenType: .Keyword)
            ]
        ]
        
        documentScope.perform(attributedString)
        XCTAssertEqualObjects("[Hello World]".comment, attributedString)
        
        attributedString.deleteCharactersInRange(NSMakeRange(attributedString.length - 1, 1))
        documentScope.perform(attributedString)
        XCTAssertEqualObjects("[Hello ".text + "World".keyword, attributedString)
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}

extension String {
    // I'm lazy
    var comment: NSMutableAttributedString { return attributedStringWithTokenType(.Comment) }
    var text: NSMutableAttributedString { return attributedStringWithTokenType(.Text) }
    var keyword: NSMutableAttributedString { return attributedStringWithTokenType(.Keyword) }
    
    func attributedStringWithTokenType(token: JLTokenType) -> NSMutableAttributedString {
        let colors = JLColorTheme.Default.dictionary
        return NSMutableAttributedString(string: self, attributes: [NSForegroundColorAttributeName:colors[token]! ])
    }
}

@infix func + (left: NSAttributedString, right: NSAttributedString) -> NSMutableAttributedString {
    let string = left.mutableCopy() as NSMutableAttributedString
    string.appendAttributedString(right)
    return string
}
