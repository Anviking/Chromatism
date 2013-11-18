 //
//  JLTokenPattern.m
//  iGitpad
//
//  Created by Johannes Lund on 2013-06-30.
//  Copyright (c) 2013 Johannes Lund
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.//

#import "JLTokenPattern.h"
#import "Helpers.h"

@interface JLScope ()
- (BOOL)shouldPerform;

@property (nonatomic, readwrite, strong) NSString *string;
@end

@implementation JLTokenPattern

#pragma mark - Initialization

static NSCache *cache;

+ (instancetype)tokenPatternWithPattern:(NSString *)pattern
{
    if (!cache) {
        cache = [NSCache new];
    }
    
    JLTokenPattern *tokenPattern = [JLTokenPattern new];
    NSRegularExpression *expression = [cache objectForKey:pattern];
    if (expression) {
        tokenPattern->_expression = expression;
        tokenPattern->_pattern = pattern;
    } else {
        tokenPattern.pattern = pattern;
        if (tokenPattern.expression) {
            [cache setObject:tokenPattern.expression forKey:pattern];
        }
    }
    
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
    _pattern = expression.pattern;
}

- (void)setPattern:(NSString *)pattern
{
    if (!pattern) return;
    _pattern = pattern;
    _expression = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionAnchorsMatchLines error:nil];
}

#pragma mark - Perform

- (void)main
{
    NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
    for (JLScope *scope in self.scopes) {
            [set addIndexes:scope.set];
            self.string = scope.string;
            self.textStorage = scope.textStorage;
    }
    
    if (![self shouldPerform]) return;
    if (!self.expression) return;
    NSDictionary *attributes = [self.delegate attributesForScope:self];
    self.set = [self.set intersectionWithSet:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.textStorage.length)]];
    [self.set removeIndexes:set];
    NSAssert(attributes, @"");
    [set enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
        [self.expression enumerateMatchesInString:self.string options:self.matchingOptions range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.textStorage addAttributes:attributes range:[result rangeAtIndex:self.captureGroup]];
            });
            [self.set addIndexesInRange:[result rangeAtIndex:self.captureGroup]];
        }];
    }];
    
    for (JLScope *scope in self.scopes) {
        [scope.set removeIndexes:self.set];
    }
}

#pragma mark - Debugging

- (NSString *)description
{
    NSString *subscopes = [[[[self.dependencies valueForKey:@"description"] componentsJoinedByString:@"\n"] componentsSeparatedByString:@"\n"] componentsJoinedByString:@"\n\t\t"];
    return [NSString stringWithFormat:@"%@, %@, Regex Pattern: %@, opaque: %i, indexesSet:%@ \nsubscopes, %@", NSStringFromClass(self.class), self.identifier, self.pattern, self.opaque, self.set, subscopes];
}

@end
