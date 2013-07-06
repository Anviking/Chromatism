//
//  Tokenizer.h
//  iGitpad
//
//  Created by Johannes Lund on 2012-11-24.
//
//

#import <Foundation/Foundation.h>
#import "JLTextStorage.h"
#import "Helpers.h"

@class TextViewChange, JLTextView;
@interface JLTokenizer : NSObject <JLTextStorageTokenizer>

- (void)clearColorAttributesInRange:(NSRange)range textStorage:(NSTextStorage *)storage;
@property (nonatomic, strong) NSDictionary *colors;
@end
