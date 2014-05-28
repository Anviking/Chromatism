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

@class TextViewChange, JLTextView, JLTokenPattern;

@protocol JLTokenizerDelegate;

@interface JLTokenizer : NSObject <NSTextStorageDelegate, NSLayoutManagerDelegate, UITextViewDelegate>

- (void)waitUntilFinished; /// Wait untill all syntax-highlighting operations are finished.

- (void)refreshTokenizationOfTextStorage:(NSTextStorage *)textStorage;

- (void)tokenizeTextStorage:(NSTextStorage *)textStorage withScope:(JLScope *)scope;
- (JLScope *)documentScopeForTokenizingTextStorage:(NSTextStorage *)textStorage inRange:(NSRange)range;

// Override these two methods and add your own scopes and tokenPatterns
- (void)prepareDocumentScope:(JLScope *)documentScope;
- (void)prepareLineScope:(JLScope *)lineScope;

- (NSMutableArray *)symbolsWithPattern:(NSString *)pattern captureGroup:(int)group textStorage:(NSTextStorage *)textStorage;

// Creates JLTokenPatterns and adds them to the operationQueue
- (JLTokenPattern *)addToken:(NSString *)type withPattern:(NSString *)pattern andScope:(JLScope *)scope;
- (JLTokenPattern *)addToken:(NSString *)type withKeywords:(NSString *)keywords andScope:(JLScope *)scope;


- (void)clearColorAttributesInRange:(NSRange)range textStorage:(NSTextStorage *)storage;

- (JLTokenizerIntendtationAction)intendationActionAfterReplacingTextInRange:(NSRange)range replacementText:(NSString *)text previousCharacter:(unichar)character textView:(UITextView *)textView;

@property (nonatomic, strong) NSDictionary *colors;
@property (nonatomic, weak) id<JLTokenizerDelegate> delegate;
@end

@protocol JLTokenizerDelegate <NSObject>

- (void)scope:(JLScope *)scope didFinishProcessing:(JLTokenizer *)tokenizer;

@end
