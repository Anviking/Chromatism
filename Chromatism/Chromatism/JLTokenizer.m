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

#define BLOCK_COMMENT @"blockComment"
#define LINE_COMMENT @"lineComment"

@interface JLTokenizer ()

@property (nonatomic, strong) JLScope *documentScope;
@property (nonatomic, strong) JLScope *lineScope;
@property (nonatomic, strong) NSTimer *validationTimer;

@end

@implementation JLTokenizer
{
    NSRange _editedRange;
    NSRange _editedLineRange;
    NSString *_oldString;
}

#pragma mark - Setup

- (void)setup
{
    JLScope *documentScope = [JLScope new];
    JLScope *lineScope = [JLScope new];
    
    // Block and line comments
    JLTokenPattern *blockComment = [self addToken:JLTokenTypeComment withIdentifier:BLOCK_COMMENT pattern:@"" andScope:documentScope];
    blockComment.triggeringCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"/*"];
    blockComment.expression = [NSRegularExpression regularExpressionWithPattern:@"/\\*.*?\\*/" options:NSRegularExpressionDotMatchesLineSeparators error:nil];
    
    [self addToken:JLTokenTypeComment withIdentifier:LINE_COMMENT pattern:@"//.*+$" andScope:lineScope];
    
    // Preprocessor macros
    JLTokenPattern *preprocessor = [self addToken:JLTokenTypePreprocessor withIdentifier:nil pattern:@"^#.*+$" andScope:lineScope];
    
    // #import <Library/Library.h>
    // In xcode it only works for #import and #include, not all preprocessor statements.
    [self addToken:JLTokenTypeString withPattern:@"<.*?>" andScope:preprocessor];
    
    // Strings
    [[self addToken:JLTokenTypeString withPattern:@"(\"|@\")[^\"\\n]*(@\"|\")" andScope:lineScope] addScope:preprocessor];
    
    // Numbers
    [self addToken:JLTokenTypeNumber withPattern:@"(?<=\\s)\\d+" andScope:lineScope];
    
    // New literals, for example @[]
    // TODO: Highlight the closing bracket too, but with some special "nested-token-pattern"
    [[self addToken:JLTokenTypeNumber withPattern:@"@[\\[|\\{|\\(]" andScope:lineScope] setOpaque:NO];
    
    // C function names
    [[self addToken:JLTokenTypeOtherMethodNames withPattern:@"\\w+\\s*(?>\\(.*\\)" andScope:lineScope] setCaptureGroup:1];
    
    // Dot notation
    [[self addToken:JLTokenTypeOtherMethodNames withPattern:@"\\.(\\w+)" andScope:lineScope] setCaptureGroup:1];
    
    // Method Calls
    [[self addToken:JLTokenTypeOtherMethodNames withPattern:@"(\\w+)\\]" andScope:lineScope] setCaptureGroup:1];
    
    // Method call parts
    [[self addToken:JLTokenTypeOtherMethodNames withPattern:@"(?<=\\w+):" andScope:lineScope] setCaptureGroup:0];
    
    NSString *keywords = @"true false yes no YES TRUE FALSE bool BOOL nil id void self NULL if else strong weak nonatomic atomic assign copy typedef enum auto break case const char continue do default double extern float for goto int long register return short signed sizeof static struct switch typedef union unsigned volatile while nonatomic atomic nonatomic readonly super";
    
    [self addToken:JLTokenTypeKeyword withKeywords:keywords andScope:lineScope];
    [self addToken:JLTokenTypeKeyword withPattern:@"@[a-zA-Z0-9_]+" andScope:lineScope];
    
    // Other Class Names
    [self addToken:JLTokenTypeOtherClassNames withPattern:@"\\b[A-Z]{3}[a-zA-Z]*\\b" andScope:lineScope];
    
    [documentScope addSubscope:lineScope];
    
    self.documentScope = documentScope;
    self.lineScope = lineScope;
}

- (JLScope *)documentScope
{
    if (!_documentScope) [self setup];
    return _documentScope;
}

- (JLScope *)lineScope
{
    if (!_lineScope) [self setup];
    return _lineScope;
}

#pragma mark - NSTextStorageDelegate

- (void)textStorage:(NSTextStorage *)textStorage willProcessEditing:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta
{
    
}

- (void)textStorage:(NSTextStorage *)textStorage didProcessEditing:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta
{
    _editedRange = editedRange;
    _editedLineRange = [textStorage.string lineRangeForRange:editedRange];
    
    if (textStorage.editedMask == NSTextStorageEditedAttributes) return;
    
    [self tokenizeTextStorage:textStorage withRange:_editedLineRange];
//    [self setNeedsValidation:YES];
}

#pragma mark - JLScope delegate

- (void)scope:(JLScope *)scope didChangeIndexesFrom:(NSIndexSet *)oldSet to:(NSIndexSet *)newSet
{
    if ([self.delegate respondsToSelector:@selector(scope:didFinishProcessing:)]) [self.delegate scope:scope didFinishProcessing:self];
    
    if ([self.documentScope.subscopes containsObject:scope] && scope != self.lineScope)
    {
        NSMutableIndexSet *removedIndexes = oldSet.mutableCopy;
        [removedIndexes removeIndexes:newSet];
        
        // Make sure the indexes still excist in the attributedString
        removedIndexes = [removedIndexes intersectionWithSet:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, scope.textStorage.length)]];
        
        ChromatismLog(@"Removed Indexes:%@",removedIndexes);
        
        if (removedIndexes) {
            [removedIndexes enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
                [self tokenizeTextStorage:scope.textStorage withRange:range];
            }];
        } 
    }
}

- (NSString *)mergedModifiedStringForScope:(JLScope *)scope
{
    NSString *newString = [scope.string substringWithRange:_editedLineRange];
    if (_oldString && newString) {
        return [_oldString stringByAppendingString:newString];
    }
    return nil;
}

- (NSDictionary *)attributesForScope:(JLScope *)scope
{
    UIColor *color = self.colors[scope.type];
    NSAssert(color, @"Didn't get a color for type:%@ in colorDictionary: %@",scope.type, self.colors);
    return @{ NSForegroundColorAttributeName : color };
}

#pragma mark - Tokenizing

- (void)tokenizeTextStorage:(NSTextStorage *)textStorage
{
    [self tokenizeTextStorage:textStorage withRange:NSMakeRange(0, textStorage.length)];
}

- (void)tokenizeTextStorage:(NSTextStorage *)storage withRange:(NSRange)range
{
    // First, remove old attributes
    [self clearColorAttributesInRange:range textStorage:storage];
    
    [self.documentScope setTextStorage:storage];
    [self.documentScope setSet:[NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, storage.length)]];
    [self.lineScope setSet:[NSMutableIndexSet indexSetWithIndexesInRange:range]];
    
    [self.documentScope perform];
}

#pragma mark - Validation

/*
- (void)setNeedsValidation:(BOOL)needsValidation
{
    _needsValidation = needsValidation;
    if (needsValidation) {
        [self.validationTimer invalidate]; // This is not necessary, right?
        self.validationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(validateTokenization) userInfo:nil repeats:NO];
    }
}

- (void)validateTokenization
{
    [self.textStorage beginEditing];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self tokenize];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setNeedsValidation:NO];
            [self.textStorage endEditing];
        });
    });
}
*/

+ (NSMutableAttributedString *)tokenizeString:(NSString *)string withDefaultAttributes:(NSDictionary *)attributes;
{
    NSMutableAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:attributes].mutableCopy;
    [[[self alloc] init] tokenizeTextStorage:(NSTextStorage *)attributedString withRange:NSMakeRange(0, string.length)];
    return attributedString;
}

#pragma mark - Helpers

- (JLTokenPattern *)addToken:(NSString *)type withPattern:(NSString *)pattern andScope:(JLScope *)scope
{
    return [self addToken:type withIdentifier:type pattern:pattern andScope:scope];
}

- (JLTokenPattern *)addToken:(NSString *)type withIdentifier:(NSString *)identifier pattern:(NSString *)pattern andScope:(JLScope *)scope
{
    NSParameterAssert(type);
    NSParameterAssert(pattern);
    NSParameterAssert(scope);
    
    JLTokenPattern *token = [JLTokenPattern tokenPatternWithPattern:pattern];
    token.identifier = identifier;
    token.type = type;
    token.delegate = self;
    [scope addSubscope:token];
    
    return token;
}

- (JLTokenPattern *)addToken:(NSString *)type withKeywords:(NSString *)keywords andScope:(JLScope *)scope
{
    NSString *pattern = [NSString stringWithFormat:@"\\b(%@)\\b", [[keywords componentsSeparatedByString:@" "] componentsJoinedByString:@"|"]];
    return [self addToken:type withPattern:pattern andScope:scope];
}

- (void)clearColorAttributesInRange:(NSRange)range textStorage:(NSTextStorage *)storage;
{
    [storage removeAttribute:NSForegroundColorAttributeName range:range];
    [storage addAttribute:NSForegroundColorAttributeName value:self.colors[JLTokenTypeText] range:range];
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
        
        NSString *prefixString = [@"\n" stringByAppendingString:[self prefixStringFromRange:range inTextView:textView]];
        
        NSString *lastCharacter = [textView.text substringWithRange:NSMakeRange(range.location - 1, 1)];
        if ([lastCharacter isEqualToString:@"{"]) {
            
            prefixString = [prefixString stringByAppendingString:@"    "];
        } else if ([lastCharacter isEqualToString:@"}"]) {
            if ([[prefixString substringFromIndex:prefixString.length - 4] isEqualToString:@"    "]) {
                prefixString = [prefixString substringToIndex:prefixString.length - 4];
            }
            else if ([[prefixString substringFromIndex:prefixString.length - 1] isEqualToString:@"\t"]) {
                prefixString = [prefixString substringToIndex:prefixString.length - 1];
            }
        }
        [textView replaceRange:[self rangeWithRange:range inTextView:textView] withText:prefixString];
        return NO;
    }
    
    if (range.length > 0) {
        _oldString = [textView.text substringWithRange:range];
    }
    else _oldString = @"";
    
    return YES;
}

#pragma mark - Helpers

- (UITextRange *)rangeWithRange:(NSRange)range inTextView:(UITextView *)textView
{
    UITextPosition *beginning = textView.beginningOfDocument;
    UITextPosition *start = [textView positionFromPosition:beginning offset:range.location];
    UITextPosition *stop = [textView positionFromPosition:start offset:range.length];
    
    return [textView textRangeFromPosition:start toPosition:stop];
}

- (NSString *)prefixStringFromRange:(NSRange)range inTextView:(UITextView *)textView
{
    NSRange lineRange = [textView.text lineRangeForRange:range];
    NSRange prefixRange = [textView.text rangeOfString:@"[\\t| ]*" options:NSRegularExpressionSearch range:lineRange];
    return [textView.text substringWithRange:prefixRange];
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
    unichar character = [layoutManager.textStorage.string characterAtIndex:charIndex];
    if (character == '*') return NO;
    return YES;
}

@end
