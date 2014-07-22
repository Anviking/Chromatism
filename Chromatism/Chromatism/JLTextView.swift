//
//  JLTextView.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-18.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

public class JLTextView: UITextView {
    
    var syntaxTokenizer: JLTokenizer { didSet{ self.textStorage.delegate = syntaxTokenizer }}
    
    public var language: JLLanguage { didSet{ syntaxTokenizer = JLTokenizer(language: language, theme: theme) }}
    public var theme: JLColorTheme {
    didSet {
        backgroundColor = theme[.Background]
        syntaxTokenizer.theme = theme
    }}
    
    public init(language: JLLanguage, theme: JLColorTheme) {
        self.language = language
        self.theme = theme
        syntaxTokenizer = JLTokenizer(language: language, theme: theme)
        
        let frame = CGRect.zeroRect
        super.init(frame: frame, textContainer: nil)
        
        textStorage.delegate = syntaxTokenizer
        backgroundColor = theme[JLTokenType.Background]
        font = UIFont(name: "Menlo-Regular", size: 15)
        layoutManager.allowsNonContiguousLayout = true
    }
    
    override public var attributedText: NSAttributedString! {
    didSet {
        self.syntaxTokenizer.tokenizeAttributedString(textStorage)
    }
    }
    
// –––––––––––––––––––––––––––––––––––––––––––––––––––––––
    
    func updateTypingAttributes() {
        let color = syntaxTokenizer.theme[JLTokenType.Text]!
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
