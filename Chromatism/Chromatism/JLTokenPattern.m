//
//  JLTokenPattern.m
//  iGitpad
//
//  Created by Johannes Lund on 2013-06-30.
//  Copyright (c) 2013 Anviking. All rights reserved.
//

#import "JLTokenPattern.h"

@implementation JLTokenPattern

#pragma mark - Initialization

+ (instancetype)tokenPatternWithPattern:(NSString *)pattern andColor:(UIColor *)color
{
    JLTokenPattern *tokenPattern = [JLTokenPattern new];
    tokenPattern.color = color;
    tokenPattern.pattern = pattern;
    return tokenPattern;
}

- (id)init
{
    self = [super init];
    if (self) {
//        self.dirtySearch = NO;
        self.opaque = YES;
    }
    return self;
}

#pragma mark - Properties

- (void)setExpression:(NSRegularExpression *)expression
{
    _expression = expression;
    
    self.pattern = expression.pattern;
}

- (void)setPattern:(NSString *)pattern
{
    _pattern = pattern;
    
    _expression = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
}

- (void)perform
{
    [self.scope enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
        [self.expression enumerateMatchesInString:self.string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            [self.textStorage addAttribute:NSForegroundColorAttributeName value:self.color range:[result range]];
            [self addIndexesInRange:[result range]];
        }];
    }];
    
    [super perform];
}

@end
