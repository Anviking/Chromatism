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
- (void)iterateSubscopes;
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
        self.opaque = YES;
        self.captureGroup = 0;
    }
    return self;
}

#pragma mark - Regular Expression

- (void)setExpression:(NSRegularExpression *)expression
{
    _expression = expression;
    
    self.pattern = expression.pattern;
}

- (void)setPattern:(NSString *)pattern
{
    _pattern = pattern;
    
    _expression = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionAnchorsMatchLines error:nil];
}

#pragma mark - Perform

- (void)performInIndexSet:(NSIndexSet *)set
{
    [set enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
        [self.expression enumerateMatchesInString:self.string options:self.matchingOptions range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            [self.textStorage addAttribute:NSForegroundColorAttributeName value:self.color range:[result rangeAtIndex:self.captureGroup]];
            [self.set addIndexesInRange:[result rangeAtIndex:self.captureGroup]];
        }];
    }];
    
    [self iterateSubscopes];
    if ([self.delegate respondsToSelector:@selector(scopeDidFinishPerforming:)]) [self.delegate scopeDidFinishPerforming:self];
}

#pragma mark - Debugging

- (NSString *)description
{
    NSString *subscopes = [[[[self.subscopes valueForKey:@"description"] componentsJoinedByString:@"\n"] componentsSeparatedByString:@"\n"] componentsJoinedByString:@"\n\t\t"];
    return [NSString stringWithFormat:@"%@, %@, Regex Pattern: %@, opaque: %i, indexesSet:%@ \nsubscopes, %@", NSStringFromClass(self.class), self.identifier, self.pattern, self.opaque, self.set, subscopes];
}

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
