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
    NSAssert(textStorage == self.textStorage, @"A JLTokenizer should only handle one textStorage");
}

- (void)textStorage:(NSTextStorage *)textStorage didProcessEditing:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta
{
    NSAssert(textStorage == self.textStorage, @"A JLTokenizer should only handle one textStorage");
    _editedRange = editedRange;
    _editedLineRange = [textStorage.string lineRangeForRange:editedRange];
    
    [self tokenizeWithRange:_editedLineRange];
    [self setNeedsValidation:YES];
}

#pragma mark - JLScope delegate

- (void)scope:(JLScope *)scope didChangeIndexesFrom:(NSIndexSet *)oldSet to:(NSIndexSet *)newSet
{
    if ([self.delegate respondsToSelector:@selector(scope:didFinishProcessing:)]) [self.delegate scope:scope didFinishProcessing:self];
    
    if ([self.documentScope.subscopes containsObject:scope] && scope != self.lineScope)
    {
        NSMutableIndexSet *removedIndexes = oldSet.mutableCopy;
        [removedIndexes removeIndexes:newSet];
        
        ChromatismLog(@"Removed Indexes:%@",removedIndexes);
        
        if (removedIndexes) {
            [removedIndexes enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
                [self tokenizeWithRange:range];
            }];
        } 
    }
}

- (NSString *)mergedModifiedStringForScope:(JLScope *)scope
{
    NSString *oldString = [self.dataSource recentlyReplacedText];
    NSString *newString = [scope.string substringWithRange:_editedLineRange];
    if (oldString && newString) {
        return [oldString stringByAppendingString:newString];
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

- (void)tokenize
{
    [self tokenizeWithRange:NSMakeRange(0, self.textStorage.length)];
}

- (void)tokenizeWithRange:(NSRange)range
{
    // First, remove old attributes
    [self clearColorAttributesInRange:range textStorage:self.textStorage];
    
    [self.documentScope setTextStorage:self.textStorage];
    [self.documentScope setSet:[NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.textStorage.length)]];
    [self.lineScope setSet:[NSMutableIndexSet indexSetWithIndexesInRange:range]];
    
    [self.documentScope perform];
}


#pragma mark - Validation

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
        
        // This seem to be safe, is it?
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setNeedsValidation:NO];
            [self.textStorage endEditing];
        });
    });
}

/*
- (NSMutableAttributedString *)tokenizeString:(NSString *)string withDefaultAttributes:(NSDictionary *)attributes;
{
    NSMutableAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:attributes].mutableCopy;
    
    [self.documentScope setTextStorage:self.textStorage];
    [self.documentScope setSet:[NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.textStorage.length)]];
    
    [self.documentScope perform];
    
    return attributedString;
}
*/

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

@end
