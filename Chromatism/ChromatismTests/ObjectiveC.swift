//
//  JLLanguageTests.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-21.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit
import XCTest

let url = NSBundle(forClass: ObjectiveC.self).URLForResource("demo", withExtension: "txt")
let string = NSString(contentsOfURL: url, encoding: NSUTF8StringEncoding, error: nil)

class ObjectiveC: XCTestCase {
    
    var attributedString: NSMutableAttributedString!
    var language: JLLanguage.ObjectiveC!
    
    override func setUp() {
        super.setUp()
        attributedString = NSMutableAttributedString(string: string)
        language = JLLanguage.ObjectiveC()
        language.documentScope.theme = .Default
    }
    
    func testEverything() {
        println()
        measureBlock {
            self.language.documentScope.perform(self.attributedString)
        }
    }
    
    func testBlockComments() {
        measureBlock {
            self.language.blockComments.perform(self.attributedString)
        }
    }
    
    func testMethodCalls() {
        measureBlock {
            self.language.methodCalls.perform(self.attributedString)
        }
    }
    
    func testLineComments() {
        measureBlock {
            self.language.lineComments.perform(self.attributedString)
        }
    }
    
    func testPreprocessor() {
        measureBlock {
            self.language.preprocessor.perform(self.attributedString)
        }
    }
    
    func testStrings() {
        measureBlock {
            self.language.strings.perform(self.attributedString)
        }
    }
    
    func testNumbers() {
        measureBlock {
            self.language.numbers.perform(self.attributedString)
        }
    }
    
    func testFunctions() {
        measureBlock {
            self.language.functions.perform(self.attributedString)
        }
    }
    
    func testKeywords() {
        measureBlock {
            self.language.keywords.perform(self.attributedString)
        }
    }
    
    func testDotNotation() {
        measureBlock {
            self.language.dotNotation.perform(self.attributedString)
        }
    }
    
    func testObjectiveCKeywords() {
        measureBlock {
            self.language.objcKeywords.perform(self.attributedString)
        }
    }
}
