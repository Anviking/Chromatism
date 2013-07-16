//
//  JLTextView.h
//  Chromatism
//
//  Created by Johannes Lund on 2013-07-16.
//  Copyright (c) 2013 Anviking. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JLTokenizer;

@interface JLTextView : UITextView

@property (nonatomic, strong) JLTokenizer *syntaxTokenizer;
@end
