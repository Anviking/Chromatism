//
//  JLTokenizer.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-17.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

class JLTokenizer: NSObject {
    
    var language: JLLanguage
    
    var colorDictionary = JLColorTheme.Default.dictionary
    func setColorTheme(theme: JLColorTheme) { colorDictionary = theme.dictionary }
    
    init(language: JLLanguage) {
        self.language = language
    }
    
    func tokenizeAttributedString(attributedString: NSMutableAttributedString) {
        language.lineScope.editedIndexSet = nil
        language.documentScope.perform(attributedString)
    }
    
    func tokenizeAttributedString(attributedString: NSMutableAttributedString, editedLineRange: NSRange) {
        language.lineScope.editedIndexSet = NSIndexSet(indexesInRange: editedLineRange)
        language.documentScope.perform(attributedString)
    }
}

extension JLTokenizer: NSTextStorageDelegate {
    func textStorage(textStorage: NSTextStorage!, willProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        
    }
    
    func textStorage(textStorage: NSTextStorage!, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        let editedLineRange = textStorage.string.bridgeToObjectiveC().lineRangeForRange(editedRange)
        tokenizeAttributedString(textStorage, editedLineRange: editedLineRange)
    }
}