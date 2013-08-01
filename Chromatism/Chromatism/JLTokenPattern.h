//
//  JLTokenPattern.h
//  iGitpad
//
//  Created by Johannes Lund on 2013-06-30.
//  Copyright (c) 2013 Anviking. All rights reserved.
//

#import "JLScope.h"

@interface JLTokenPattern : JLScope

+ (instancetype)tokenPatternWithPattern:(NSString *)pattern;

// Setting either expression or pattern causes the other one to update.
@property (nonatomic, strong) NSRegularExpression *expression;
@property (nonatomic, copy) NSString *pattern;

@property (nonatomic, assign) NSMatchingOptions matchingOptions;

/**
 *  The index of the capture group which will be used as result from the regex search. Default is 0.
 */
@property (nonatomic, assign) NSUInteger captureGroup;

@end
