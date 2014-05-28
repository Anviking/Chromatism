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
#import "Chromatism+Internal.h"

@interface JLTokenizer ()
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSMutableDictionary *expressions;
@end

@implementation JLTokenizer

#pragma mark - Setup

- (id)init
{
    self = [super init];
    if (self) {
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}


- (void)waitUntilFinished
{
    [self.operationQueue waitUntilAllOperationsAreFinished];
}

#pragma mark - NSTextStorageDelegate

- (void)textStorage:(NSTextStorage *)textStorage willProcessEditing:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta
{
    
}

- (void)textStorage:(NSTextStorage *)textStorage didProcessEditing:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta
{
    if (textStorage.editedMask == NSTextStorageEditedAttributes) return;
    [self tokenizeTextStorage:textStorage withScope:[self documentScopeForTokenizingTextStorage:textStorage inRange:editedRange]];
}

#pragma mark - NSLayoutManager delegeate

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

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (![text isEqualToString:@"\n"]) return YES; // Something else than return
    
    // Return has been pressed, start the new line with as many tabs or white spaces as the previous one.
    NSString *prefixString = [@"\n" stringByAppendingString:[self prefixStringFromRange:range inTextView:textView]];
    
    unichar previousCharacter = [textView.text characterAtIndex:range.location - 1];
    switch ([self intendationActionAfterReplacingTextInRange:range replacementText:text previousCharacter:previousCharacter textView:textView]) {
        case JLTokenizerIntendtationActionIncrease:
            prefixString = [prefixString stringByAppendingString:@"    "];
            break;
        case JLTokenizerIntendtationActionDecrease:
            if ([[prefixString substringFromIndex:prefixString.length - 4] isEqualToString:@"    "]) {
                prefixString = [prefixString substringToIndex:prefixString.length - 4];
            }
            else if ([[prefixString substringFromIndex:prefixString.length - 1] isEqualToString:@"\t"]) {
                prefixString = [prefixString substringToIndex:prefixString.length - 1];
            }
            break;
        case JLTokenizerIntendtationActionNone:
            break;
    }
    
    [textView replaceRange:[self rangeWithRange:range inTextView:textView] withText:prefixString];
    return NO;
}


#pragma mark - Tokenizing

- (void)refreshTokenizationOfTextStorage:(NSTextStorage *)textStorage;
{
    [self tokenizeTextStorage:textStorage withScope:[self documentScopeForTokenizingTextStorage:textStorage inRange:NSMakeRange(0, textStorage.length)]];
}

- (JLScope *)documentScopeForTokenizingTextStorage:(NSTextStorage *)textStorage inRange:(NSRange)range
{
    JLScope *documentScope = [JLScope new];
    JLScope *lineScope = [JLScope new];
    
    [self prepareDocumentScope:documentScope];
    [self prepareLineScope:lineScope];
    
    [documentScope addSubscope:lineScope];
    
    [self clearColorAttributesInRange:range textStorage:textStorage];
    
    [documentScope setTextStorage:textStorage];
    [documentScope setSet:[NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, textStorage.length)]];
    [lineScope setSet:[NSMutableIndexSet indexSetWithIndexesInRange:[textStorage.string lineRangeForRange:range]]];
    
    return documentScope;
}

- (void)tokenizeTextStorage:(NSTextStorage *)textStorage withScope:(JLScope *)scope
{
    //[textStorage beginEditing];
    [self.operationQueue addOperations:[[scope recursiveSubscopes] allObjects] waitUntilFinished:YES];
    //[textStorage endEditing];
}

#pragma mark - Setup Token Patterns

- (void)prepareDocumentScope:(JLScope *)documentScope
{

}

- (void)prepareLineScope:(JLScope *)lineScope
{

}


#pragma mark - Symbolication

/*
- (void)symbolicate
{
    [self.scopes[PROJECT_CLASS_NAMES] setPattern:[NSString stringWithFormat:@"\\b(%@)\\b", [[self symbolsWithPattern:@"^@implementation (\\w+)" captureGroup:1] componentsJoinedByString:@"|"]]];
    [self.scopes[PROJECT_METHOD_NAMES] setPattern:[NSString stringWithFormat:@"\\b(%@)\\b", [[self symbolsWithPattern:@"^@property \\(.*?\\)\\s*\\w+[\\s*]+(\\w+);" captureGroup:1] componentsJoinedByString:@"|"]]];
}
*/

#pragma mark - Helpers

- (JLTokenPattern *)addToken:(NSString *)type withPattern:(NSString *)pattern andScope:(JLScope *)scope
{

    NSParameterAssert(type);
    NSParameterAssert(pattern);
    NSParameterAssert(scope);
    
    NSRegularExpression *expression = self.expressions[pattern];
    if (expression) {
        self.expressions[pattern] = expression;
    } else {
        expression = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionAnchorsMatchLines error:NULL];
        self.expressions[pattern] = expression;
    }
    
    JLTokenPattern *token = [JLTokenPattern tokenPatternWithRegularExpression:expression];
    token.type = type;
    token.color = self.colors[type];

    [token addScope:scope];
    
    return token;
}

- (JLTokenPattern *)addToken:(NSString *)type withKeywords:(NSString *)keywords andScope:(JLScope *)scope
{
    NSString *pattern = [NSString stringWithFormat:@"\\b(%@)\\b", [[keywords componentsSeparatedByString:@" "] componentsJoinedByString:@"|"]];
    return [self addToken:type withPattern:pattern andScope:scope];
}

- (NSMutableArray *)symbolsWithPattern:(NSString *)pattern captureGroup:(int)group textStorage:(NSTextStorage *)textStorage
{
    NSMutableArray *array = [NSMutableArray array];
    NSError *error = nil;
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionAnchorsMatchLines error:&error];
    [expression enumerateMatchesInString:textStorage.string options:0 range:NSMakeRange(0, textStorage.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        [array addObject:[textStorage.string substringWithRange:[result rangeAtIndex:group]]];
    }];
    NSAssert(!error, @"%@",error);
    return array;
}

- (JLTokenizerIntendtationAction)intendationActionAfterReplacingTextInRange:(NSRange)range replacementText:(NSString *)text previousCharacter:(unichar)character textView:(UITextView *)textView;
{
    if (character == '{') {
        return JLTokenizerIntendtationActionIncrease;
    } else if (character == '}') {
        return JLTokenizerIntendtationActionDecrease;
    } else {
        return JLTokenizerIntendtationActionNone;
    }
}

#pragma mark - Helpers

- (UITextRange *)rangeWithRange:(NSRange)range inTextView:(UITextView *)textView
{
    UITextPosition *beginning = textView.beginningOfDocument;
    UITextPosition *start = [textView positionFromPosition:beginning offset:range.location];
    UITextPosition *stop = [textView positionFromPosition:start offset:range.length];
    
    return [textView textRangeFromPosition:start toPosition:stop];
}

- (void)clearColorAttributesInRange:(NSRange)range textStorage:(NSTextStorage *)storage;
{
    [storage removeAttribute:NSForegroundColorAttributeName range:range];
    [storage addAttribute:NSForegroundColorAttributeName value:self.colors[JLTokenTypeText] range:range];
}

- (NSString *)prefixStringFromRange:(NSRange)range inTextView:(UITextView *)textView
{
    NSRange lineRange = [textView.text lineRangeForRange:range];
    NSRange prefixRange = [textView.text rangeOfString:@"[\\t| ]*" options:NSRegularExpressionSearch range:lineRange];
    return [textView.text substringWithRange:prefixRange];
}

@end
