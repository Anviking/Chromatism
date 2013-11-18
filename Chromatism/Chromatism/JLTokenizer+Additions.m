//
//  JLTokenizer+Additions.m
//  Chromatism
//
//  Created by Johannes Lund on 2013-11-19.
//  Copyright (c) 2013 Anviking. All rights reserved.
//

#import "JLTokenizer+Additions.h"
#import "JLObjectiveCTokenizer.h"

@implementation JLTokenizer (Additions)

+ (JLObjectiveCTokenizer *)objectiveCTokenizer
{
    return [[JLObjectiveCTokenizer alloc] init];
}

// For now, let every JLTokenizer be created as a JLObjectiveCTokenizer

+ (id)alloc
{
    if ([self class] == [JLTokenizer class]) {
        return [JLObjectiveCTokenizer alloc];
    }
    return [super alloc];
}

@end
