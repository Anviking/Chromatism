//
//  JLLanguageTests.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-21.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit
import XCTest

let url = Bundle(for: ObjectiveC.self).url(forResource: "demo", withExtension: "txt")!

class ObjectiveC: XCTestCase {

    let string = try! String(contentsOf: url)
    
    var attributedString: NSMutableAttributedString!
    var scope: JLDocumentScope
    
    override func setUp() {
        super.setUp()
        attributedString = NSMutableAttributedString(string: string)
        scope = Language.objectiveC.documentScope()
        scope.cascadeAttributedString(attributedString)
        scope.theme = .default
    }
    
    func testEverything() {
        measure {
            self.scope.perform()
        }
    }
    /*
    func testSquareBrackets() {
        measure {
            scope.squareBrackets.perform()
        }
    }
    
    func testBlockComments() {
        measure {
            scope.blockComments.perform()
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
 */
}
