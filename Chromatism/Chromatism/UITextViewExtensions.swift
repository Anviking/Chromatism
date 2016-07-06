//
//  JLTextView.swift
//  Chromatism
//
//  Created by Johannes Lund on 2014-07-18.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit


// MARK: JLScopeDelegate

extension UITextView: JLNestedScopeDelegate {
    func nestedScopeDidPerform(_ scope: JLNestedScope, additions: IndexSet) {
        DispatchQueue.main.async(execute: {
            for range in additions.rangeView() {
                let range = self.textRange(Range(range))
                let array = self.selectionRects(for: range!) as! [UITextSelectionRect]
                for value in array {
                    self.flash(value.rect, color: UIColor(white: 0.0, alpha: 0.1))
                }
            }
            })
    }
    
    func flash(_ rect: CGRect, color: UIColor) {
        let view = UIView(frame: rect)
        view.backgroundColor = UIColor.clear()
        self.addSubview(view)
        
        let duration = 0.2

        
        let gone = CGAffineTransform(scaleX: 0, y: 0)
        let visible = CGAffineTransform(scaleX: 1, y: 1)
        
        view.transform = gone
        
        // Its ok for this to be hacky for now
        view.animateToColor(color, transform: visible, duration: duration, completion: {
            view.animateToColor(UIColor.clear(), transform: gone, duration: duration, completion: {
                view.removeFromSuperview()
                })
            })
    }
}

private extension UIView {
    func animateToColor(_ color: UIColor, transform: CGAffineTransform, duration: Double, completion: () -> Void) {
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.3, options: [], animations: {
            self.backgroundColor = color
            self.transform = transform
            }, completion: { _ in
                completion()
            })
    }
}

private extension UITextView {
    func textRange(_ range: Range<Int>) -> UITextRange? {
        let beginning = beginningOfDocument
        
        guard let start = position(from: beginning, offset: range.lowerBound) else {
            return nil
        }
        guard let end = position(from: beginning, offset: range.upperBound) else {
            return nil
        }
        
        return self.textRange(from: start, to: end)
    }
}
