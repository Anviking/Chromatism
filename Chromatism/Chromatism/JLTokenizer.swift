//
//  JLTokenizer.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-17.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

public class JLTokenizer: NSObject {
    
    var documentScope: JLScope
    var lineScope: JLScope
    
    var colorDictionary: Dictionary<JLTokenType, UIColor> {
    didSet {
        documentScope.colorDictionary = colorDictionary; lineScope.colorDictionary = colorDictionary
    }
    }
    
    init (colorDictionary: Dictionary<JLTokenType, UIColor>, documentScope: JLScope, lineScope: JLScope) {
        documentScope.colorDictionary = colorDictionary
        lineScope.colorDictionary = colorDictionary
        
        self.colorDictionary = colorDictionary
        self.documentScope = documentScope
        self.lineScope = lineScope
    }
    
    convenience init(language: JLLanguage, theme: JLColorTheme) {
        self.init(colorDictionary: theme.dictionary, documentScope: language.documentScope, lineScope: language.lineScope)
    }

    func tokenizeAttributedString(attributedString: NSMutableAttributedString) {
        tokenizeAttributedString(attributedString, editedLineIndexSet: nil)
    }
    
    func tokenizeAttributedString(attributedString: NSMutableAttributedString, editedLineIndexSet: NSIndexSet?) {
        lineScope.editedIndexSet = editedLineIndexSet
        documentScope.perform(attributedString)
    }

}

extension JLTokenizer: NSTextStorageDelegate {
    public func textStorage(textStorage: NSTextStorage!, willProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
    }
  public   
    func textStorage(textStorage: NSTextStorage!, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {

        if editedMask & NSTextStorageEditActions.EditedCharacters {
            documentScope.cascade { $0.attributedStringDidChange(editedRange, delta: delta) }
            let editedLineRange = textStorage.string.bridgeToObjectiveC().lineRangeForRange(editedRange)
            tokenizeAttributedString(textStorage, editedLineIndexSet: NSIndexSet(indexesInRange: editedLineRange))
        }
    }
}