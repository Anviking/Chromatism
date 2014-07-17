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
    
    var attributedString = NSMutableAttributedString(string: "//Hello World!\nHello", attributes: [NSForegroundColorAttributeName: UIColor.blackColor(), NSFontAttributeName: UIFont.systemFontOfSize(15)])
    let commentColor = UIColor.greenColor()
    let worldColor = UIColor.blueColor()
    

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let documentScope = JLScope(attributedString: attributedString)
        let comment = JLToken(pattern: "//(.*)", color: commentColor, scope: documentScope, contentCaptureGroup: 1)
        let world = JLToken(pattern: "World", color: worldColor, scope: comment)
        documentScope.perform()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testContentCaptureGroup() {
        let tester = NSAttributedStringTester(attributedString: attributedString)
        tester.expect("//Hello ", toHaveColor: commentColor)
        tester.expect("World", toHaveColor: worldColor)
        tester.expect("!", toHaveColor: commentColor)
        tester.expect("\nHello", toHaveColor: UIColor.blackColor())
    }

    func testTokenizationPerformance() {
        // This is an example of a performance test case.
        self.measureBlock() {
            
        }
    }

}

class NSAttributedStringTester {
    init(attributedString: NSAttributedString) {
        self.attributedString = attributedString
    }
    
    var index = 0
    var attributedString: NSAttributedString
    func expect(string: String, toHaveColor color: UIColor) {
                println("Index: \(index)")
        println("String:\(attributedString.string)")
        println("Other Range: \(NSMakeRange(index, attributedString.length-index))")
        let range = attributedString.string.bridgeToObjectiveC().rangeOfString(string, options: nil, range: NSMakeRange(index, attributedString.length-index))
        if range.location == NSNotFound {
            XCTFail("Could not find:\"\(string)\" in attributed string")
        }
        println("Range:\(range)")
        expect(range, toHaveColor: color)
        index = NSMaxRange(range)
    }
    
    func expect(range: NSRange, toHaveColor color: UIColor) {
        var effectiveRangePointer = NSRangePointer.alloc(sizeof(NSRange))
        XCTAssertEqualObjects(attributedString.attribute(NSForegroundColorAttributeName, atIndex: index, effectiveRange: effectiveRangePointer) as UIColor, color, "")
        
        let effectiveRange = effectiveRangePointer.memory
        let value = NSEqualRanges(effectiveRange, range)
        XCTAssertTrue(value, "range: \(range) and effectiveRange: \(effectiveRange) are not equal")
    }
}
