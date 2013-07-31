//
//  Chromatism.m
//  Chromatism
//
//  Created by Johannes Lund on 2013-07-01.
//  Copyright (c) 2013 Anviking. All rights reserved.
//

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
                       JLTokenTypeOtherClassNames :  [UIColor colorWithHex:@"7040a6" alpha:1]
                       
                       
                       
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
                       JLTokenTypeOtherMethodNames :  [UIColor colorWithHex:@"04afc8" alpha:1]
                       };
            break;
    }
    return colors;
}

@end
