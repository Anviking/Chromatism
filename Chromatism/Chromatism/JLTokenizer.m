//
//  Tokenizer.m
//  iGitpad
//
//  Created by Johannes Lund on 2012-11-24.
//
//

//  This file builds upon the work of Kristian Kraljic
//
//  RegexHighlightView.m
//  Simple Objective-C Syntax Highlighter
//
//  Created by Kristian Kraljic on 30/08/12.
//  Copyright (c) 2012 Kristian Kraljic (dikrypt.com, ksquared.de). All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "JLTokenizer.h"
#import "JLTextViewController.h" 
#import "JLScope.h"
#import "JLTokenPattern.h"
#import "Chromatism.h"

@interface JLTokenizer ()
{
    NSString *_oldString;
}

@end

@implementation JLTokenizer
@synthesize theme = _theme, themes = _themes, colors = _colors;

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

#pragma mark - Scopes

//
// NOT COMPLETED
//
//- (void)refreshScopesInTextStorage:(NSTextStorage *)textStorage;
//{
//    NSString *string = textStorage.string;
//    __block NSUInteger scope = 0;
//    
//    
//    NSString *pattern = @"\\{|\\}";
//    NSError *error;
//    NSString *attribute = @"ChromatismScopeAttributeName";
//    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
//
//    NSAssert(!error, @"%@",error);
//    
//    [expression enumerateMatchesInString:string options:0 range:NSMakeRange(0, textStorage.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
//        NSString *substring = [string substringWithRange:result.range];
//        if ([substring isEqualToString:@"{"]) {
//            scope++;
//        }
//        else scope--;
//        NSLog(@"Scope is %i",scope);
//        float f = 0.3 + ((float)scope/10);
//        NSLog(@"Color is :%f",f);
//        UIColor *color = [UIColor colorWithWhite:f alpha:1];
//        [textStorage addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(result.range.location, string.length - result.range.location)];
//    }];
//}

#pragma mark - NSTextStorageDelegate

- (void)textStorage:(NSTextStorage *)textStorage willProcessEditing:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta
{
    
}

- (void)textStorage:(NSTextStorage *)textStorage didProcessEditing:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta
{
   [self tokenizeTextStorage:textStorage withRange:[textStorage.string lineRangeForRange:editedRange]];
}

#pragma mark - Tokenizing

- (JLTokenPattern *)addToken:(NSString *)type withPattern:(NSString *)pattern andScope:(JLScope *)scope
{
    NSParameterAssert(type);
    NSParameterAssert(pattern);
    NSParameterAssert(scope);
    UIColor *color = self.colors[type];
    
    NSAssert(color, @"%@ didn't return a color in color dictionary %@", type, self.colors);
    
    JLTokenPattern *token = [JLTokenPattern tokenPatternWithPattern:pattern andColor:self.colors[type]];
    [scope addSubscope:token];
    return token;
}

- (void)tokenizeTextStorage:(NSTextStorage *)storage withRange:(NSRange)range
{
    // Measure performance
    NSDate *date = [NSDate date];
    
    // First, remove old attributes
    [self clearColorAttributesInRange:range textStorage:storage];

    JLScope *documentScope = [JLScope scopeWithTextStorage:storage];
    JLScope *rangeScope = [JLScope scopeWithRange:range inTextStorage:storage];
 
    // Block and line comments
    [self addToken:JLTokenTypeComment withPattern:@"/\\*([^*]|[\\r\\n]|(\\*+([^*/]|[\\r\\n])))*\\*+/" andScope:documentScope];
    [self addToken:JLTokenTypeComment withPattern:@"//.*+$" andScope:rangeScope];
    
    // Preprocessor macros
    JLTokenPattern *preprocessor = [self addToken:JLTokenTypePreprocessor withPattern:@"#.*+$" andScope:rangeScope];
    
    // #import <Library/Library.h>
    // In xcode it only works for #import and #include, not all preprocessor statements.
    [self addToken:JLTokenTypeString withPattern:@"<.*?>" andScope:preprocessor];
    
    // Strings
    [[self addToken:JLTokenTypeString withPattern:@"(\"|@\")[^\"\\n]*(@\"|\")" andScope:rangeScope] addScope:preprocessor];
    
    // Numbers
    [self addToken:JLTokenTypeNumber withPattern:@"(?<=\\s)\\d+" andScope:rangeScope];
    
    // New literals, for example @[]
    // TODO: Literals don't search through multiple lines. Nor does it keep track of nested things.
    [[self addToken:JLTokenTypeNumber withPattern:@"@[\\(|\\{|\\[][^\\(\\{\\[]+[\\)|\\}|\\]]" andScope:rangeScope] setOpaque:NO];
    
    // C function names
    [[self addToken:JLTokenTypeOtherMethodNames withPattern:@"\\w+\\s*(?>\\(.*\\)" andScope:rangeScope] setCaptureGroup:1];
    
    // Dot notation
    [[self addToken:JLTokenTypeOtherMethodNames withPattern:@"\\.(\\w+)" andScope:rangeScope] setCaptureGroup:1];

    // Method Calls
    [[self addToken:JLTokenTypeOtherMethodNames withPattern:@"\\[\\w+\\s+(\\w+)\\]" andScope:rangeScope] setCaptureGroup:1];
    
    // Method call parts
    [[self addToken:JLTokenTypeOtherMethodNames withPattern:@"(?<=\\w+):\\s*[^\\s;\\]]+" andScope:rangeScope] setCaptureGroup:1];
    
    // NS and UI prefixes words
    [self addToken:JLTokenTypeOtherClassNames withPattern:@"(\\b(?>NS|UI))\\w+\\b" andScope:rangeScope];
    
    [self addToken:JLTokenTypeKeyword withPattern:@"(?<=\\b)(?>true|false|yes|no|TRUE|FALSE|bool|BOOL|nil|id|void|self|NULL|if|else|strong|weak|nonatomic|atomic|assign|copy|typedef|enum|auto|break|case|const|char|continue|do|default|double|extern|float|for|goto|int|long|register|return|short|signed|sizeof|static|struct|switch|typedef|union|unsigned|volatile|while|nonatomic|atomic|nonatomic|readonly|super )(\\b)" andScope:rangeScope];
    [self addToken:JLTokenTypeKeyword withPattern:@"@[a-zA-Z0-9_]+" andScope:rangeScope];
    
    [documentScope addSubscope:rangeScope];
    [documentScope perform];
    NSLog(@"Chromatism done tokenizing with time of %fms",ABS([date timeIntervalSinceNow]*1000));
}

- (NSMutableAttributedString *)tokenizeString:(NSString *)string withDefaultAttributes:(NSDictionary *)attributes;
{
    NSMutableAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:attributes].mutableCopy;
    [self tokenizeTextStorage:(NSTextStorage *)attributedString withRange:NSMakeRange(0, string.length)];
    return attributedString;
}

- (void)clearColorAttributesInRange:(NSRange)range textStorage:(NSTextStorage *)storage;
{
    [storage removeAttribute:NSForegroundColorAttributeName range:range];
    [storage addAttribute:NSForegroundColorAttributeName value:self.colors[JLTokenTypeText] range:range];
}

#pragma mark - Color Themes

- (NSDictionary *)defaultAttributes
{
    if (!_defaultAttributes) _defaultAttributes = @{NSForegroundColorAttributeName: self.colors[JLTokenTypeText], NSFontAttributeName : [UIFont fontWithName:@"Menlo" size:12]};
    return _defaultAttributes;
}

-(void)setTheme:(JLTokenizerTheme)theme
{
    self.colors = [Chromatism colorsForTheme:theme];
    self.textView.typingAttributes = @{ NSForegroundColorAttributeName : self.colors[JLTokenTypeText]};
    _theme = theme;
    
    //Set font, text color and background color back to default
    UIColor *backgroundColor = self.colors[JLTokenTypeBackground];
    [self.textView setBackgroundColor:backgroundColor ? backgroundColor : [UIColor whiteColor] ];
}

- (NSDictionary *)colors
{
    if (!_colors) {
        self.colors = [Chromatism colorsForTheme:self.theme];
    }
    return _colors;
}

- (void)setColors:(NSDictionary *)colors
{
    _colors = colors;
}

- (NSArray *)themes
{
    if (!_themes) _themes = @[@(JLTokenizerThemeDefault),@(JLTokenizerThemeDusk)];
    return _themes;
}

- (JLTokenizerTheme)theme
{
    if (!_theme) _theme = JLTokenizerThemeDefault;
    return _theme;
}

@end
