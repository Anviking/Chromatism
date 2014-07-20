//
//  JLTokenizer.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-17.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

protocol JLTokenizerScopeDataSource {
    var documentScope: JLScope {get}
    var lineScope: JLScope {get}
}

class JLTokenizer: NSObject {
    
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
    
    convenience init (colorDictionary: Dictionary<JLTokenType, UIColor>, languageDataSource: JLLanguageDataSource) {
        self.init(colorDictionary: colorDictionary, documentScope: languageDataSource.documentScope, lineScope: languageDataSource.lineScope)
    }
    
    convenience init(language: JLLanguage, theme: JLColorTheme) {
        let dataSource = language.languageDataSource
        self.init(colorDictionary: theme.dictionary, documentScope: dataSource.documentScope, lineScope: dataSource.lineScope)
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
    func textStorage(textStorage: NSTextStorage!, willProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        
    }
    
    func textStorage(textStorage: NSTextStorage!, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        let editedLineRange = textStorage.string.bridgeToObjectiveC().lineRangeForRange(editedRange)
        tokenizeAttributedString(textStorage, editedLineIndexSet: NSIndexSet(indexesInRange: editedLineRange))
    }
}