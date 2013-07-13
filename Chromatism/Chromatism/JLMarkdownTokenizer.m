//
//  JLMarkdownTokenizer.m
//  Chromatism
//
//  Created by Johannes Lund on 2013-07-13.
//  Copyright (c) 2013 Anviking. All rights reserved.
//

#import "JLMarkdownTokenizer.h"

@implementation JLMarkdownTokenizer

- (void)tokenizeTextStorage:(NSTextStorage *)storage withRange:(NSRange)range
{
    [NSException raise:@"Chromatism bad task" format:@"%@ cannot handle live syntax highlighting", self.class];
}

- (NSMutableAttributedString *)tokenizeString:(NSString *)string withDefaultAttributes:(NSDictionary *)attributes
{
    NSString *markup = @"**bold**, //italics//, __underlining__, `monospacing`, and {#0000FF|text colour}";
    
    UIFont *baseFont = [UIFont fontWithName:@"HelveticaNeue" size:18];
    UIColor *textColor = UIColor.whiteColor;
    
}

//
// Created by matt on 7/11/12.
//
// https://github.com/sobri909/MGBox2/blob/master/MGBox/MGMushParser.m
//
// Slightly modified

- (void)parse {
    
    
    // patterns
    NSDictionary *boldParser = @{
                      @"regex":@"(\\*{2})(.+?)(\\*{2})",
                      @"replace":@[@"", @1, @""],
                      @"attributes":@[@{ }, @{ NSFontAttributeName:bold }, @{ }]
                      };
    
    NSDictionary *italicParser = @{
                        @"regex":@"(/{2})(.+?)(/{2})",
                        @"replace":@[@"", @1, @""],
                        @"attributes":@[@{ }, @{ NSFontAttributeName:italic }, @{ }]
                        };
    
    NSDictionary *underlineParser = @{
                           @"regex":@"(_{2})(.+?)(_{2})",
                           @"replace":@[@"", @1, @""],
                           @"attributes":@[@{ }, @{ NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle) }, @{ }]
                           };
    
    NSDictionary *monospaceParser = @{
                           @"regex":@"(`)(.+?)(`)",
                           @"replace":@[@"", @1, @""],
                           @"attributes":@[@{ }, @{ NSFontAttributeName:monospace }, @{ }]
                           };
    
    [self applyParser:boldParser];
    [self applyParser:italicParser];
    [self applyParser:underlineParser];
    [self applyParser:monospaceParser];
}

- (void)applyParser:(NSDictionary *)parser {
    id regex = [NSRegularExpression regularExpressionWithPattern:parser[@"regex"]
                                                         options:0 error:nil];
    NSString *markdown = working.string.copy;
    
    __block int nudge = 0;
    [regex enumerateMatchesInString:markdown options:0
                              range:(NSRange){0, markdown.length}
                         usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags,
                                      BOOL *stop) {
                             
                             NSMutableArray *substrs = @[].mutableCopy;
                             NSMutableArray *replacements = @[].mutableCopy;
                             
                             // fetch match substrings
                             for (int i = 0; i < match.numberOfRanges - 1; i++) {
                                 NSRange nudged = [match rangeAtIndex:i + 1];
                                 nudged.location -= nudge;
                                 substrs[i] = [working attributedSubstringFromRange:nudged].mutableCopy;
                             }
                             
                             // make replacement substrings
                             for (int i = 0; i < match.numberOfRanges - 1; i++) {
                                 NSString *repstr = parser[@"replace"][i];
                                 replacements[i] = [repstr isKindOfClass:NSNumber.class]
                                 ? substrs[repstr.intValue]
                                 : [[NSMutableAttributedString alloc] initWithString:repstr];
                             }
                             
                             // apply attributes
                             for (int i = 0; i < match.numberOfRanges - 1; i++) {
                                 id attributes = parser[@"attributes"][i];
                                 if (attributes) {
                                     NSMutableAttributedString *repl = replacements[i];
                                     [repl addAttributes:attributes range:(NSRange){0, repl.length}];
                                 }
                             }
                             
                             // replace
                             for (int i = 0; i < match.numberOfRanges - 1; i++) {
                                 NSRange nudged = [match rangeAtIndex:i + 1];
                                 nudged.location -= nudge;
                                 nudge += [substrs[i] length] - [replacements[i] length];
                                 [working replaceCharactersInRange:nudged
                                              withAttributedString:replacements[i]];
                             }
                         }];
}


@end
