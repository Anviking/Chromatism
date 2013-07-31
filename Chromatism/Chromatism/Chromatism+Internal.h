//
//  ChromatismInternal.h
//  Chromatism
//
//  Created by Anviking on 2013-07-31.
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

/**
 *  In addition to being the name of the library, the Chromatism class handles colors and TokenTypes
 */

@interface Chromatism : NSObject

+ (NSDictionary *)colorsForTheme:(JLTokenizerTheme)theme;

@end
