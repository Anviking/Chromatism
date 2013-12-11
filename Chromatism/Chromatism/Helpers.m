//
//  NSString+Helper.m
//  TextTest
//
//  Created by Johannes Lund on 2012-07-13.
//  Copyright (c) 2012 Anviking. All rights reserved.
//

#import "Helpers.h"

@implementation UIColor (CreateMethods)

+ (UIColor*)colorWith8BitRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:(red/255.0) green:(green/255.0) blue:(blue/255.0) alpha:alpha];
}

+ (UIColor*)colorWithHex:(NSString*)hex alpha:(CGFloat)alpha {
    
    if (hex.length != 6) return nil;
    
    NSString *redHex = [NSString stringWithFormat:@"0x%@", [hex substringWithRange:NSMakeRange(0, 2)]];
    NSString *greenHex = [NSString stringWithFormat:@"0x%@", [hex substringWithRange:NSMakeRange(2, 2)]];
    NSString *blueHex = [NSString stringWithFormat:@"0x%@", [hex substringWithRange:NSMakeRange(4, 2)]];
    
    unsigned redInt = 0;
    NSScanner *rScanner = [NSScanner scannerWithString:redHex];
    [rScanner scanHexInt:&redInt];
    
    unsigned greenInt = 0;
    NSScanner *gScanner = [NSScanner scannerWithString:greenHex];
    [gScanner scanHexInt:&greenInt];
    
    unsigned blueInt = 0;
    NSScanner *bScanner = [NSScanner scannerWithString:blueHex];
    [bScanner scanHexInt:&blueInt];
    
    return [UIColor colorWith8BitRed:redInt green:greenInt blue:blueInt alpha:alpha];
}

@end

@implementation NSIndexSet (GSIndexSetAdditions)

- (NSMutableIndexSet *)intersectionWithSet:(NSIndexSet *)otherSet
{
    NSMutableIndexSet *finalSet = [NSMutableIndexSet indexSet];
    [self enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        if ([otherSet containsIndex:index]) [finalSet addIndex:index];
    }];
    
    return finalSet;
}

@end
