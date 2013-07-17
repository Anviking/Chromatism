//
//  Tokenizer.h
//  iGitpad
//
//  Created by Johannes Lund on 2012-11-24.
//
//

#import <Foundation/Foundation.h>
#import "Helpers.h"

typedef NS_ENUM(NSInteger, JLTokenizerTheme) {
    JLTokenizerThemeDefault,
    JLTokenizerThemeDusk
};

FOUNDATION_EXPORT NSString *const JLTokenTypeText;
FOUNDATION_EXPORT NSString *const JLTokenTypeBackground;
FOUNDATION_EXPORT NSString *const JLTokenTypeComment;
FOUNDATION_EXPORT NSString *const JLTokenTypeDocumentationComment;
FOUNDATION_EXPORT NSString *const JLTokenTypeDocumentationCommentKeyword;
FOUNDATION_EXPORT NSString *const JLTokenTypeString;
FOUNDATION_EXPORT NSString *const JLTokenTypeCharacter;
FOUNDATION_EXPORT NSString *const JLTokenTypeNumber;
FOUNDATION_EXPORT NSString *const JLTokenTypeKeyword;
FOUNDATION_EXPORT NSString *const JLTokenTypePreprocessor;
FOUNDATION_EXPORT NSString *const JLTokenTypeURL;
FOUNDATION_EXPORT NSString *const JLTokenTypeOther;
FOUNDATION_EXPORT NSString *const JLTokenTypeOtherClassNames;
FOUNDATION_EXPORT NSString *const JLTokenTypeOtherMethodNames;

@class TextViewChange, JLTextView;
@interface JLTokenizer : NSObject <UITextViewDelegate, NSTextStorageDelegate>

// Override to create your own syntax highlighting
- (void)tokenizeTextStorage:(NSTextStorage *)storage withRange:(NSRange)range;

- (void)clearColorAttributesInRange:(NSRange)range textStorage:(NSTextStorage *)storage;
- (NSMutableAttributedString *)tokenizeString:(NSString *)string withDefaultAttributes:(NSDictionary *)attributes;

@property (nonatomic, strong) NSDictionary *colors;
@property (nonatomic, strong) NSDictionary *defaultAttributes;

@property (nonatomic, strong) UIColor *highlightColor;
@property (nonatomic, assign) JLTokenizerTheme theme;
@property (nonatomic, strong, readonly) NSArray *themes;
@property (nonatomic, weak) UITextView *textView;
@end
