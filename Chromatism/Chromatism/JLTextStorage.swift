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

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Syntax Highlighting
    
    public override func processEditing() {
        if let range = editedLineRange {
            // let layoutManager = layoutManagers[0] as NSLayoutManager
            //println("Non Contigigous Layout: \(layoutManager.hasNonContiguousLayout)")
            var editedLineIndexSet = IndexSet(integersIn: range.toRange() ?? 0..<0)
            documentScope.perform(&editedLineIndexSet)
            editedLineRange = nil
        }
        super.processEditing()
    }
    
    // MARK: Text Storage Backing
    
    private var backingStore = NSMutableAttributedString()
    private var editedLineRange: NSRange?
    
    public override var string: String { return backingStore.string }
    
    public override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [String: AnyObject] {
        return backingStore.attributes(at: location, effectiveRange: range)
    }
    
    public override func replaceCharacters(in range: NSRange, with str: String) {
        let actions: NSTextStorageEditActions = [NSTextStorageEditActions.editedCharacters, NSTextStorageEditActions.editedAttributes]
        let delta = str.utf16.count - range.length
        edited(actions, range: range, changeInLength: delta)
        backingStore.replaceCharacters(in: range, with: str)
        editedLineRange = (string as NSString).lineRange(for: editedRange)
        documentScope.invalidateAttributesInIndexes(IndexSet(integersIn: range.toRange() ?? 0..<0))
        documentScope.shiftIndexesAtLoaction(range.end, by: delta)
    }
    
    
    
    public override func setAttributes(_ attrs: [String : AnyObject]?, range: NSRange) {
        backingStore.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
    }

}
