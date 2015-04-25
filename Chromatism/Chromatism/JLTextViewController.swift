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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unregisterForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // Called when the UIKeyboardDidShowNotification is sent.
    func keyboardWasShown(notification: NSNotification) {
        // FIXME: ! could be wrong
        let info = notification.userInfo!
        let scrollView = self.textView
        let kbSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue().size;
        
        var contentInsets = scrollView.contentInset;
        contentInsets.bottom = kbSize.height;
        scrollView.contentInset = contentInsets;
        scrollView.scrollIndicatorInsets = contentInsets;
        
        // FIXME: ! could be wrong
        var point = textView.caretRectForPosition(textView.selectedTextRange!.start).origin;
        point.y = min(point.y, self.textView.frame.size.height - kbSize.height);
        
        var aRect = self.view.frame;
        aRect.size.height -= kbSize.height;
        if (!CGRectContainsPoint(aRect, point) ) {
            
            var rect = CGRectMake(point.x, point.y, 1, 1)
            rect.size.height = kbSize.height
            rect.origin.y += kbSize.height
            textView.scrollRectToVisible(rect, animated: true)
        }
    }
    
    // Called when the UIKeyboardWillHideNotification is sent
    func keyboardWillBeHidden(notification: NSNotification) {
        var contentInsets = textView.contentInset;
        contentInsets.bottom = 0;
        textView.contentInset = contentInsets;
        textView.scrollIndicatorInsets = contentInsets;
        textView.contentInset = contentInsets;
        textView.scrollIndicatorInsets = contentInsets;
    }
}
