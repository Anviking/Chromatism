//
//  JLTextViewController.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-18.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

class JLTextViewController: UIViewController {
    
    var textView: JLTextView
    
    init(text: String, language: JLLanguageType, theme: JLColorTheme) {
        textView = JLTextView(language: language, theme: theme)
        textView.text = text
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView()  {
        view = textView
    }
}
