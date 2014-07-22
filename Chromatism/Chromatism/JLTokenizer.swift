//
//  JLTokenizer.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-17.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

public class JLTokenizer: NSObject {
    
    let documentScope: JLScope
    let lineScope: JLScope

    public var theme: JLColorTheme { didSet { documentScope.theme = theme }}
    
    public init (documentScope: JLScope, lineScope: JLScope, theme: JLColorTheme) {
        documentScope.theme = theme
        self.theme = theme
        self.documentScope = documentScope
        self.lineScope = lineScope
    }
    
    convenience init(language: JLLanguage, theme: JLColorTheme) {
        self.init(documentScope: language.documentScope, lineScope: language.lineScope, theme: theme)
    }
    
    convenience init(language: JLLanguage, theme: JLColorTheme, textStorage: NSTextStorage) {
        self.init(documentScope: language.documentScope, lineScope: language.lineScope, theme: theme)
        textStorage.delegate = self
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