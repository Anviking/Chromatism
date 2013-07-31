//
//  JLTextView.m
//  Chromatism
//
//  Created by Johannes Lund on 2013-07-16.
//  Copyright (c) 2013 Anviking. All rights reserved.
//

#import "JLTextView.h"
#import "JLTokenizer.h"
#import "Chromatism.h"

@implementation JLTextView

#pragma mark - Initialization & Setup

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    // Setup tokenizer
    self.syntaxTokenizer = [[JLTokenizer alloc] init];
    self.syntaxTokenizer.textView = self;
    self.textStorage.delegate = self.syntaxTokenizer;
    self.delegate = self.syntaxTokenizer;
    self.syntaxTokenizer.theme = JLTokenizerThemeDusk;
    
    // Set default properties
    self.scrollEnabled = YES;
    self.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    self.font = [UIFont fontWithName:@"Menlo" size:12];
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
}


@end
