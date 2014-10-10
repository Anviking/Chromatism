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
    
    var attributedString = "//Hello World!\nHello".text
    let commentColor = JLColorTheme.Default.dictionary[.Comment]!
    let worldColor = JLColorTheme.Default.dictionary[.Keyword]!
}