//
//  JLTextStorage.h
//  iGitpad
//
//  Created by Johannes Lund on 2013-06-13.
//  Copyright (c) 2013 Anviking. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JLTextStorageTokenizer;
@interface JLTextStorage : NSTextStorage

@property (nonatomic, weak) id <JLTextStorageTokenizer> tokenizer;

@end

@protocol JLTextStorageTokenizer <NSObject>

- (void)tokenizeTextStorage:(NSTextStorage *)storage withRange:(NSRange)range;

@end
