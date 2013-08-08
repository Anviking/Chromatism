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

@protocol JLTokenizerDelegate, JLTokenizerDataSource;

@interface JLTokenizer : NSObject <NSTextStorageDelegate, JLScopeDelegate>

- (void)tokenizeWithRange:(NSRange)range;
- (void)tokenize;
- (void)validateTokenization;
- (void)symbolicate;
- (void)clearColorAttributesInRange:(NSRange)range textStorage:(NSTextStorage *)storage;

- (NSMutableAttributedString *)tokenizeString:(NSString *)string withDefaultAttributes:(NSDictionary *)attributes;

@property (nonatomic, strong) NSDictionary *colors;
@property (nonatomic, weak) NSTextStorage *textStorage;
@property (nonatomic, assign) BOOL needsValidation;
@property (nonatomic, weak) id<JLTokenizerDelegate> delegate;
@property (nonatomic, weak) id<JLTokenizerDataSource> dataSource;
@end

@protocol JLTokenizerDataSource <NSObject>

/// Return the text that was replaced in the most recent text edit or an empty string if there is none.
- (NSString *)recentlyReplacedText;

@end

@protocol JLTokenizerDelegate <NSObject>

- (void)scope:(JLScope *)scope didFinishProcessing:(JLTokenizer *)tokenizer;

@end
