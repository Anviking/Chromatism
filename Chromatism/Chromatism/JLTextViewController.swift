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
    
    public required init(text: String, language: JLLanguageType, theme: JLColorTheme) {
        textView = JLTextView(language: language, theme: theme)
        textView.text = text
        super.init(nibName: nil, bundle: nil)
        registerForKeyboardNotifications()
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        unregisterForKeyboardNotifications()
    }
    
    override public func loadView()  {
        view = textView
    }

    // MARK: Content Insets and Keyboard
    
    func registerForKeyboardNotifications()
    {
        NotificationCenter.default().addObserver(self, selector: "keyboardWasShown:", name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default().addObserver(self, selector: "keyboardWillBeHidden:", name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unregisterForKeyboardNotifications() {
        NotificationCenter.default().removeObserver(self)
    }
    
    // Called when the UIKeyboardDidShowNotification is sent.
    func keyboardWasShown(_ notification: Notification) {
        // FIXME: ! could be wrong
        let info = (notification as NSNotification).userInfo!
        let scrollView = self.textView
        let kbSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue().size;
        
        var contentInsets = scrollView.contentInset;
        contentInsets.bottom = kbSize.height;
        scrollView.contentInset = contentInsets;
        scrollView.scrollIndicatorInsets = contentInsets;
        
        // FIXME: ! could be wrong
        var point = textView.caretRect(for: textView.selectedTextRange!.start).origin;
        point.y = min(point.y, self.textView.frame.size.height - kbSize.height);
        
        var aRect = self.view.frame;
        aRect.size.height -= kbSize.height;
        if (!aRect.contains(point) ) {
            
            var rect = CGRect(x: point.x, y: point.y, width: 1, height: 1)
            rect.size.height = kbSize.height
            rect.origin.y += kbSize.height
            textView.scrollRectToVisible(rect, animated: true)
        }
    }
    
    // Called when the UIKeyboardWillHideNotification is sent
    func keyboardWillBeHidden(_ notification: Notification) {
        var contentInsets = textView.contentInset;
        contentInsets.bottom = 0;
        textView.contentInset = contentInsets;
        textView.scrollIndicatorInsets = contentInsets;
        textView.contentInset = contentInsets;
        textView.scrollIndicatorInsets = contentInsets;
    }
}
