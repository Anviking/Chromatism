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
    var language: JLLanguage { didSet{
        let dataSource = language.languageDataSource
        syntaxTokenizer.documentScope = dataSource.documentScope
        syntaxTokenizer.lineScope = dataSource.lineScope
    }}
    var theme: JLColorTheme {
    didSet {
        backgroundColor = syntaxTokenizer.colorDictionary[JLTokenType.Background]
        syntaxTokenizer.colorDictionary = theme.dictionary
    }}
    
    init(language: JLLanguage, theme: JLColorTheme) {
        self.language = language
        self.theme = theme
        self.syntaxTokenizer = JLTokenizer(colorDictionary: theme.dictionary, languageDataSource: language.languageDataSource)
        
        let frame = CGRect.zeroRect
        super.init(frame: frame, textContainer: nil)
        self.textStorage.delegate = syntaxTokenizer
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
