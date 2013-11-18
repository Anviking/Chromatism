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

typedef NS_ENUM(NSInteger, JLTokenizerIntendtationAction) {
    JLTokenizerIntendtationActionIncrease = 1,
    JLTokenizerIntendtationActionDecrease = -1,
    JLTokenizerIntendtationActionNone = 0
} NS_ENUM_AVAILABLE_IOS(7_0);

@class TextViewChange, JLTextView;

@protocol JLTokenizerDelegate;

@interface JLTokenizer : NSObject <NSTextStorageDelegate, JLScopeDelegate, NSLayoutManagerDelegate, UITextViewDelegate>

/// Override these two methods and add your own scopes and tokenPatterns
- (void)prepareDocumentScope:(JLScope *)documentScope;
- (void)prepareLineScope:(JLScope *)lineScope;

- (void)tokenizeTextStorage:(NSTextStorage *)textStorage withRange:(NSRange)range;
- (void)tokenizeTextStorage:(NSTextStorage *)textStorage;

- (void)clearColorAttributesInRange:(NSRange)range textStorage:(NSTextStorage *)storage;

- (JLTokenizerIntendtationAction)intendationActionAfterReplacingTextInRange:(NSRange)range replacementText:(NSString *)text previousCharacter:(unichar)character textView:(UITextView *)textView;

@property (nonatomic, strong) NSDictionary *colors;
@property (nonatomic, weak) id<JLTokenizerDelegate> delegate;
@end

@protocol JLTokenizerDelegate <NSObject>

- (void)scope:(JLScope *)scope didFinishProcessing:(JLTokenizer *)tokenizer;

@end
