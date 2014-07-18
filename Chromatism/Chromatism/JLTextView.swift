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
    
    init(frame: CGRect, tokenizer: JLTokenizer) {
        syntaxTokenizer = tokenizer
        language = tokenizer.language
        super.init(frame: frame, textContainer: nil)
        self.textStorage.delegate = tokenizer
    }
    
    convenience init(coder: NSCoder?) {
        let frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        let language = JLLanguage()
        let tokenizer = JLTokenizer(language: language)
        
        self.init(frame: frame, tokenizer:  tokenizer)
    }
    
    

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
        // Drawing code
    }
    */

}
