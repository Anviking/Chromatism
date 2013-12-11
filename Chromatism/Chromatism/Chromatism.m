//
//  Chromatism.m
//  Chromatism
//
//  Created by Johannes Lund on 2013-07-01.
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

#import "Chromatism+Internal.h"
#import "Helpers.h"

NSString *const JLTokenTypeText = @"text";
NSString *const JLTokenTypeBackground = @"background";
NSString *const JLTokenTypeComment = @"comment";
NSString *const JLTokenTypeDocumentationComment = @"documentation_comment";
NSString *const JLTokenTypeDocumentationCommentKeyword = @"documentation_comment_keyword";
NSString *const JLTokenTypeString = @"string";
NSString *const JLTokenTypeCharacter = @"character";
NSString *const JLTokenTypeNumber = @"number";
NSString *const JLTokenTypeKeyword = @"keyword";
NSString *const JLTokenTypePreprocessor = @"preprocessor";
NSString *const JLTokenTypeURL = @"url";
NSString *const JLTokenTypeAttribute = @"attribute";
NSString *const JLTokenTypeProject = @"project";
NSString *const JLTokenTypeOther = @"other";
NSString *const JLTokenTypeOtherMethodNames = @"other_method_names";
NSString *const JLTokenTypeOtherClassNames = @"other_class_names";

NSString *const JLTokenTypeDiffAddition = @"diff_addition";
NSString *const JLTokenTypeDiffDeletion = @"diff_deletion";

NSString *const JLDiffColorAttributeName = @"diff_color_attribute_name";


@implementation Chromatism

+ (NSDictionary *)colorsForTheme:(JLTokenizerTheme)theme
{
    NSDictionary* colors;
    switch(theme) {
        case JLTokenizerThemeDefault:
            colors = @{JLTokenTypeText: [UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1],
                       JLTokenTypeBackground: [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1],
                       JLTokenTypeComment: [UIColor colorWithRed:0.0/255 green:131.0/255 blue:39.0/255 alpha:1],
                       JLTokenTypeDocumentationComment: [UIColor colorWithRed:0.0/255 green:131.0/255 blue:39.0/255 alpha:1],
                       JLTokenTypeDocumentationCommentKeyword: [UIColor colorWithRed:0.0/255 green:76.0/255 blue:29.0/255 alpha:1],
                       JLTokenTypeString: [UIColor colorWithRed:211.0/255 green:45.0/255 blue:38.0/255 alpha:1],
                       JLTokenTypeCharacter: [UIColor colorWithRed:40.0/255 green:52.0/255 blue:206.0/255 alpha:1],
                       JLTokenTypeNumber: [UIColor colorWithRed:40.0/255 green:52.0/255 blue:206.0/255 alpha:1],
                       JLTokenTypeKeyword: [UIColor colorWithRed:188.0/255 green:49.0/255 blue:156.0/255 alpha:1],
                       JLTokenTypePreprocessor: [UIColor colorWithRed:120.0/255 green:72.0/255 blue:48.0/255 alpha:1],
                       JLTokenTypeURL: [UIColor colorWithRed:21.0/255 green:67.0/255 blue:244.0/255 alpha:1],
                       JLTokenTypeOther: [UIColor colorWithRed:113.0/255 green:65.0/255 blue:163.0/255 alpha:1],
                       JLTokenTypeOtherMethodNames :  [UIColor colorWithHex:@"7040a6" alpha:1],
                       JLTokenTypeOtherClassNames :  [UIColor colorWithHex:@"7040a6" alpha:1],
                       
                       JLTokenTypeDiffAddition : [UIColor greenColor],
                       JLTokenTypeDiffDeletion : [UIColor redColor]
                       
                       };
            break;
        case JLTokenizerThemeDusk:
            colors = @{JLTokenTypeText: [UIColor whiteColor],
                       JLTokenTypeBackground: [UIColor colorWithRed:30.0/255.0 green:32.0/255.0 blue:40.0/255.0 alpha:1],
                       JLTokenTypeComment: [UIColor colorWithRed:72.0/255 green:190.0/255 blue:102.0/255 alpha:1],
                       JLTokenTypeDocumentationComment: [UIColor colorWithRed:72.0/255 green:190.0/255 blue:102.0/255 alpha:1],
                       JLTokenTypeDocumentationCommentKeyword: [UIColor colorWithRed:72.0/255 green:190.0/255 blue:102.0/255 alpha:1],
                       JLTokenTypeString: [UIColor colorWithRed:230.0/255 green:66.0/255 blue:75.0/255 alpha:1],
                       JLTokenTypeCharacter: [UIColor colorWithRed:139.0/255 green:134.0/255 blue:201.0/255 alpha:1],
                       JLTokenTypeNumber: [UIColor colorWithRed:139.0/255 green:134.0/255 blue:201.0/255 alpha:1],
                       JLTokenTypeKeyword: [UIColor colorWithRed:195.0/255 green:55.0/255 blue:149.0/255 alpha:1],
                       JLTokenTypePreprocessor: [UIColor colorWithRed:198.0/255.0 green:124.0/255.0 blue:72.0/255.0 alpha:1],
                       JLTokenTypeURL: [UIColor colorWithRed:35.0/255 green:63.0/255 blue:208.0/255 alpha:1],
                       JLTokenTypeOther: [UIColor colorWithRed:0.0/255 green:175.0/255 blue:199.0/255 alpha:1],
                       JLTokenTypeOtherClassNames :  [UIColor colorWithHex:@"04afc8" alpha:1],
                       JLTokenTypeOtherMethodNames :  [UIColor colorWithHex:@"04afc8" alpha:1],
                       
                       JLTokenTypeDiffAddition : [UIColor greenColor],
                       JLTokenTypeDiffDeletion : [UIColor redColor]
                       
                       };
            break;
		case JLTokenizerThemeLowKey:
            colors = [NSDictionary dictionaryWithObjectsAndKeys:
					 [UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1],JLTokenTypeText,
					 [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1],JLTokenTypeBackground,
					 [UIColor colorWithRed:84.0/255 green:99.0/255 blue:75.0/255 alpha:1],JLTokenTypeComment,
					 [UIColor colorWithRed:84.0/255 green:99.0/255 blue:75.0/255 alpha:1],JLTokenTypeDocumentationComment,
					 [UIColor colorWithRed:84.0/255 green:99.0/255 blue:75.0/255 alpha:1],JLTokenTypeDocumentationCommentKeyword,
					 [UIColor colorWithRed:133.0/255 green:63.0/255 blue:98.0/255 alpha:1],JLTokenTypeString,
					 [UIColor colorWithRed:50.0/255 green:64.0/255 blue:121.0/255 alpha:1],JLTokenTypeCharacter,
					 [UIColor colorWithRed:50.0/255 green:64.0/255 blue:121.0/255 alpha:1],JLTokenTypeNumber,
					 [UIColor colorWithRed:50.0/255 green:64.0/255 blue:121.0/255 alpha:1],JLTokenTypeKeyword,
					 [UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1],JLTokenTypePreprocessor,
					 [UIColor colorWithRed:24.0/255 green:49.0/255 blue:168.0/255 alpha:1],JLTokenTypeURL,
					 [UIColor colorWithRed:35.0/255 green:93.0/255 blue:43.0/255 alpha:1],JLTokenTypeOther,
					 [UIColor colorWithRed:87.0/255 green:127.0/255 blue:164.0/255 alpha:1],JLTokenTypeOtherClassNames,
					 [UIColor colorWithRed:87.0/255 green:127.0/255 blue:164.0/255 alpha:1],JLTokenTypeOtherMethodNames,
					 [UIColor greenColor],JLTokenTypeDiffAddition,
					 [UIColor greenColor],JLTokenTypeDiffDeletion,
					  nil];
            break;
		case JLTokenizerThemeMidnight:
            colors = [NSDictionary dictionaryWithObjectsAndKeys:
					 [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1],JLTokenTypeText,
					 [UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1],JLTokenTypeBackground,
					 [UIColor colorWithRed:69.0/255 green:208.0/255 blue:106.0/255 alpha:1],JLTokenTypeComment,
					 [UIColor colorWithRed:69.0/255 green:208.0/255 blue:106.0/255 alpha:1],JLTokenTypeDocumentationComment,
					 [UIColor colorWithRed:69.0/255 green:208.0/255 blue:106.0/255 alpha:1],JLTokenTypeDocumentationCommentKeyword,
					 [UIColor colorWithRed:255.0/255 green:68.0/255 blue:77.0/255 alpha:1],JLTokenTypeString,
					 [UIColor colorWithRed:139.0/255 green:138.0/255 blue:247.0/255 alpha:1],JLTokenTypeCharacter,
					 [UIColor colorWithRed:139.0/255 green:138.0/255     blue:247.0/255 alpha:1],JLTokenTypeNumber,
					 [UIColor colorWithRed:224.0/255 green:59.0/255 blue:160.0/255 alpha:1],JLTokenTypeKeyword,
					 [UIColor colorWithRed:237.0/255 green:143.0/255 blue:100.0/255 alpha:1],JLTokenTypePreprocessor,
					 [UIColor colorWithRed:36.0/255 green:72.0/255 blue:244.0/255 alpha:1],JLTokenTypeURL,
					 [UIColor colorWithRed:79.0/255 green:108.0/255 blue:132.0/255 alpha:1],JLTokenTypeOther,
					 [UIColor colorWithRed:0.0/255 green:249.0/255 blue:161.0/255 alpha:1],JLTokenTypeOtherClassNames,
					 [UIColor colorWithRed:0.0/255 green:179.0/255 blue:248.0/255 alpha:1],JLTokenTypeOtherMethodNames,
					 [UIColor greenColor],JLTokenTypeDiffAddition,
					 [UIColor greenColor],JLTokenTypeDiffDeletion,
					 nil];
            break;
		case JLTokenizerThemePresentation:
            colors = [NSDictionary dictionaryWithObjectsAndKeys:
					 [UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1],JLTokenTypeText,
					 [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1],JLTokenTypeBackground,
					 [UIColor colorWithRed:38.0/255 green:126.0/255 blue:61.0/255 alpha:1],JLTokenTypeComment,
					 [UIColor colorWithRed:38.0/255 green:126.0/255 blue:61.0/255 alpha:1],JLTokenTypeDocumentationComment,
					 [UIColor colorWithRed:38.0/255 green:126.0/255 blue:61.0/255 alpha:1],JLTokenTypeDocumentationCommentKeyword,
					 [UIColor colorWithRed:158.0/255 green:32.0/255 blue:32.0/255 alpha:1],JLTokenTypeString,
					 [UIColor colorWithRed:6.0/255 green:63.0/255 blue:244.0/255 alpha:1],JLTokenTypeCharacter,
					 [UIColor colorWithRed:6.0/255 green:63.0/255 blue:244.0/255 alpha:1],JLTokenTypeNumber,
					 [UIColor colorWithRed:140.0/255 green:34.0/255 blue:96.0/255 alpha:1],JLTokenTypeKeyword,
					 [UIColor colorWithRed:125.0/255 green:72.0/255 blue:49.0/255 alpha:1],JLTokenTypePreprocessor,
					 [UIColor colorWithRed:21.0/255 green:67.0/255 blue:244.0/255 alpha:1],JLTokenTypeURL,
					 [UIColor colorWithRed:150.0/255 green:125.0/255 blue:65.0/255 alpha:1],JLTokenTypeOther,
					 [UIColor colorWithRed:77.0/255 green:129.0/255 blue:134.0/255 alpha:1],JLTokenTypeOtherClassNames,
					 [UIColor colorWithRed:113.0/255 green:65.0/255 blue:163.0/255 alpha:1],JLTokenTypeOtherMethodNames,
					 [UIColor greenColor],JLTokenTypeDiffAddition,
					 [UIColor greenColor],JLTokenTypeDiffDeletion,
					 nil];
            break;
		case JLTokenizerThemePrinting:
            colors = [NSDictionary dictionaryWithObjectsAndKeys:
					 [UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1],JLTokenTypeText,
					 [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1],JLTokenTypeBackground,
					 [UIColor colorWithRed:113.0/255 green:113.0/255 blue:113.0/255 alpha:1],JLTokenTypeComment,
					 [UIColor colorWithRed:113.0/255 green:113.0/255 blue:113.0/255 alpha:1],JLTokenTypeDocumentationComment,
					 [UIColor colorWithRed:64.0/255 green:64.0/255 blue:64.0/255 alpha:1],JLTokenTypeDocumentationCommentKeyword,
					 [UIColor colorWithRed:112.0/255 green:112.0/255 blue:112.0/255 alpha:1],JLTokenTypeString,
					 [UIColor colorWithRed:71.0/255 green:71.0/255 blue:71.0/255 alpha:1],JLTokenTypeCharacter,
					 [UIColor colorWithRed:71.0/255 green:71.0/255 blue:71.0/255 alpha:1],JLTokenTypeNumber,
					 [UIColor colorWithRed:108.0/255 green:108.0/255 blue:108.0/255 alpha:1],JLTokenTypeKeyword,
					 [UIColor colorWithRed:85.0/255 green:85.0/255 blue:85.0/255 alpha:1],JLTokenTypePreprocessor,
					 [UIColor colorWithRed:84.0/255 green:84.0/255 blue:84.0/255 alpha:1],JLTokenTypeURL,
					 [UIColor colorWithRed:129.0/255 green:129.0/255 blue:129.0/255 alpha:1],JLTokenTypeOther,
					 [UIColor colorWithRed:120.0/255 green:120.0/255 blue:120.0/255 alpha:1],JLTokenTypeOtherClassNames,
					 [UIColor colorWithRed:86.0/255 green:86.0/255 blue:86.0/255 alpha:1],JLTokenTypeOtherMethodNames,
					 [UIColor greenColor],JLTokenTypeDiffAddition,
					 [UIColor greenColor],JLTokenTypeDiffDeletion,
					 nil];
            break;
		case JLTokenizerThemeSunset:
            colors = [NSDictionary dictionaryWithObjectsAndKeys:
					 [UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1],JLTokenTypeText,
					 [UIColor colorWithRed:255.0/255 green:252.0/255 blue:236.0/255 alpha:1],JLTokenTypeBackground,
					 [UIColor colorWithRed:208.0/255 green:134.0/255 blue:59.0/255 alpha:1],JLTokenTypeComment,
					 [UIColor colorWithRed:208.0/255 green:134.0/255 blue:59.0/255 alpha:1],JLTokenTypeDocumentationComment,
					 [UIColor colorWithRed:190.0/255 green:116.0/255 blue:55.0/255 alpha:1],JLTokenTypeDocumentationCommentKeyword,
					 [UIColor colorWithRed:234.0/255 green:32.0/255 blue:24.0/255 alpha:1],JLTokenTypeString,
					 [UIColor colorWithRed:53.0/255 green:87.0/255 blue:134.0/255 alpha:1],JLTokenTypeCharacter,
					 [UIColor colorWithRed:53.0/255 green:87.0/255 blue:134.0/255 alpha:1],JLTokenTypeNumber,
					 [UIColor colorWithRed:53.0/255 green:87.0/255 blue:134.0/255 alpha:1],JLTokenTypeKeyword,
					 [UIColor colorWithRed:119.0/255 green:121.0/255 blue:148.0/255 alpha:1],JLTokenTypePreprocessor,
					 [UIColor colorWithRed:85.0/255 green:99.0/255 blue:179.0/255 alpha:1],JLTokenTypeURL,
					 [UIColor colorWithRed:58.0/255 green:76.0/255 blue:166.0/255 alpha:1],JLTokenTypeOther,
					 [UIColor colorWithRed:196.0/255 green:88.0/255 blue:31.0/255 alpha:1],JLTokenTypeOtherClassNames,
					 [UIColor colorWithRed:196.0/255 green:88.0/255 blue:31.0/255 alpha:1],JLTokenTypeOtherMethodNames,
					 [UIColor greenColor],JLTokenTypeDiffAddition,
					 [UIColor greenColor],JLTokenTypeDiffDeletion,
					 nil];
            break;
    }
    return colors;
}

@end
