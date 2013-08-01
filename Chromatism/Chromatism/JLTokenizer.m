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
    JLTokenPattern *blockComment = [self addToken:JLTokenTypeComment withIdentifier:BLOCK_COMMENT pattern:@"/\\*([^*]|[\\r\\n]|(\\*+([^*/]|[\\r\\n])))*\\*+/" andScope:documentScope];
    blockComment.triggeringCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"/*"];
    
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
    // TODO: Literals don't search through multiple lines. Nor does it keep track of nested things.
    [[self addToken:JLTokenTypeNumber withPattern:@"@[\\(|\\{|\\[][^\\(\\{\\[]+[\\)|\\}|\\]]" andScope:lineScope] setOpaque:NO];
    
    // C function names
    [[self addToken:JLTokenTypeOtherMethodNames withPattern:@"\\w+\\s*(?>\\(.*\\)" andScope:lineScope] setCaptureGroup:1];
    
    // Dot notation
    [[self addToken:JLTokenTypeOtherMethodNames withPattern:@"\\.(\\w+)" andScope:lineScope] setCaptureGroup:1];
    
    // Method Calls
    [[self addToken:JLTokenTypeOtherMethodNames withPattern:@"\\[\\w+\\s+(\\w+)\\]" andScope:lineScope] setCaptureGroup:1];
    
    // Method call parts
    [[self addToken:JLTokenTypeOtherMethodNames withPattern:@"(?<=\\w+):\\s*[^\\s;\\]]+" andScope:lineScope] setCaptureGroup:1];
    
    [self addToken:JLTokenTypeKeyword withPattern:@"\\b(true|false|yes|no|TRUE|FALSE|bool|BOOL|nil|id|void|self|NULL|if|else|strong|weak|nonatomic|atomic|assign|copy|typedef|enum|auto|break|case|const|char|continue|do|default|double|extern|float|for|goto|int|long|register|return|short|signed|sizeof|static|struct|switch|typedef|union|unsigned|volatile|while|nonatomic|atomic|nonatomic|readonly|super)\\b" andScope:lineScope];
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
    // Measure performance
    NSDate *date = [NSDate date];
   [self tokenizeTextStorage:textStorage withRange:_editedLineRange];
    NSLog(@"Chromatism done tokenizing with time of %fms",ABS([date timeIntervalSinceNow]*1000));
}

#pragma mark - JLScope delegate

- (void)scopeDidFinishPerforming:(JLScope *)scope
{
    if ([self.delegate respondsToSelector:@selector(scope:didFinishProcessing:)]) [self.delegate scope:scope didFinishProcessing:self];
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

#pragma mark - Tokenizing

- (BOOL)characters:(NSString *)characters appearInString:(NSString *)string
{
    if (!characters && !string) return NO;
    return ([string rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:characters]].location != NSNotFound);
}

- (void)tokenizeTextStorage:(NSTextStorage *)storage withRange:(NSRange)range
{
    // First, remove old attributes
    [self clearColorAttributesInRange:range textStorage:storage];
    
    [self.documentScope reset];
    
    [self.documentScope setTextStorage:storage];
    [self.documentScope.set addIndexesInRange:NSMakeRange(0, storage.length)];
    [self.lineScope.set addIndexesInRange:range];
    
    [self.documentScope perform];
}

- (NSMutableAttributedString *)tokenizeString:(NSString *)string withDefaultAttributes:(NSDictionary *)attributes;
{
    NSMutableAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:attributes].mutableCopy;
    [self tokenizeTextStorage:(NSTextStorage *)attributedString withRange:NSMakeRange(0, string.length)];
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
    UIColor *color = self.colors[type];
    
    NSAssert(color, @"%@ didn't return a color in color dictionary %@", type, self.colors);
    
    JLTokenPattern *token = [JLTokenPattern tokenPatternWithPattern:pattern andColor:self.colors[type]];
    token.identifier = identifier;
    token.type = type;
    token.delegate = self;
    [scope addSubscope:token];
    
    return token;
}

- (void)clearColorAttributesInRange:(NSRange)range textStorage:(NSTextStorage *)storage;
{
    [storage removeAttribute:NSForegroundColorAttributeName range:range];
    [storage addAttribute:NSForegroundColorAttributeName value:self.colors[JLTokenTypeText] range:range];
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


@end
