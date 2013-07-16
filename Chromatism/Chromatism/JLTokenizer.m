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

@interface JLTokenizer ()

@end

@implementation JLTokenizer

- (void)tokenizeTextStorage:(NSTextStorage *)storage withRange:(NSRange)range
{
    // Measure performance
    NSDate *date = [NSDate date];
    
    // First, remove old attributes
    [self clearColorAttributesInRange:range textStorage:storage];

    JLScope *documentScope = [JLScope scopeWithTextStorage:storage];
    JLScope *rangeScope = [JLScope scopeWithRange:range inTextStorage:storage];

    NSDictionary *colors = self.colors;
 
    // Two types of comments
    JLTokenPattern *comments1 = [JLTokenPattern tokenPatternWithPattern:@"/\\*([^*]|[\\r\\n]|(\\*+([^*/]|[\\r\\n])))*\\*+/" andColor:colors[JLTokenTypeComment]];
    JLTokenPattern *comments2 = [JLTokenPattern tokenPatternWithPattern:@"//.*+$" andColor:colors[JLTokenTypeComment]];
    
    // Preprocessor macros
    JLTokenPattern *preprocessor = [JLTokenPattern tokenPatternWithPattern:@"#.*+$" andColor:colors[JLTokenTypePreprocessor]];
    
    // Strings
    JLTokenPattern *strings = [JLTokenPattern tokenPatternWithPattern:@"(\"|@\")[^\"\\n]*(@\"|\")" andColor:colors[JLTokenTypeString]];
    [strings addScope:preprocessor];
    
    // Numbers
    JLTokenPattern *numbers = [JLTokenPattern tokenPatternWithPattern:@"(?<=\\s)\\d+" andColor:colors[JLTokenTypeNumber]];
    
    // New literals, for example @[]
    JLTokenPattern *literals = [JLTokenPattern tokenPatternWithPattern:@"@[\\(|\\{|\\[][^\\(\\{\\[]+[\\)|\\}|\\]]" andColor:colors[JLTokenTypeNumber]]; // New literals
    
    // TODO: Literals don't search through multiple lines. Nor does it keep track of nested things.
    literals.opaque = NO;
    
    // C function names
    JLTokenPattern *functions = [JLTokenPattern tokenPatternWithPattern:@"\\w+\\s*(?>\\(.*\\)" andColor:colors[JLTokenTypeOtherMethodNames]];
    functions.captureGroup = 1;
    
    // Dot notation
    JLTokenPattern *dots = [JLTokenPattern tokenPatternWithPattern:@"\\.(\\w+)" andColor:colors[JLTokenTypeOtherMethodNames]];
    dots.captureGroup = 1;
    
    // Method Calls
    JLTokenPattern *methods1 = [JLTokenPattern tokenPatternWithPattern:@"\\[\\w+\\s+(\\w+)\\]" andColor:colors[JLTokenTypeOtherMethodNames]];
    methods1.captureGroup = 1;
    
    // Method call parts
    JLTokenPattern *methods2 = [JLTokenPattern tokenPatternWithPattern:@"(?<=\\w+):\\s*[^\\s;\\]]+" andColor:colors[JLTokenTypeOtherMethodNames]];
    methods2.captureGroup = 1;
    
    // NS and UI prefixes words
    JLTokenPattern *appleClassNames = [JLTokenPattern tokenPatternWithPattern:@"(\\b(?>NS|UI))\\w+\\b" andColor:colors[JLTokenTypeOtherClassNames]];
    JLTokenPattern *keywords1 = [JLTokenPattern tokenPatternWithPattern:@"(?<=\\b)(?>true|false|yes|no|TRUE|FALSE|bool|BOOL|nil|id|void|self|NULL|if|else|strong|weak|nonatomic|atomic|assign|copy|typedef|enum|auto|break|case|const|char|continue|do|default|double|extern|float|for|goto|int|long|register|return|short|signed|sizeof|static|struct|switch|typedef|union|unsigned|volatile|while|nonatomic|atomic|nonatomic|readonly|super )(\\b)" andColor:colors[JLTokenTypeKeyword]];
    JLTokenPattern *keywords2 = [JLTokenPattern tokenPatternWithPattern:@"@[a-zA-Z0-9_]+" andColor:colors[JLTokenTypeKeyword]];
    
    documentScope.subscopes = @[comments1, rangeScope];
    rangeScope.subscopes = @[comments2, preprocessor, strings, numbers, literals, functions, dots, methods1, methods2, appleClassNames, keywords1, keywords2];
    
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

@end
