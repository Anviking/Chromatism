//
//  JLTextView.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-18.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

public class JLTextView: UITextView {
    
    public var language: JLLanguage
    public var theme: JLColorTheme {
    didSet {
        backgroundColor = theme[.Background]
        _textStorage.theme = theme
    }}
    
    private var _textStorage: JLTextStorage
    
    public init(language: JLLanguage, theme: JLColorTheme) {
        self.language = language
        self.theme = theme

        let frame = CGRect.zeroRect
        _textStorage = JLTextStorage(documentScope: language.documentScope, theme: theme)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer()
        textContainer.widthTracksTextView = true
        layoutManager.addTextContainer(textContainer)
        _textStorage.addLayoutManager(layoutManager)
        super.init(frame: frame, textContainer: textContainer)
        
        backgroundColor = theme[JLTokenType.Background]
        font = UIFont(name: "Menlo-Regular", size: 15)
//        layoutManager.allowsNonContiguousLayout = true
    }
    
    override public var attributedText: NSAttributedString! {
    didSet {

    }
    }
    
// –––––––––––––––––––––––––––––––––––––––––––––––––––––––
    
    func updateTypingAttributes() {
        let color = theme[JLTokenType.Text]!
        typingAttributes = [NSForegroundColorAttributeName: color, NSFontAttributeName: font]
    }
    
    override public var text: String! {
    didSet {
        updateTypingAttributes()
        attributedText = NSAttributedString(string: text, attributes: typingAttributes)
    }
    }
    
    override public var textColor: UIColor! {
    didSet {
        updateTypingAttributes()
    }
    }
    
    override public var font: UIFont! {
    didSet {
        updateTypingAttributes()
    }
    }
}
