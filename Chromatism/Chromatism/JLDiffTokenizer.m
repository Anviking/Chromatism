//
//  JLDiffTokenizer.m
//  Chromatism
//
//  Created by Johannes Lund on 2013-10-31.
//  Copyright (c) 2013 Anviking. All rights reserved.
//

#import "JLDiffTokenizer.h"

@implementation JLDiffTokenizer

+ (NSMutableAttributedString *)tokenizeString:(NSString *)string withDefaultAttributes:(NSDictionary *)attributes
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string attributes:attributes];
    
    NSRegularExpression *additionExpresssion = [[NSRegularExpression alloc] initWithPattern:@"^\\+.*?\\n" options:NSRegularExpressionAnchorsMatchLines | NSRegularExpressionDotMatchesLineSeparators error:NULL];
    NSRegularExpression *deletionExpression = [[NSRegularExpression alloc] initWithPattern:@"^-.*?\\n" options:NSRegularExpressionAnchorsMatchLines | NSRegularExpressionDotMatchesLineSeparators error:NULL];
    
    NSUInteger removedCharacters = 0;
    
    UIColor *additionColor = attributes[JLTokenTypeDiffAddition];
    UIColor *deletionColor = attributes[JLTokenTypeDiffDeletion];
    
    tokenizeStringWithExpression(additionExpresssion, string, attributedString, &removedCharacters, additionColor);
    tokenizeStringWithExpression(deletionExpression, string, attributedString, &removedCharacters, deletionColor);
    
    return attributedString;
}

void tokenizeStringWithExpression(NSRegularExpression *expression, NSString *string, NSMutableAttributedString *attributedString, NSUInteger *removedCharacters, UIColor *color)
{
    __block NSUInteger integer = *removedCharacters;
    NSRange range = NSMakeRange(0, string.length);
    [expression enumerateMatchesInString:string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSUInteger location = result.range.location - integer;
        NSRange lineRange = NSMakeRange(location, result.range.length);
        NSRange tokenRange = NSMakeRange(location, 1);
        
        [attributedString addAttribute:JLDiffColorAttributeName value:color range:lineRange];
        [attributedString deleteCharactersInRange:tokenRange];
        integer++;
    }];
    *removedCharacters = integer;
}

@end
