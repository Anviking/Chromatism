//
//  JLMarkdownTokenizer.h
//  Chromatism
//
//  Created by Johannes Lund on 2013-07-13.
//  Copyright (c) 2013 Anviking. All rights reserved.
//

#import <Chromatism/Chromatism.h>

@interface JLMarkdownTokenizer : JLTokenizer

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIFont *boldFont;
@property (nonatomic, strong) UIFont *italicFont;
@property (nonatomic, strong) UIFont *monospaceFont;
@end
