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
{
    NSString *_oldString;
}

@synthesize theme = _theme;

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
    self.textStorage.delegate = self.syntaxTokenizer;
    self.theme = JLTokenizerThemeDusk;
    
    // Set default properties
    self.scrollEnabled = YES;
    self.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    self.font = [UIFont fontWithName:@"Menlo" size:12];
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    // Setup delegates
    self.delegate = self;
    self.layoutManager.delegate = self;
}

#pragma mark - Color Themes

-(void)setTheme:(JLTokenizerTheme)theme
{
    self.syntaxTokenizer.colors = [Chromatism colorsForTheme:theme];
    self.typingAttributes = @{ NSForegroundColorAttributeName : self.syntaxTokenizer.colors[JLTokenTypeText]};
    _theme = theme;
    
    //Set font, text color and background color back to default
    UIColor *backgroundColor = self.syntaxTokenizer.colors[JLTokenTypeBackground];
    [self setBackgroundColor:backgroundColor ? backgroundColor : [UIColor whiteColor] ];
}

- (JLTokenizerTheme)theme
{
    if (!_theme) _theme = JLTokenizerThemeDefault;
    return _theme;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    _oldString = nil;
    
    if (range.length == 0 && text.length == 1) {
        // A normal character typed
    }
    else if (range.length == 1 && text.length == 0) {
        // Backspace
    }
    else {
        // Multicharacter edit
    }
    
    if ([text isEqualToString:@"\n"]) {
        // Return
        // Start the new line with as many tabs or white spaces as the previous one.
        NSRange lineRange = [textView.text lineRangeForRange:range];
        NSRange prefixRange = [textView.text rangeOfString:@"[\\t| ]*" options:NSRegularExpressionSearch range:lineRange];
        NSString *prefixString = [textView.text substringWithRange:prefixRange];
        
        UITextPosition *beginning = textView.beginningOfDocument;
        UITextPosition *start = [textView positionFromPosition:beginning offset:range.location];
        UITextPosition *stop = [textView positionFromPosition:start offset:range.length];
        
        UITextRange *textRange = [textView textRangeFromPosition:start toPosition:stop];
        
        [textView replaceRange:textRange withText:[NSString stringWithFormat:@"\n%@",prefixString]];
        
        return NO;
    }
    
    if (range.length > 0)
    {
        _oldString = [textView.text substringWithRange:range];
    }
    
    return YES;
}

#pragma mark - NSLayoutManager delegeate
/*
 *  TODO: Find out a way to set intendation for entire paragraphs.
 */

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager paragraphSpacingBeforeGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect
{
    return 0;
}

- (BOOL)layoutManager:(NSLayoutManager *)layoutManager shouldBreakLineByWordBeforeCharacterAtIndex:(NSUInteger)charIndex
{
    NSString *character = [layoutManager.textStorage.string substringWithRange:NSMakeRange(charIndex, 1)];
    // NSLog(@"Asked about linebreak: %@",character);
    if ([character isEqualToString:@"*"]) return NO;
    return YES;
}

@end
