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

@interface JLTokenizer : NSObject <NSTextStorageDelegate, JLScopeDelegate, NSLayoutManagerDelegate, UITextViewDelegate>

- (void)tokenizeTextStorage:(NSTextStorage *)textStorage withRange:(NSRange)range;
- (void)tokenizeTextStorage:(NSTextStorage *)textStorage;

// - (void)validateTokenization;

- (void)clearColorAttributesInRange:(NSRange)range textStorage:(NSTextStorage *)storage;
+ (NSMutableAttributedString *)tokenizeString:(NSString *)string withDefaultAttributes:(NSDictionary *)attributes;

@property (nonatomic, strong) NSDictionary *colors;
@property (nonatomic, strong) NSString *syntax;

// @property (nonatomic, assign) BOOL needsValidation;

@property (nonatomic, weak) id<JLTokenizerDelegate> delegate;
@end

@protocol JLTokenizerDelegate <NSObject>

- (void)scope:(JLScope *)scope didFinishProcessing:(JLTokenizer *)tokenizer;

@end
