//
//  NSMutableAttributedString+Mush.m
//  Chromatism
//
//  Created by Johannes Lund on 2013-07-13.
//  Copyright (c) 2013 Anviking. All rights reserved.
//

// Original from sobri909/MGBox2
//
// Created by matt on 7/11/12.
//
// https://github.com/sobri909/MGBox2/blob/master/MGBox/MGMushParser.m
//
//

#import "NSMutableAttributedString+Mush.h"

@implementation NSMutableAttributedString (Mush)

- (void)applyMushDictionary:(NSDictionary *)parser
{
    id regex = [NSRegularExpression regularExpressionWithPattern:parser[@"regex"]
                                                         options:0 error:nil];
    NSString *markdown = self.string.copy;
    
    __block int nudge = 0;
    [regex enumerateMatchesInString:markdown options:0 range:(NSRange){0, markdown.length} usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
        
        NSMutableArray *substrs = @[].mutableCopy;
        NSMutableArray *replacements = @[].mutableCopy;
        
        // fetch match substrings
        for (int i = 0; i < match.numberOfRanges - 1; i++) {
            NSRange nudged = [match rangeAtIndex:i + 1];
            nudged.location -= nudge;
            substrs[i] = [self attributedSubstringFromRange:nudged].mutableCopy;
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
            [self replaceCharactersInRange:nudged
                      withAttributedString:replacements[i]];
        }
    }];
}

@end
