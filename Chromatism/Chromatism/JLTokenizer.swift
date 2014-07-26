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

    public var theme: JLColorTheme { didSet { documentScope.theme = theme }}
    
    public init (language: JLLanguage, theme: JLColorTheme) {
        self.theme = theme
        self.documentScope = language.documentScope
        documentScope.theme = theme
    }

    func tokenizeAttributedString(attributedString: NSMutableAttributedString) {
        let range = NSRangeFromString(attributedString.string)
        let editedLineIndexSet = NSIndexSet(indexesInRange: range)
        tokenizeAttributedString(attributedString, editedLineIndexSet: editedLineIndexSet)
    }
    
    func tokenizeAttributedString(attributedString: NSMutableAttributedString, editedLineIndexSet: NSIndexSet) {
        documentScope.perform(attributedString, parentIndexSet: editedLineIndexSet)
    }

}

extension JLTokenizer: NSTextStorageDelegate {
    public func textStorage(textStorage: NSTextStorage!, willProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        if editedMask & NSTextStorageEditActions.EditedCharacters {
            println("Will: \(editedRange)")
            let editedLineRange = textStorage.string.bridgeToObjectiveC().lineRangeForRange(editedRange)
            tokenizeAttributedString(textStorage, editedLineIndexSet: NSIndexSet(indexesInRange: editedLineRange))
        }
    }
  public
    func textStorage(textStorage: NSTextStorage!, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        if editedMask & NSTextStorageEditActions.EditedCharacters {
            println("Did: \(editedRange)")
            documentScope.cascade { $0.attributedStringDidChange(editedRange, delta: delta) }
            tokenizeAttributedString(textStorage, editedLineIndexSet: NSIndexSet(indexesInRange: editedRange))
        }
    }
}