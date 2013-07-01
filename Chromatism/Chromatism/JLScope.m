//
//  JLScope.m
//  iGitpad
//
//  Created by Johannes Lund on 2013-06-30.
//  Copyright (c) 2013 Anviking. All rights reserved.
//

#import "JLScope.h"

@implementation JLScope
{
    NSMutableArray *_subscopes;
}
@synthesize subscopes = _subscopes;

#pragma mark - Initialization

+ (instancetype)scopeWithRange:(NSRange)range inTextStorage:(NSTextStorage *)textStorage
{
    JLScope *scope = [[JLScope alloc] initWithIndexesInRange:range];
    scope.textStorage = textStorage;
    return scope;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.opaque = NO;
    }
    return self;
}

+ (instancetype)scopeWithTextStorage:(NSTextStorage *)textStorage
{
    return [self scopeWithRange:NSMakeRange(0, textStorage.length) inTextStorage:textStorage];
}

- (void)perform
{
    if (self.scope && self.opaque == YES)
    {
        [self.scope removeIndexes:self];
    }
    for (JLScope *scope in self.subscopes) {
        
        scope->_textStorage = self.textStorage;
        scope->_string = self.string;
        
        [scope perform];
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
    [(NSMutableArray *)_scope.subscopes removeObject:scope];
    _scope = scope;
    
    [(NSMutableArray *)_scope.subscopes addObject:scope];
}

- (void)addSubscope:(JLScope *)subscope
{
    subscope.scope = self;
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

@end

