//
//  JLTokenPattern.m
//  iGitpad
//
//  Created by Johannes Lund on 2013-06-30.
//  Copyright (c) 2013 Anviking. All rights reserved.
//

#import "JLTokenPattern.h"

@implementation JLTokenPattern

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
    
}

@end
