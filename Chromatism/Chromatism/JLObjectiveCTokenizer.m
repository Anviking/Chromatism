//
//  JLObjectiveCTokenizer.m
//  Chromatism
//
//  Created by Johannes Lund on 2013-11-19.
//  Copyright (c) 2013 Anviking. All rights reserved.
//

#import "JLObjectiveCTokenizer.h"

@implementation JLObjectiveCTokenizer

- (void)prepareDocumentScope:(JLScope *)documentScope
{
    [super prepareDocumentScope:documentScope];
    
    JLTokenPattern *blockComment = [self addToken:JLTokenTypeComment withPattern:@"" andScope:documentScope];
    blockComment.expression = [NSRegularExpression regularExpressionWithPattern:@"/\\*.*?\\*/" options:NSRegularExpressionDotMatchesLineSeparators error:nil];
}

- (void)prepareLineScope:(JLScope *)lineScope
{
    [super prepareLineScope:lineScope];
    
    [self addToken:JLTokenTypeComment withPattern:@"//.*+$" andScope:lineScope];
    
    JLTokenPattern *preprocessor = [self addToken:JLTokenTypePreprocessor withPattern:@"^#.*+$" andScope:lineScope];
    
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
}

#pragma mark - Symbolication

- (void)prepareSymbolicateScope:(JLScope *)scope
{
    //NSString *pattern = [NSString stringWithFormat:@"\\b(%@)\\b", [[self symbolsWithPattern:@"^@implementation (\\w+)" captureGroup:1 textStorage:scope.textStorage] componentsJoinedByString:@"|"]];
    //JLTokenizer *pattern = [JLTokenPattern tokenPatternWithRegularExpression:[NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL]];

// [self.scopes[PROJECT_METHOD_NAMES] setPattern:[NSString stringWithFormat:@"\\b(%@)\\b", [[self symbolsWithPattern:@"^@property \\(.*?\\)\\s*\\w+[\\s*]+(\\w+);" captureGroup:1] componentsJoinedByString:@"|"]]];
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

@end
