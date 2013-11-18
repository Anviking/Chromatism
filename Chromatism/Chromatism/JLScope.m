//
//  JLScope.m
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

#import "JLScope.h"
#import "Helpers.h"

@interface JLScope ()
@property (nonatomic, readwrite, strong) NSString *string;
@end

@implementation JLScope

#pragma mark - Initialization

+ (instancetype)scopeWithRange:(NSRange)range inTextStorage:(NSTextStorage *)textStorage
{
    JLScope *scope = [JLScope new];
    scope.set = [NSMutableIndexSet indexSetWithIndexesInRange:range];
    scope.textStorage = textStorage;
    return scope;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.opaque = YES;
    }
    return self;
}

+ (instancetype)scopeWithTextStorage:(NSTextStorage *)textStorage
{
    return [self scopeWithRange:NSMakeRange(0, textStorage.length) inTextStorage:textStorage];
}

- (NSMutableArray *)scopes
{
    if (!_scopes) {
        self.scopes = @[].mutableCopy;
    }
    return _scopes;
}

#pragma mark - Perform

- (void)main
{
    NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
    for (JLScope *scope in self.scopes) {
        [set addIndexes:scope.set];
        self.textStorage = scope.textStorage;
        self.string = scope.string;
    }
    
    if (set.count > 0) {
        if (![self shouldPerform]) return;
        NSMutableIndexSet *oldSet = self.set;
        self.set = [self.set intersectionWithSet:set];
        
        if ([self.delegate respondsToSelector:@selector(scope:didChangeIndexesFrom:to:)]) [self.delegate scope:self didChangeIndexesFrom:oldSet to:self.set];
    } else {
        self.set = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.string.length)];
    }
    
    for (JLScope *scope in self.scopes) {
        [scope.set removeIndexes:self.set];
    }
}

- (BOOL)shouldPerform
{
    if ([self.delegate respondsToSelector:@selector(scopeShouldPerform:)]) return [self.delegate scopeShouldPerform:self];

    if (self.triggeringCharacterSet) {
        NSString *string = [self.delegate mergedModifiedStringForScope:self];
        if (!string) return YES;
        if ([string rangeOfCharacterFromSet:self.triggeringCharacterSet].location == NSNotFound) {
            return NO;
        }
        return YES;
    }
    return YES;
}

- (void)addSubscope:(JLScope *)scope
{
    [scope addDependency:self];
    [scope.scopes addObject:self];
}

- (void)addScope:(JLScope *)scope
{
    [self addDependency:scope];
    [self.scopes addObject:scope];
}

#pragma mark - Properties

- (NSString *)string
{
    if (!_string) _string = self.textStorage.string;
    return _string;
}
- (NSMutableIndexSet *)set
{
    if (!_set) _set = [NSMutableIndexSet indexSet];
    return _set;
}

#pragma mark - Debugging

- (NSString *)description
{
    NSString *subscopes = [[[[self.dependencies valueForKey:@"description"] componentsJoinedByString:@"\n"] componentsSeparatedByString:@"\n"] componentsJoinedByString:@"\n\t\t"];
    return [NSString stringWithFormat:@"%@, %@, nopaque: %i, nindexesSet:%@, \n subscopes, %@", NSStringFromClass(self.class), _identifier, _opaque, _set, subscopes];
}

@end

