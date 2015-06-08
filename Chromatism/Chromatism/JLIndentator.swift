//
//  JLIndentator.swift
//  Chromatism
//
//  Created by Johannes Lund on 2015-06-05.
//  Copyright (c) 2015 anviking. All rights reserved.
//

import Foundation

//
//class JLIndentator: NSObject, UITextViewDelegate {
//    
//    
//    let expression = NSRegularExpression(pattern: "[\\t| ]*", options: nil, error: nil)!
//    
//    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
//        let oldString: String?
//        
//        if text == "\n" {
//            // Return
//            // Start the new line with as many tabs or white spaces as the previous one.
//            let lineRange = [textView.text lineRangeForRange:range];
//            let prefixRange = expression.firstMatchInString(textView.text, options: nil, range: lineRange)
//            NSString *prefixString = [textView.text substringWithRange:prefixRange];
//            
//            UITextPosition *beginning = textView.beginningOfDocument;
//            UITextPosition *start = [textView positionFromPosition:beginning offset:range.location];
//            UITextPosition *stop = [textView positionFromPosition:start offset:range.length];
//            
//            UITextRange *textRange = [textView textRangeFromPosition:start toPosition:stop];
//            
//            [textView replaceRange:textRange withText:[NSString stringWithFormat:@"\n%@",prefixString]];
//            
//            return NO;
//        }
//        
//        if (range.length > 0)
//        {
//            _oldString = [textView.text substringWithRange:range];
//        }
//        
//        return YES;
//    }
//    }
//}