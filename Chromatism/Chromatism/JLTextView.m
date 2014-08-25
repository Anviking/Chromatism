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
#import "CYRLayoutManager.h"

static void *JLTextViewContext = &JLTextViewContext;

@interface JLTextView ()
{
    CYRLayoutManager *_lineNumberLayoutManager;
    
    UIColor *_gutterBackgroundColor;
    UIColor *_gutterLineColor;
}
@end



@implementation JLTextView

@synthesize theme = _theme;

@synthesize drawLineNumbers       = _drawLineNumbers;
@synthesize drawLineCursor        = _drawLineCursor;

#pragma mark - Initialization & Setup

- (id)init
{
    return [self initWithFrame:CGRectMake(0, 0, 0, 0)];
}

- (id)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer
{
    return [self initWithFrame:frame];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithFrame:CGRectMake(0, 0, 0, 0)];
}

- (id)initWithFrame:(CGRect)frame
{
    NSTextStorage *textStorage = [[NSTextStorage alloc] init];
    CYRLayoutManager *layoutManager = [[CYRLayoutManager alloc] init];
    
    _lineNumberLayoutManager = layoutManager;
    
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    
    //  Wrap text to the text view's frame
    textContainer.widthTracksTextView = YES;
    
    [layoutManager addTextContainer:textContainer];
    
    [textStorage removeLayoutManager:textStorage.layoutManagers.firstObject];
    [textStorage addLayoutManager:layoutManager];
    
    if ((self = [super initWithFrame:frame textContainer:textContainer]))
    {
        // causes drawRect: to be called on frame resizing and device rotation
        self.contentMode = UIViewContentModeRedraw;
        
        
        _drawLineCursor        = YES;
        _drawLineNumbers       = YES;
        
        // Inset the content to make room for line numbers
        self.textContainerInset = UIEdgeInsetsMake(8, _lineNumberLayoutManager.gutterWidth, 8, 0);
        
        
        [self addObserver:self forKeyPath:NSStringFromSelector(@selector(selectedTextRange)) options:NSKeyValueObservingOptionNew context:JLTextViewContext];
        [self addObserver:self forKeyPath:NSStringFromSelector(@selector(selectedRange)) options:NSKeyValueObservingOptionNew context:JLTextViewContext];
        
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    // Setup tokenizer
    self.syntaxTokenizer = [[JLTokenizer alloc] init];
    self.theme = JLTokenizerThemeDusk;
    
    // Set default properties
    self.scrollEnabled = YES;
    self.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    self.font = [UIFont fontWithName:@"Menlo" size:12];
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.layoutManager.allowsNonContiguousLayout = YES;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(selectedTextRange))];
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(selectedRange))];
}

- (void)setSyntaxTokenizer:(JLTokenizer *)tokenizer
{
    _syntaxTokenizer = tokenizer;
    
    self.textStorage.delegate = self.syntaxTokenizer;
    self.layoutManager.delegate = self.syntaxTokenizer;
    self.delegate = self.syntaxTokenizer;
}

#pragma mark - Color Themes

-(void)setTheme:(JLTokenizerTheme)theme
{
    _theme = theme;
    
    // Set font- and background color from the theme
    self.syntaxTokenizer.colors = [Chromatism colorsForTheme:theme];
    NSMutableDictionary *typingAttributes = self.typingAttributes.mutableCopy;
    typingAttributes[NSForegroundColorAttributeName] = self.syntaxTokenizer.colors[JLTokenTypeText];
    self.typingAttributes = typingAttributes;
    
    UIColor *backgroundColor = self.syntaxTokenizer.colors[JLTokenTypeBackground];
    [self setBackgroundColor:backgroundColor ? backgroundColor : [UIColor whiteColor] ];
    
    //Set gutter colors
    _gutterBackgroundColor = self.syntaxTokenizer.colors[JLGutterBackgroundColor];
    _gutterLineColor = self.syntaxTokenizer.colors[JLGutterLineColor];
    
    // Refresh Tokenization
    [self.syntaxTokenizer refreshTokenizationOfTextStorage:self.textStorage];
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



#pragma mark - Line Drawing

// Implementation sourced from https://github.com/illyabusigin/CYRTextView
// Original implementation sourced from: https://github.com/alldritt/TextKit_LineNumbers
- (void)drawRect:(CGRect)rect
{
    if (_drawLineNumbers)
    {
        //  Drag the line number gutter background.  The line numbers them selves are drawn by LineNumberLayoutManager.
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGRect bounds = self.bounds;
        
        CGFloat height = MAX(CGRectGetHeight(bounds), self.contentSize.height) + 200;
        
        // Set the regular fill
        CGContextSetFillColorWithColor(context, _gutterBackgroundColor.CGColor);
        CGContextFillRect(context, CGRectMake(bounds.origin.x, bounds.origin.y, _lineNumberLayoutManager.gutterWidth, height));
        
        // Draw line
        CGContextSetFillColorWithColor(context, _gutterLineColor.CGColor);
        CGContextFillRect(context, CGRectMake(_lineNumberLayoutManager.gutterWidth, bounds.origin.y, 0.5, height));
        
        if (_drawLineCursor)
        {
            _lineNumberLayoutManager.selectedRange = self.selectedRange;
            
            NSRange glyphRange = [_lineNumberLayoutManager.textStorage.string paragraphRangeForRange:self.selectedRange];
            glyphRange = [_lineNumberLayoutManager glyphRangeForCharacterRange:glyphRange actualCharacterRange:NULL];
            _lineNumberLayoutManager.selectedRange = glyphRange;
            [_lineNumberLayoutManager invalidateDisplayForGlyphRange:glyphRange];
        }
    }
    else
        _lineNumberLayoutManager.selectedRange = NSMakeRange(-1, 0);
    
    [super drawRect:rect];
}

- (void)setDrawLineNumbers:(BOOL)drawLineNumbers
{
    _drawLineNumbers = drawLineNumbers;
    
    if (_drawLineNumbers)
        self.textContainerInset = UIEdgeInsetsMake(8, _lineNumberLayoutManager.gutterWidth, 8, 0);
    else
        self.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    // Redraw to remove the stripe at the left
    [self setNeedsDisplay];
}


#pragma mark - KVO

// Implementation original sourced from https://github.com/illyabusigin/CYRTextView
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (([keyPath isEqualToString:NSStringFromSelector(@selector(selectedTextRange))] ||
              [keyPath isEqualToString:NSStringFromSelector(@selector(selectedRange))]) && context == JLTextViewContext)
        [self setNeedsDisplay];
    else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end
