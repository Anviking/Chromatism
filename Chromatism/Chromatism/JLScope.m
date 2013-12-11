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

- (void)iterateSubscopes;

@property (nonatomic, readwrite, strong) NSString *string;
@end

@implementation JLScope
{
    NSMutableArray *_subscopes;
}
@synthesize subscopes = _subscopes;

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

#pragma mark - Perform

- (void)iterateSubscopes
{
    NSMutableIndexSet *set = (self.empty) ? self.scope.set.mutableCopy :self.set.mutableCopy;
    for (JLScope *scope in self.subscopes) {
        
        NSAssert(scope != self, @"%@ can under no circumstances have itself as a subscope.", self);
        scope.textStorage = self.textStorage;
        scope.string = self.string;
        
        [scope performInIndexSet:set];
        
        if (scope.opaque) {
            [set removeIndexes:scope.set];
            if (self.empty) {
                [self.set addIndexes:scope.set];
            }
        }
    }
}

- (void)perform
{
    NSAssert(!self.scope, @"Only call -perform to a rootlevel scope");
    if (![self shouldPerform]) return;
    [self iterateSubscopes];
}

- (void)performInIndexSet:(NSIndexSet *)set
{
    NSParameterAssert(set);
    if (![self shouldPerform]) return;
    NSMutableIndexSet *oldSet = self.set;
    self.set = [self.set intersectionWithSet:set];
    [self iterateSubscopes];
    
    if ([self.delegate respondsToSelector:@selector(scope:didChangeIndexesFrom:to:)]) [self.delegate scope:self didChangeIndexesFrom:oldSet to:self.set];
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

#pragma mark - Scope Hierarchy Management

- (NSMutableArray *)subscopes
{
    if (!_subscopes) _subscopes = [NSMutableArray array];
    return _subscopes;
}

- (void)setSubscopes:(NSArray *)subscopes
{
    for (JLScope *scope in subscopes) {
        scope.scope = self;
    }
    _subscopes = subscopes.mutableCopy;
}

- (void)setScope:(JLScope *)scope
{
    [(NSMutableArray *)_scope.subscopes removeObject:self];
    _scope = scope;
    
    [(NSMutableArray *)_scope.subscopes addObject:self];
}

- (void)addSubscope:(JLScope *)subscope
{
    [(NSMutableArray *)self.subscopes addObject:subscope];
    subscope->_scope = self;
}

- (void)removeSubscope:(JLScope *)subscope
{
    [(NSMutableArray *)self.subscopes removeObject:subscope];
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
    NSString *subscopes = [[[[self.subscopes valueForKey:@"description"] componentsJoinedByString:@"\n"] componentsSeparatedByString:@"\n"] componentsJoinedByString:@"\n\t\t"];
    return [NSString stringWithFormat:@"%@, %@, nopaque: %i, nindexesSet:%@, \n subscopes, %@", NSStringFromClass(self.class), _identifier, _opaque, _set, subscopes];
}

#pragma mark - NSCopying Protocol

- (id)copyWithZone:(NSZone *)zone
{
    JLScope *scope = [[self.class allocWithZone:zone] init];
    for (JLScope *subscope in self.subscopes) {
        [scope addSubscope:subscope.copy];
    }
    scope.textStorage = self.textStorage;
    scope.delegate = self.delegate;
    scope.type = self.type.copy;
    scope.identifier = self.identifier.copy;
    return scope;
}

- (void)addScope:(JLScope *)scope
{
    [scope addSubscope:self.copy];
}

@end

