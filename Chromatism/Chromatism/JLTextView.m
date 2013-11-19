//
//  JLTextView.m
//  Chromatism
//
//  Created by Johannes Lund on 2013-07-16.
//
//  Copyright (c) 2013 Johannes Lund
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "JLTextView.h"
#import "Chromatism.h"

@implementation JLTextView
@synthesize theme = _theme, tokenizer = _tokenizer;

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

- (id)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer
{
    self = [super initWithFrame:frame textContainer:textContainer];
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
    self.tokenizer = [[JLTokenizer alloc] init];
    self.theme = JLTokenizerThemeDusk;
    
    // Set default properties
    self.scrollEnabled = YES;
    self.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    self.font = [UIFont fontWithName:@"Menlo" size:12];
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
}

- (void)setTokenizer:(JLTokenizer *)tokenizer
{
    _tokenizer = tokenizer;
    
    self.textStorage.delegate = self.tokenizer;
    self.layoutManager.delegate = self.tokenizer;
    self.delegate = self.tokenizer;
}

#pragma mark - Color Themes

-(void)setTheme:(JLTokenizerTheme)theme
{
    self.tokenizer.colors = [Chromatism colorsForTheme:theme];
    self.typingAttributes = @{ NSForegroundColorAttributeName : self.tokenizer.colors[JLTokenTypeText]};
    _theme = theme;
    
    //Set font, text color and background color back to default
    UIColor *backgroundColor = self.tokenizer.colors[JLTokenTypeBackground];
    [self setBackgroundColor:backgroundColor ? backgroundColor : [UIColor whiteColor] ];
    
    // Refresh Tokenization
    [self.tokenizer tokenizeTextStorage:self.textStorage withRange:NSMakeRange(0, self.textStorage.length)];
}

- (JLTokenizerTheme)theme
{
    if (!_theme) _theme = JLTokenizerThemeDefault;
    return _theme;
}

// http://stackoverflow.com/questions/19235762/how-can-i-support-the-up-and-down-arrow-keys-with-a-bluetooth-keyboard-under-ios

#pragma mark - Bluethooth Keyboard Extension

- (NSArray *)keyCommands {
    UIKeyCommand *upArrow = [UIKeyCommand keyCommandWithInput: UIKeyInputUpArrow modifierFlags: 0 action: @selector(upArrow:)];
    UIKeyCommand *downArrow = [UIKeyCommand keyCommandWithInput: UIKeyInputDownArrow modifierFlags: 0 action: @selector(downArrow:)];
    return [[NSArray alloc] initWithObjects: upArrow, downArrow, nil];
}

- (void)upArrow:(UIKeyCommand *)keyCommand {
    UITextRange *range = self.selectedTextRange;
    if (range != nil) {
        float lineHeight = self.font.lineHeight;
        
        CGRect caret = [self firstRectForRange: range];
        if (isinf(caret.origin.y)) {
            // Work-around for a bug in iOS 7 that returns bogus values when the caret is at the start of a line.
            range = [self textRangeFromPosition: range.start toPosition: [self positionFromPosition: range.start offset: 1]];
            caret = [self firstRectForRange: range];
            caret.origin.y = caret.origin.y + lineHeight;
        }
        caret.origin.y = caret.origin.y - lineHeight < 0 ? 0 : caret.origin.y - lineHeight;
        caret.size.width = 1;
        UITextPosition *position = [self closestPositionToPoint: caret.origin];
        self.selectedTextRange = [self textRangeFromPosition: position toPosition: position];
        
        caret = [self firstRectForRange: self.selectedTextRange];
        if (isinf(caret.origin.y)) {
            // Work-around for a bug in iOS 7 that occurs when the range is set to a position past the end of the last character
            // on a line.
            NSRange range = {0, 0};
            range.location = [self offsetFromPosition: self.beginningOfDocument toPosition: position];
            self.selectedRange = range;
        }
    }
}

- (void)downArrow:(UIKeyCommand *)keyCommand {
    UITextRange *range = self.selectedTextRange;
    if (range != nil) {
        float lineHeight = self.font.lineHeight;
        
        CGRect caret = [self firstRectForRange: range];
        if (isinf(caret.origin.y)) {
            // Work-around for a bug in iOS 7 that returns bogus values when the caret is at the start of a line.
            range = [self textRangeFromPosition: range.start toPosition: [self positionFromPosition: range.start offset: 1]];
            caret = [self firstRectForRange: range];
            caret.origin.y = caret.origin.y + lineHeight;
        }
        caret.origin.y = caret.origin.y + lineHeight < 0 ? 0 : caret.origin.y + lineHeight;
        caret.size.width = 1;
        UITextPosition *position = [self closestPositionToPoint: caret.origin];
        self.selectedTextRange = [self textRangeFromPosition: position toPosition: position];
        
        caret = [self firstRectForRange: self.selectedTextRange];
        if (isinf(caret.origin.y)) {
            // Work-around for a bug in iOS 7 that occurs when the range is set to a position past the end of the last character
            // on a line.
            NSRange range = {0, 0};
            range.location = [self offsetFromPosition: self.beginningOfDocument toPosition: position];
            self.selectedRange = range;
        }
    }
}
@end
