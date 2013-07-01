//
//  NSString+Helper.m
//  TextTest
//
//  Created by Johannes Lund on 2012-07-13.
//  Copyright (c) 2012 Anviking. All rights reserved.
//

#import "Helpers.h"

@implementation NSString (Helper)

- (BOOL)string:(NSString *)longString containsString:(NSString *)shortString
{
    return ([longString rangeOfString:shortString].length != NSNotFound);
}

- (NSMutableArray *)allOccurrencesOfString:(NSString *)searchString {
    
    NSMutableArray *array = [NSMutableArray array];
    
    BOOL keepGoing = TRUE;
    NSRange searchRange = NSMakeRange(0, self.length);
    while (keepGoing) {
        NSRange range = [self rangeOfString:searchString options:NSCaseInsensitiveSearch range:searchRange];
        if (range.location != NSNotFound) {
            int pos = range.location  + searchString.length;
            [array addObject:[NSValue valueWithRange:range]];
            
            searchRange = NSMakeRange(pos, [self length] - pos);
            
        } else {
            keepGoing = NO;
        }
    }
    
    return array;
}

@end

@implementation NSArray (Helper)

- (NSArray *)uniqueArray;
{
    NSMutableSet* existingNames = [NSMutableSet set];
    NSMutableArray* filteredArray = [NSMutableArray array];
    for (id object in self) {
        if (![existingNames containsObject:[object name]]) {
            [existingNames addObject:[object name]];
            [filteredArray addObject:object];
        }
    }
    return [NSArray arrayWithArray:filteredArray];
}
@end

@implementation NSMutableArray (Helper)

- (NSMutableArray *)uniqueArray;
{
    NSMutableSet* existingNames = [NSMutableSet set];
    NSMutableArray* filteredArray = [NSMutableArray array];
    for (id object in self) {
        if (![existingNames containsObject:object]) {
            [existingNames addObject:object];
            [filteredArray addObject:object];
        }
    }
    return filteredArray;
}

@end

@implementation NSValue (Helper)

- (NSComparisonResult)compareTo:(NSValue *)range {
    if (self.rangeValue.location < range.rangeValue.location) {
        return NSOrderedAscending;
    } else if (self.rangeValue.location == range.rangeValue.location) {
        return NSOrderedSame;
    } else {
        return NSOrderedDescending;
    }
}

@end

@implementation UIColor (CreateMethods)

+ (UIColor*)colorWith8BitRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:(red/255.0) green:(green/255.0) blue:(blue/255.0) alpha:alpha];
}

+ (UIColor*)colorWithHex:(NSString*)hex alpha:(CGFloat)alpha {
    
    assert(6 == [hex length]);
    
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

@implementation NSAttributedString (help)

- (NSString *)description
{
    return self.string;
}

@end

@implementation NSMutableAttributedString (help)

- (NSString *)description
{
    return self.string;
}

@end

@implementation NSDate (Helper)

- (NSString *)iso8601String
{
    static NSDateFormatter* dateFormatter;
    if (!dateFormatter)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
    }
    return [dateFormatter stringFromDate:self];
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
