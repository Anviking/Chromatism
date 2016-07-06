//
//  JLTextStorage.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-26.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

public class JLTextStorageDelegate: NSObject, NSTextStorageDelegate {
    
    public var documentScope: JLDocumentScope
    public var textView: UITextView
    
    public var language: Language
    public var theme: ColorTheme {
        didSet {
            textView.backgroundColor = theme[.background]
            documentScope.theme = theme
        }}
    
    public init(managing textView: UITextView, language: Language, theme: ColorTheme) {
        self.textView = textView
        self.language = language
        self.documentScope = language.documentScope()
        self.theme = theme
        self.documentScope.cascadeAttributedString(textView.textStorage)
        
        super.init()
        textView.textStorage.delegate = self
        documentScope.perform()
    }
    
    public func update() {
        documentScope.perform()
    }
    
    // MARK: Text Storage Backing
    
    private var editedLineRange: NSRange?
    
    public func textStorage(_ textStorage: NSTextStorage, willProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        
        /*
        if editedMask.contains(.editedCharacters) {
            editedLineRange = (textStorage.string as NSString).lineRange(for: editedRange)
            documentScope.invalidateAttributesInIndexes(IndexSet(integersIn: editedRange.toRange() ?? 0..<0))
            documentScope.shiftIndexesAtLoaction(editedRange.end, by: delta)
        }*/
        
        if let range = editedLineRange {
            // let layoutManager = layoutManagers[0] as NSLayoutManager
            //println("Non Contigigous Layout: \(layoutManager.hasNonContiguousLayout)")
            var editedLineIndexSet = IndexSet(integersIn: range.toRange() ?? 0..<0)
            documentScope.perform(&editedLineIndexSet)
            editedLineRange = nil
        }
    }
    
    //
    
    func updateTypingAttributes() {
        let color = theme[JLTokenType.text]!
        var dictionary: [String: AnyObject] = [NSForegroundColorAttributeName: color]
        if let font = font {
            dictionary[NSFontAttributeName] = font
        }
        
        textView.typingAttributes = dictionary
    }
    
    public var text: String! {
        didSet {
            updateTypingAttributes()
            textView.attributedText = AttributedString(string: text, attributes: textView.typingAttributes)
            update()
        }
    }
    
    public var textColor: UIColor? {
        didSet {
            updateTypingAttributes()
        }
    }
    
    public var font: UIFont? {
        didSet {
            updateTypingAttributes()
        }
    }

}
