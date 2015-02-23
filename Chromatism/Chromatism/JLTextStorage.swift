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
    
    init(documentScope: JLDocumentScope) {
        self.documentScope = documentScope
        super.init()
        self.documentScope.cascadeAttributedString(self)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Syntax Highlighting
    
    public override func processEditing() {
        if let range = editedLineRange {
            let layoutManager = layoutManagers[0] as! NSLayoutManager
            //println("Non Contigigous Layout: \(layoutManager.hasNonContiguousLayout)")
            let editedLineIndexSet = NSIndexSet(indexesInRange: range)
            documentScope.perform(editedLineIndexSet)
            editedLineRange = nil
        }
        super.processEditing()
    }
    
    // MARK: Text Storage Backing
    
    private var backingStore = NSMutableAttributedString()
    private var editedLineRange: NSRange?
    
    public override var string: String { return backingStore.string }
    
    public override func attributesAtIndex(location: Int, effectiveRange range: NSRangePointer) -> [NSObject : AnyObject] {
        return backingStore.attributesAtIndex(location, effectiveRange: range)
    }
    
    public override func replaceCharactersInRange(range: NSRange, withString str: String) {
        let actions = NSTextStorageEditActions.EditedCharacters | NSTextStorageEditActions.EditedAttributes
        let delta = str.utf16Count - range.length
        edited(actions, range: range, changeInLength: delta)
        backingStore.replaceCharactersInRange(range, withString: str)
        editedLineRange = (string as NSString).lineRangeForRange(editedRange)
        documentScope.invalidateAttributesInIndexes(NSIndexSet(indexesInRange: range))
        documentScope.shiftIndexesAtLoaction(range.end, by: delta)
    }
    
    public override func setAttributes(attrs: [NSObject : AnyObject]!, range: NSRange) {
        backingStore.setAttributes(attrs, range: range)
        edited(.EditedAttributes, range: range, changeInLength: 0)
    }
}
