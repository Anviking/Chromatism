//
//  JLTextViewController.h
//  iGitpad
//
//  Created by Johannes Lund on 2013-06-13.
//  Copyright (c) 2013 Anviking. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JLTokenizer, JLTextView;

@interface JLTextViewController : UIViewController

- (instancetype)initWithText:(NSString *)text;

@property (nonatomic, strong) IBOutlet JLTextView *textView;

// Convenience property for self.textView.syntaxTokenizer
@property (nonatomic, weak, readonly) JLTokenizer *tokenizer;
@end
