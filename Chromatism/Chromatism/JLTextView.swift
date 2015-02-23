//
//  JLTextView.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-18.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit

public class JLTextView: UITextView, JLNestedScopeDelegate {
    
    public var language: JLLanguage
    public var theme: JLColorTheme {
    didSet {
        backgroundColor = theme[.Background]
        language.documentScope.theme = theme
    }}
    
    private var _textStorage: JLTextStorage
    
    public init(language: JLLanguageType, theme: JLColorTheme) {
        self.language = language.language()
        self.theme = theme

        let frame = CGRect.zeroRect
        _textStorage = JLTextStorage(documentScope: self.language.documentScope)
        self.language.documentScope.theme = theme
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer()
        textContainer.widthTracksTextView = true
        layoutManager.addTextContainer(textContainer)
        _textStorage.addLayoutManager(layoutManager)
        super.init(frame: frame, textContainer: textContainer)
        
        self.language.documentScope.cascade { $0.delegate = self }
        backgroundColor = theme[JLTokenType.Background]
        font = UIFont(name: "Menlo-Regular", size: 15)
//        layoutManager.allowsNonContiguousLayout = true
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Override UITextView

    override public var attributedText: NSAttributedString! {
    didSet {

    }
    }
    
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

// MARK: JLScopeDelegate

extension JLTextView: JLNestedScopeDelegate {
    func nestedScopeDidPerform(scope: JLNestedScope, additions: NSIndexSet) {
        dispatch_async(dispatch_get_main_queue(), {
            additions.enumerateRangesUsingBlock { (range, stop) in
                
                let range = self.textRange(range.start ..< range.end)
                let array = self.selectionRectsForRange(range) as! [UITextSelectionRect]
                for value in array {
                    self.flash(value.rect, color: UIColor(white: 0.0, alpha: 0.1))
                }
            }
            })
    }
    
    func flash(rect: CGRect, color: UIColor) {
        let view = UIView(frame: rect)
        view.backgroundColor = UIColor.clearColor()
        self.addSubview(view)
        
        let duration = 0.2

        
        let gone = CGAffineTransformMakeScale(0, 0)
        let visible = CGAffineTransformMakeScale(1, 1)
        
        view.transform = gone
        
        // Its ok for this to be hacky for now
        view.animateToColor(color, transform: visible, duration: duration, completion: {
            view.animateToColor(UIColor.clearColor(), transform: gone, duration: duration, completion: {
                view.removeFromSuperview()
                })
            })
    }
}

private extension UIView {
    func animateToColor(color: UIColor, transform: CGAffineTransform, duration: Double, completion: () -> Void) {
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.3, options: nil, animations: {
            self.backgroundColor = color
            self.transform = transform
            }, completion: { _ in
                completion()
            })
    }
}

private extension UITextView {
    func textRange(range: Range<Int>) -> UITextRange {
        let beginning = beginningOfDocument
        let start = positionFromPosition(beginning, offset: range.startIndex)
        let end = positionFromPosition(beginning, offset: range.endIndex)
        return textRangeFromPosition(start, toPosition: end)
    }
}
