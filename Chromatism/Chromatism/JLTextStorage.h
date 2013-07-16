//
//  JLTextStorage.h
//  iGitpad
//
//  Created by Johannes Lund on 2013-06-13.
//  Copyright (c) 2013 Anviking. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JLTextStorageDelegate;
@interface JLTextStorage : NSTextStorage

@property (nonatomic, weak) id <JLTextStorageDelegate> delegate;

@end

@protocol JLTextStorageDelegate <NSObject>

- (void)tokenizeTextStorage:(NSTextStorage *)storage withRange:(NSRange)range;

@end
