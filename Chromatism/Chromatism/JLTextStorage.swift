//
//  JLTextStorage.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-26.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

public class JLTextStorage: NSTextStorage {
    
    public var documentScope: JLDocumentScope
    public var theme: JLColorTheme { didSet { documentScope.theme = theme }}
    
    init(documentScope: JLDocumentScope, theme: JLColorTheme) {
        documentScope.theme = theme
        self.documentScope = documentScope
        self.theme = theme
        super.init()
        self.documentScope.cascadeAttributedString(self)
    }
    
    // MARK: Syntax Highlighting
    
    public override func processEditing() {
        if let range = editedLineRange {
            let editedLineIndexSet = NSIndexSet(indexesInRange: range)
            documentScope.perform(editedLineIndexSet)
        }
        super.processEditing()
    }
    
    // MARK: Text Storage Backing
    
    private var backingStore = NSMutableAttributedString()
    private var editedLineRange: NSRange?
    
    public override var string: String { return backingStore.string }
    
    public override func attributesAtIndex(location: Int, effectiveRange range: NSRangePointer) -> [NSObject : AnyObject]! {
        return backingStore.attributesAtIndex(location, effectiveRange: range)
    }
    
    public override func replaceCharactersInRange(range: NSRange, withString str: String!) {
        let actions = NSTextStorageEditActions.EditedCharacters | NSTextStorageEditActions.EditedAttributes
        let delta = str.bridgeToObjectiveC().length - range.length
        backingStore.replaceCharactersInRange(range, withString: str)
        edited(actions, range: range, changeInLength: delta)
        editedLineRange = string.bridgeToObjectiveC().lineRangeForRange(editedRange)
        documentScope.invalidateAttributesInIndexes(NSIndexSet(indexesInRange: range))
        documentScope.shiftIndexesAtLoaction(range.location, by: delta)
    }
    
    public override func setAttributes(attrs: [NSObject : AnyObject]!, range: NSRange) {
        backingStore.setAttributes(attrs, range: range)
        edited(.EditedAttributes, range: range, changeInLength: 0)
    }
}
