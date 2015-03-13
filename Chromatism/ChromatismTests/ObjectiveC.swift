//
//  JLLanguageTests.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-21.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit
import XCTest

class ObjectiveC: XCTestCase {
    
    let string = NSString(contentsOfURL: NSBundle(forClass: ObjectiveC.self).URLForResource("demo", withExtension: "txt")!, encoding: NSUTF8StringEncoding, error: nil) as String
    
    var attributedString: NSMutableAttributedString!
    var language: JLLanguage.ObjectiveC!
    
    override func setUp() {
        super.setUp()
        attributedString = NSMutableAttributedString(string: string)
        language = JLLanguage.ObjectiveC()
        language.documentScope.cascadeAttributedString(attributedString)
        language.documentScope.theme = .Default
    }
    
    func testEverything() {
        measureBlock {
            self.language.documentScope.perform()
        }
    }
    
    func testSquareBrackets() {
        measureBlock {
            self.language.squareBrackets.perform()
        }
    }
    
    func testBlockComments() {
        measureBlock {
            self.language.blockComments.perform()
        }
    }
    
    func testLineComments() {
        measureBlock {
            self.language.lineComments.perform()
        }
    }
    
    func testPreprocessor() {
        measureBlock {
            self.language.preprocessor.perform()
        }
    }
    
    func testStrings() {
        measureBlock {
            self.language.strings.perform()
        }
    }
    
    func testNumbers() {
        measureBlock {
            self.language.numbers.perform()
        }
    }
    
    func testFunctions() {
        measureBlock {
            self.language.functions.perform()
        }
    }
    
    func testKeywords() {
        measureBlock {
            self.language.keywords.perform()
        }
    }
    
    func testDotNotation() {
        measureBlock {
            self.language.dotNotation.perform()
        }
    }
    
    func testObjectiveCKeywords() {
        measureBlock {
            self.language.objcKeywords.perform()
        }
    }
}
