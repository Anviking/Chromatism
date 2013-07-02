//
//  JLTokenPattern.m
//  iGitpad
//
//  Created by Johannes Lund on 2013-06-30.
//  Copyright (c) 2013 Anviking. All rights reserved.
//

#import "JLTokenPattern.h"

@interface JLScope ()
@property (nonatomic, readwrite, strong) NSString *string;
@end

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
    [self.scope.set enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
        [self.expression enumerateMatchesInString:self.string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            [self.textStorage addAttribute:NSForegroundColorAttributeName value:self.color range:[result range]];
            [self.set addIndexesInRange:[result range]];
        }];
    }];
    
    NSMutableIndexSet *archivedSet = self.set.mutableCopy;
    for (JLScope *scope in self.subscopes) {
        
        scope.textStorage = self.textStorage;
        scope.string = self.string;
        
        [scope perform];
    }
    self.set = archivedSet;
    
    if (self.scope && self.opaque == YES)
    {
        [self.scope.set removeIndexes:self.set];
    }}

#pragma mark - NSCopying Protocol

- (id)copyWithZone:(NSZone *)zone
{
    JLTokenPattern *pattern = [[self.class allocWithZone:zone] init];
    for (JLScope *subscope in self.subscopes) {
        [pattern addSubscope:subscope.copy];
    }
    pattern.textStorage = self.textStorage;
    pattern.expression = self.expression;
    pattern.set = self.set.mutableCopy;
    pattern.color = self.color;

    return pattern;
}

@end
