//
//  JLLayoutManager.m
//  Chromatism
//
//  Created by Johannes Lund on 2013-08-20.
//  Copyright (c) 2013 Anviking. All rights reserved.
//

#import "JLLayoutManager.h"
#import "UIColor+Chromatism.h"

@implementation JLLayoutManager

- (void)fillBackgroundRectArray:(const CGRect *)rectArray count:(NSUInteger)rectCount forCharacterRange:(NSRange)charRange color:(UIColor *)color
{
    if (color == [UIColor backgroundMarkupColor]) {
        CGRect rect;
        
        //// Color Declarations
        UIColor* borderColor = [UIColor colorWithRed: 0.867 green: 0.867 blue: 0.867 alpha: 1];
        UIColor* backgroundColor = [UIColor colorWithRed: 0.973 green: 0.973 blue: 0.973 alpha: 1];
        
        for (int i = 0; i < rectCount; i++) {
            rect = rectArray[i];
            
            //// Rounded Rectangle Drawing
            UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius: 3];
            [backgroundColor setFill];
            [roundedRectanglePath fill];
            [borderColor setStroke];
            roundedRectanglePath.lineWidth = 1;
            [roundedRectanglePath stroke];
        }
    } else {
        [super fillBackgroundRectArray:rectArray count:rectCount forCharacterRange:charRange color:color];
    }
}

@end
