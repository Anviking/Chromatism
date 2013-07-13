//
//  JLMarkdownTokenizer.m
//  Chromatism
//
//  Created by Johannes Lund on 2013-07-13.
//  Copyright (c) 2013 Anviking. All rights reserved.
//

#import "JLMarkdownTokenizer.h"
#import "NSMutableAttributedString+Mush.h"

@implementation JLMarkdownTokenizer

- (void)tokenizeTextStorage:(NSTextStorage *)storage withRange:(NSRange)range
{
    [NSException raise:@"Chromatism bad task" format:@"%@ cannot handle live syntax highlighting", self.class];
}

- (NSMutableAttributedString *)tokenizeString:(NSString *)string withDefaultAttributes:(NSDictionary *)attributes
{

    NSMutableAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:attributes].mutableCopy;
    
    // Get fonts
    UIFont *defaultFont = (UIFont *)attributes[NSFontAttributeName];
    UIFontDescriptor *defaultFontDescriptor = [defaultFont fontDescriptor];
    
    if (!self.boldFont)
    {
        UIFontDescriptor *descriptor = [defaultFontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
        self.boldFont = [UIFont fontWithDescriptor:descriptor size:descriptor.pointSize];
    }
    if (!self.italicFont)
    {
        UIFontDescriptor *descriptor = [defaultFontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic];
        self.italicFont = [UIFont fontWithDescriptor:descriptor size:descriptor.pointSize];
    }
    if (!self.monospaceFont)
    {
        self.monospaceFont = [UIFont fontWithName:@"Courier" size:defaultFontDescriptor.pointSize];
    }
    
    
    
    NSDictionary *boldParser = @{
                                 @"regex":@"(\\*{2})(.+?)(\\*{2})",
                                 @"replace":@[@"", @1, @""],
                                 @"attributes":@[@{ }, @{ NSFontAttributeName:self.boldFont }, @{ }]
                                 };
    
    NSDictionary *italicParser = @{
                                   @"regex":@"(\\*)(.+?)(\\*)",
                                   @"replace":@[@"", @1, @""],
                                   @"attributes":@[@{ }, @{ NSFontAttributeName:self.italicFont }, @{ }]
                                   };
    
    NSDictionary *monospaceParser = @{
                                      @"regex":@"(`)(.+?)(`)",
                                      @"replace":@[@"", @1, @""],
                                      @"attributes":@[@{ }, @{ NSFontAttributeName:self.monospaceFont, NSBackgroundColorAttributeName : [UIColor colorWithWhite:0 alpha:0.01] }, @{ }]
                                      };
    NSDictionary *linkParser = @{
                                      @"regex":@"(\\[)([^\\]]+)(\\])(\\()([^\\)]+)(\\))",
                                      @"replace":@[@"", @1, @"", @"", @"" , @""],
                                      };
    
    // Links
    NSString *markdown = attributedString.string.copy;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:linkParser[@"regex"] options:0 error:nil];
    
    __block int nudge = 0;
    [regex enumerateMatchesInString:markdown options:0 range:(NSRange){0, markdown.length} usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
        
        NSMutableArray *substrs = @[].mutableCopy;
        NSMutableArray *replacements = @[].mutableCopy;
        
        // fetch match substrings
        for (int i = 0; i < match.numberOfRanges - 1; i++) {
            NSRange nudged = [match rangeAtIndex:i + 1];
            nudged.location -= nudge;
            substrs[i] = [attributedString attributedSubstringFromRange:nudged].mutableCopy;
        }
        
        // make replacement substrings
        for (int i = 0; i < match.numberOfRanges - 1; i++) {
            NSString *repstr = linkParser[@"replace"][i];
            replacements[i] = [repstr isKindOfClass:NSNumber.class]
            ? substrs[repstr.intValue]
            : [[NSMutableAttributedString alloc] initWithString:repstr];
        }
        
        // apply attributes
    
        NSMutableAttributedString *repl = replacements[1];
        NSLog(@"Link is :%@",substrs[4]);
        [repl addAttribute:NSLinkAttributeName value:substrs[2] range:(NSRange){0, repl.length}];
        
        // replace
        for (int i = 0; i < match.numberOfRanges - 1; i++) {
            NSRange nudged = [match rangeAtIndex:i + 1];
            nudged.location -= nudge;
            nudge += [substrs[i] length] - [replacements[i] length];
            [attributedString replaceCharactersInRange:nudged
                      withAttributedString:replacements[i]];
        }
    }];
    
    [attributedString applyMushDictionary:boldParser];
    [attributedString applyMushDictionary:italicParser];
    [attributedString applyMushDictionary:monospaceParser];
    
    return attributedString;
}


@end
