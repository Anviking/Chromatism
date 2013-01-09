//
//  Tokenizer.h
//  iGitpad
//
//  Created by Johannes Lund on 2012-11-24.
//
//

#import <Foundation/Foundation.h>
#import "JLTextView.h"
#import "Helpers.h"

FOUNDATION_EXPORT NSString *const kTokenizerTypeText;
FOUNDATION_EXPORT NSString *const kTokenizerTypeBackground;
FOUNDATION_EXPORT NSString *const kTokenizerTypeComment;
FOUNDATION_EXPORT NSString *const kTokenizerTypeDocumentationComment;
FOUNDATION_EXPORT NSString *const kTokenizerTypeString;
FOUNDATION_EXPORT NSString *const kTokenizerTypeCharacter;
FOUNDATION_EXPORT NSString *const kTokenizerTypeNumber;
FOUNDATION_EXPORT NSString *const kTokenizerTypeKeyword;
FOUNDATION_EXPORT NSString *const kTokenizerTypePreprocessor;
FOUNDATION_EXPORT NSString *const kTokenizerTypeURL;
FOUNDATION_EXPORT NSString *const kTokenizerTypeAttribute;
FOUNDATION_EXPORT NSString *const kTokenizerTypeProject;
FOUNDATION_EXPORT NSString *const kTokenizerTypeOther;
FOUNDATION_EXPORT NSString *const kTokenizerTypeOtherClassNames;
FOUNDATION_EXPORT NSString *const kTokenizerTypeOtherMethodNames;

typedef enum {
    kTokenizerThemeDefault,
    kTokenizerThemeDusk
} RegexHighlightViewTheme;

//TODO: Clean this header
@class TextViewChange, JLTextView;
@interface JLTokenizer : NSObject

- (NSMutableAttributedString *)tokenizeAttributedString:(NSMutableAttributedString *)attributedString withRecentTextViewChange:(TextViewChange *)change;

@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *highlightColor;

@property(nonatomic) NSDictionary *colorDictionary;
@property (nonatomic, assign) RegexHighlightViewTheme theme;
@property (nonatomic, strong) NSArray *themes;
@property (nonatomic, weak) JLTextView *textView;

@end
