//
//  JLTextViewController.h
//  iGitpad
//
//  Created by Johannes Lund on 2013-06-13.
//  Copyright (c) 2013 Anviking. All rights reserved.
//

#import <UIKit/UIKit.h>

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

@class JLTokenizer;
@interface JLTextViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, strong) NSDictionary *defaultAttributes;
@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) JLTokenizer *tokenizer;

@property (nonatomic, strong) UIColor *highlightColor;
@property(nonatomic, strong) NSDictionary *colors;
@property (nonatomic, assign) JLTokenizerTheme theme;
@property (nonatomic, strong, readonly) NSArray *themes;

@end
