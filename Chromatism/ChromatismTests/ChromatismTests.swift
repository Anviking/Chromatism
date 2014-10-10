//
//  ChromatismTests.swift
//  ChromatismTests
//
//  Created by Johannes Lund on 2014-07-14.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit
import XCTest

class ChromatismTests: XCTestCase {
    
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
    }
    
    func testIndexSetIntersection() {
        // This is an example of a performance test case.
        
        let set1 = NSMutableIndexSet(indexesInRange: NSMakeRange(0, 200))
        set1.addIndexesInRange(NSMakeRange(400, 200))
        
        let set2 = NSMutableIndexSet(indexesInRange: NSMakeRange(100, 200))
        set2.addIndexesInRange(NSMakeRange(300, 200))
        
        let set3 = NSMutableIndexSet(indexesInRange: NSMakeRange(100, 100))
        set3.addIndexesInRange(NSMakeRange(400, 100))
        
        self.measureBlock() {
            // Put the code you want to measure the time of here.
            for _ in 1...1000 {
                let finalSet = set1.intersectionWithSet(set2)
                XCTAssertEqual(set3, finalSet, "")
            }
        }
    }
    
}
