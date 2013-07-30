//
//  JLScope.m
//  iGitpad
//
//  Created by Johannes Lund on 2013-06-30.
//  Copyright (c) 2013 Anviking. All rights reserved.
//

#import "JLScope.h"
#import "Helpers.h"

@interface JLScope ()
@property (nonatomic, readwrite, strong) NSString *string;

- (void)iterateSubscopes;

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
    NSMutableIndexSet *archivedSet = self.set.mutableCopy;
    for (JLScope *scope in self.subscopes) {
        
        if (scope == self) NSAssert(NO, @"%@ can under no circumstances have itself as a subscope.", self);
        scope.textStorage = self.textStorage;
        scope.string = self.string;
        
        [scope perform];
    }
    self.set = archivedSet;
}

- (void)perform
{
    if (self.scope) {
        NSAssert(self.set.count != 0, @"A scope that is not the root-scope must have indexes before -perform:");
        self.set = [self.set intersectionWithSet:self.scope.set];
    }
    
    [self iterateSubscopes];
    
    if (self.scope && self.opaque == YES)
    {
        [self.scope.set removeIndexes:self.set];
    }
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

- (void)setTextStorage:(NSTextStorage *)textStorage
{
    _textStorage = textStorage;
    _string = textStorage.string;
}

- (NSMutableIndexSet *)set
{
    if (!_set) _set = [NSMutableIndexSet indexSet];
    return _set;
}

#pragma mark - NSCopying Protocol

- (id)copyWithZone:(NSZone *)zone
{
    JLScope *scope = [[self.class allocWithZone:zone] init];
    for (JLScope *subscope in self.subscopes) {
        [scope addSubscope:subscope.copy];
    }
    scope.textStorage = self.textStorage;
    return scope;
}

- (void)addScope:(JLScope *)scope
{
    [scope addSubscope:self.copy];
}

@end

