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


@interface NSMutableAttributedString (Regex)
- (void)addRanges:(NSArray *)array withColor:(UIColor *)color;
- (void)addRanges:(NSArray *)array withAttributes:(NSDictionary *)colors;
- (NSArray *)allMatchesOfPattern:(NSString *)pattern inString:(NSString *)string;

- (NSMutableIndexSet *)addRegularExpressionWithPattern:(NSString *)pattern withColor:(UIColor *)color group:(int)index indexSet:(NSIndexSet *)indexSet andDescription:(NSString *)description;
- (NSMutableIndexSet *)addRegularExpressionWithPattern:(NSString *)pattern withColor:(UIColor *)color indexSet:(NSIndexSet *)indexSet andDescription:(NSString *)description;

- (void)addRegularExpressionWithPattern:(NSString *)pattern withColor:(UIColor *)color andDescription:(NSString *)description;
- (void)addRegularExpressionWithPattern:(NSString *)pattern withColor:(UIColor *)color range:(NSRange)range andDescription:(NSString *)description;
- (void)addRegularExpressionWithPattern:(NSString *)pattern withColor:(UIColor *)color group:(int)index range:(NSRange)range andDescription:(NSString *)description;
- (void)removeAttribute:(NSString *)name withValue:(id)compareValue range:(NSRange)range;
@end

@interface JLTokenizer ()

@end

@implementation JLTokenizer

- (void)tokenizeTextStorage:(NSTextStorage *)storage withRange:(NSRange)range
{
    // First, remove old attributes
    [self clearColorAttributesInRange:range textStorage:storage];
    
    NSIndexSet *stringIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, storage.length)];
    NSMutableIndexSet *set = [[NSIndexSet alloc] initWithIndexesInRange:range].mutableCopy;
    
    NSDictionary *colors = self.colors;
 
    UIColor *color = color = colors[JLTokenTypeComment];
    NSMutableIndexSet *comments1 = [storage addRegularExpressionWithPattern:@"/\\*([^*]|[\\r\\n]|(\\*+([^*/]|[\\r\\n])))*\\*+/" withColor:color indexSet:stringIndexes andDescription:@"Comments"];
    [set removeIndexes:comments1];
    
    NSMutableIndexSet *comments2 = [storage addRegularExpressionWithPattern:@"//.*+\n" withColor:color indexSet:set andDescription:@"Comments"];
    [set removeIndexes:comments2];
    
    color = colors[JLTokenTypePreprocessor];
    NSMutableIndexSet *preprocessor = [storage addRegularExpressionWithPattern:@"#.*+\n" withColor:color indexSet:set andDescription:@"Preprocessor"];
    [set removeIndexes:preprocessor];
    
    color = colors[JLTokenTypeString];
    NSMutableIndexSet *strings1 = [storage addRegularExpressionWithPattern:@"(\"|@\")[^\"\\n]*(@\"|\")" withColor:color indexSet:set andDescription:@"Strings"];
    [set removeIndexes:strings1];
    NSMutableIndexSet *strings2 = [storage addRegularExpressionWithPattern:@"(\"|@\")[^\"\\n]*(@\"|\")" withColor:color indexSet:preprocessor andDescription:@"Strings"];
    [set removeIndexes:strings2];
    
    color = colors[JLTokenTypeNumber];
    [storage addRegularExpressionWithPattern:@"(?<=\\s)\\d+" withColor:color indexSet:set  andDescription:@"Numbers"];
    
    [storage addRegularExpressionWithPattern:@"@\\s*[\(|\{|\[]" withColor:color indexSet:set andDescription:@"New literals"];
    
    //C – functions and similiar
    color = colors[JLTokenTypeOtherMethodNames];
    [storage addRegularExpressionWithPattern:@"\\w+\\s*(?>\\(.*\\)" withColor:color group:1 indexSet:set andDescription:@"C function names"];
    
    //Dot notation
    [storage addRegularExpressionWithPattern:@"\\.(\\w+)" withColor:color group:1 indexSet:set andDescription:@"Dot notation"];
    
    //Method calls
    [storage addRegularExpressionWithPattern:@"\\[\\w+\\s+(\\w+)\\]" withColor:color group:1 indexSet:set andDescription:@"Method calls"];
    [storage addRegularExpressionWithPattern:@"(?<=\\w+):\\s*[^\\s;\\]]+" withColor:color group:1 indexSet:set andDescription:@"Method calls parts"];
    
    color = colors[JLTokenTypeOtherClassNames];
    [storage addRegularExpressionWithPattern:@"(\\b(?>NS|UI))\\w+\\b" withColor:color indexSet:set andDescription:@"UIKit and NS"];
    
    color = colors[JLTokenTypeKeyword];
    [storage addRegularExpressionWithPattern:@"(?<=\\b)(?>true|false|yes|no|TRUE|FALSE|bool|BOOL|nil|id|void|self|NULL|if|else|strong|weak|nonatomic|atomic|assign|copy|typedef|enum|auto|break|case|const|char|continue|do|default|double|extern|float|for|goto|int|long|register|return|short|signed|sizeof|static|struct|switch|typedef|union|unsigned|volatile|while|nonatomic|atomic|readonly)(\\b)" withColor:color indexSet:set andDescription:@"Keywords"];
    
    
    [storage addRegularExpressionWithPattern:@"@[a-zA-Z0-9_]+" withColor:color indexSet:set andDescription:@"@things"];
    

    

    
}

- (void)clearColorAttributesInRange:(NSRange)range textStorage:(NSTextStorage *)storage;
{
    //Clear the comments to later be rebuilt
    UIColor *compareColor = self.colors[JLTokenTypeComment];
    [storage removeAttribute:NSForegroundColorAttributeName withValue:compareColor range:range];
    
    [storage removeAttribute:NSForegroundColorAttributeName range:range];
    [storage addAttribute:NSForegroundColorAttributeName value:self.colors[JLTokenTypeText] range:range];
}

#pragma mark - Pattern Helpers

// TODO: Extend this

- (NSString *)patternBetweenString:(NSString *)start andString:(NSString *)stop
{
    return nil;
}


@end

#pragma mark - Regex Helpers


@implementation NSTextStorage (Regex)

- (void)removeAttribute:(NSString *)name withValue:(id)compareValue range:(NSRange)range
{
    [self enumerateAttribute:NSForegroundColorAttributeName inRange:range options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        if ([value isEqual:compareValue]) {
            [self removeAttribute:NSForegroundColorAttributeName range:range];
        }
        
    }];
}


- (void)addRanges:(NSArray *)array withColor:(UIColor *)color
{
    for (NSValue *value in array) {
        NSAssert(value.rangeValue.location < self.string.length, @"Range should be within the string");
        [self removeAttribute:NSForegroundColorAttributeName range:value.rangeValue];
        [self addAttribute:NSForegroundColorAttributeName value:color range:value.rangeValue];
    }
}

- (void)addRanges:(NSArray *)array withAttributes:(NSDictionary *)dic
{
    for (NSValue *value in array) {
        if (value.rangeValue.location + value.rangeValue.length <= self.length){
            NSAssert(value.rangeValue.location < self.string.length, @"Range should be within the string");
            [self removeAttribute:NSForegroundColorAttributeName range:value.rangeValue];
            [self addAttributes:dic range:value.rangeValue];
        }
    }
}

- (NSArray *)allMatchesOfPattern:(NSString *)pattern inString:(NSString *)string
{
    NSArray *mathces = [[NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil] matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    
    return mathces;
}

- (void)addRegularExpressionWithPattern:(NSString *)pattern withColor:(UIColor *)color group:(int)index range:(NSRange)range andDescription:(NSString *)description
{
    NSString *string = self.string;
    
    
    NSRegularExpression* expression = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionAnchorsMatchLines error:nil];
    
    [expression enumerateMatchesInString:string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSAssert(range.location < string.length, @"Range should be within the string");
        [self addAttribute:NSForegroundColorAttributeName value:color range:[result rangeAtIndex:index]];
    }];
}

// indexSet is a indexset containing the available indexes for tokenizing
- (NSMutableIndexSet *)addRegularExpressionWithPattern:(NSString *)pattern withColor:(UIColor *)color indexSet:(NSMutableIndexSet **)indexSet andDescription:(NSString *)description
{
    __block NSMutableIndexSet *restultSet = [NSIndexSet indexSet].mutableCopy;
    NSRegularExpression* expression = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionAnchorsMatchLines error:nil];
    __weak typeof(self) _self = self;

    [*indexSet enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
        [expression enumerateMatchesInString:self.string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            NSAssert(range.location < self.length, @"Range should be within the string");
            [_self addAttribute:NSForegroundColorAttributeName value:color range:[result range]];
            [restultSet addIndexesInRange:[result range]];
        }];
    }];
    
    [*indexSet removeIndexes:restultSet];
    return restultSet;
}

- (NSMutableIndexSet *)addRegularExpressionWithPattern:(NSString *)pattern withColor:(UIColor *)color group:(int)index indexSet:(NSMutableIndexSet **)indexSet andDescription:(NSString *)description
{
    NSString *string = self.string;
    __block NSMutableIndexSet *restultSet = [NSIndexSet indexSet].mutableCopy;
    __weak typeof(self) _self = self;
    
    NSRegularExpression* expression = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionAnchorsMatchLines error:nil];
    [*indexSet enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
        [expression enumerateMatchesInString:string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            NSAssert(range.location < string.length, @"Range should be within the string");
            [_self addAttribute:NSForegroundColorAttributeName value:color range:[result rangeAtIndex:index]];
            [restultSet addIndexesInRange:[result rangeAtIndex:index]];
        }];
    }];
    [*indexSet removeIndexes:restultSet];
    return restultSet;
}

- (void)addRegularExpressionWithPattern:(NSString *)pattern withColor:(UIColor *)color andDescription:(NSString *)description
{
    [self addRegularExpressionWithPattern:pattern withColor:color range:NSMakeRange(0, self.length) andDescription:description];
}


@end
