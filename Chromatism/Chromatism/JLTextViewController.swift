//
//  JLTextViewController.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-18.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

public class JLTextViewController: UIViewController {
    
    public var textView: JLTextView
    
    public init(text: String, language: JLLanguageType, theme: JLColorTheme) {
        textView = JLTextView(language: language, theme: theme)
        textView.text = text
        super.init(nibName: nil, bundle: nil)
    }
    
    override public func loadView()  {
        view = textView
    }
}
