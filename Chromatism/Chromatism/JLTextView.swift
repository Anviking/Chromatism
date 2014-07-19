//
//  JLTextView.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-18.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

class JLTextView: UITextView {
    
    var syntaxTokenizer: JLTokenizer { didSet{ self.textStorage.delegate = syntaxTokenizer }}
    var language: JLLanguage { didSet{ syntaxTokenizer.language = language }}
    var theme: JLColorTheme = JLColorTheme.Default {
    didSet {
        syntaxTokenizer.colorDictionary = theme.dictionary
        self.backgroundColor = syntaxTokenizer.colorDictionary[JLTokenType.Background]
    }
    }
    
    init(tokenizer: JLTokenizer) {
        syntaxTokenizer = tokenizer
        language = tokenizer.language
        let frame = CGRect.zeroRect
        super.init(frame: frame, textContainer: nil)
        self.textStorage.delegate = tokenizer
        self.backgroundColor = syntaxTokenizer.colorDictionary[JLTokenType.Background]
        self.font = UIFont(name: "Menlo-Regular", size: 15)
    }
    
    override var attributedText: NSAttributedString! {
    didSet {
        self.syntaxTokenizer.tokenizeAttributedString(textStorage)
    }
    }
    
// –––––––––––––––––––––––––––––––––––––––––––––––––––––––
    
    func updateTypingAttributes() {
        let color = syntaxTokenizer.colorDictionary[JLTokenType.Text]!
        typingAttributes = [NSForegroundColorAttributeName: color, NSFontAttributeName: font]
    }
    
    override var text: String! {
    didSet {
        updateTypingAttributes()
        attributedText = NSAttributedString(string: text, attributes: typingAttributes)
    }
    }
    
    override var textColor: UIColor! {
    didSet {
        updateTypingAttributes()
    }
    }
    
    override var font: UIFont! {
    didSet {
        updateTypingAttributes()
    }
    }
}
