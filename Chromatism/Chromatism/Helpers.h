//
//  NSString+Helper.h
//  TextTest
//
//  Created by Johannes Lund on 2012-07-13.
//  Copyright (c) 2012 Anviking. All rights reserved.
//

@import UIKit;

@interface NSString (Helper)
- (BOOL)string:(NSString *)longString containsString:(NSString *)shortString;
- (NSMutableArray *)allOccurrencesOfString:(NSString *)searchString;
@end

@interface NSArray (Helper)
- (NSArray *)uniqueArray;
@end

@interface NSMutableArray (Helper)
- (NSMutableArray *)uniqueArray;
@end

@interface UIColor (Helper)

// wrapper for [UIColor colorWithRed:green:blue:alpha:]
// values must be in range 0 - 255
+ (UIColor *)colorWith8BitRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue alpha:(CGFloat)alpha;

// Creates color using hex representation
// hex - must be in format: #FF00CC
// alpha - must be in range 0.0 - 1.0
+ (UIColor *)colorWithHex:(NSString*)hex alpha:(CGFloat)alpha;

@end

@interface NSValue (Helper)
- (NSComparisonResult)compareTo:(NSValue *)range;
@end

@interface NSDate (Helper)

- (NSString *)iso8601String;

@end

@interface NSIndexSet (GSIndexSetAdditions)

- (NSMutableIndexSet *)intersectionWithSet:(NSIndexSet *)otherSet;

@end



