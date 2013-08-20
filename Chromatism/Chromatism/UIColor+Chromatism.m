//
//  UIColor+Chromatism.m
//  Chromatism
//
//  Created by Johannes Lund on 2013-08-20.
//  Copyright (c) 2013 Anviking. All rights reserved.
//

#import "UIColor+Chromatism.h"

@implementation UIColor (Chromatism)

+ (UIColor *)backgroundMarkupColor
{
    static UIColor *color;
    if (!color) {
        color = [UIColor colorWithWhite:0.1122334455 alpha:1];
    }
    return color;
}

@end
