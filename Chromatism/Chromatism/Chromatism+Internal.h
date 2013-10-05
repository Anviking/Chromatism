//
//  ChromatismInternal.h
//  Chromatism
//
//  Created by Anviking on 2013-07-31.
//  Copyright (c) 2013 Johannes Lund
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, JLTokenizerTheme) {
    JLTokenizerThemeDefault,
    JLTokenizerThemeDusk
};

#ifdef DEBUG
#   define ChromatismLog(...) NSLog(__VA_ARGS__)
#else
#   define ChromatismLog(...)
#endif

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
