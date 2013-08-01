//
//  Tokenizer.h
//  iGitpad
//
//  Created by Johannes Lund on 2012-11-24.
//
//

#import <Foundation/Foundation.h>
#import "Helpers.h"
#import "Chromatism+Internal.h"
#import "JLScope.h"

@class TextViewChange, JLTextView;

@protocol JLTokenizerDelegate;

@interface JLTokenizer : NSObject <NSTextStorageDelegate, JLScopeDelegate>

// Override to create your own syntax highlighting
- (void)tokenizeTextStorage:(NSTextStorage *)storage withRange:(NSRange)range;

- (void)clearColorAttributesInRange:(NSRange)range textStorage:(NSTextStorage *)storage;
- (NSMutableAttributedString *)tokenizeString:(NSString *)string withDefaultAttributes:(NSDictionary *)attributes;

@property (nonatomic, strong) NSDictionary *colors;
@property (nonatomic, weak) id<JLTokenizerDelegate> delegate;
@end

@protocol JLTokenizerDelegate <NSObject>

- (void)scope:(JLScope *)scope didFinishProcessing:(JLTokenizer *)tokenizer;

@end
