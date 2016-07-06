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
    
    let string = String(contentsOfURL: Bundle(for: ObjectiveC.self).urlForResource("demo", withExtension: "txt")!, encoding: String.Encoding.utf8)
    
    var attributedString: NSMutableAttributedString!
    var language: JLDocumentScope
    
    override func setUp() {
        super.setUp()
        attributedString = NSMutableAttributedString(string: string)
        language = Language.objectiveC.documentScope()
        language.documentScope.cascadeAttributedString(attributedString)
        language.documentScope.theme = .default
    }
    
    func testEverything() {
        measure {
            self.language.documentScope.perform()
        }
    }
    
    func testSquareBrackets() {
        measure {
            self.language.squareBrackets.perform()
        }
    }
    
    func testBlockComments() {
        measure {
            self.language.blockComments.perform()
        }
    }
    
    func testLineComments() {
        measure {
            self.language.lineComments.perform()
        }
    }
    
    func testPreprocessor() {
        measure {
            self.language.preprocessor.perform()
        }
    }
    
    func testStrings() {
        measure {
            self.language.strings.perform()
        }
    }
    
    func testNumbers() {
        measure {
            self.language.numbers.perform()
        }
    }
    
    func testFunctions() {
        measure {
            self.language.functions.perform()
        }
    }
    
    func testKeywords() {
        measure {
            self.language.keywords.perform()
        }
    }
    
    func testDotNotation() {
        measure {
            self.language.dotNotation.perform()
        }
    }
    
    func testObjectiveCKeywords() {
        measure {
            self.language.objcKeywords.perform()
        }
    }
}
