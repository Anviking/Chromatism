//
//  JLScope.h
//  iGitpad
//
//  Created by Johannes Lund on 2013-06-30.
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

@protocol JLScopeDelegate;

@interface JLScope : NSOperation

// Designated initializors
+ (instancetype)scopeWithRange:(NSRange)range inTextStorage:(NSTextStorage *)textStorage;
+ (instancetype)scopeWithTextStorage:(NSTextStorage *)textStorage;

@property (nonatomic, strong) NSMutableIndexSet *set;
/**
 *  Causes the every scope to perform cascadingly
 */

- (void)addSubscope:(JLScope *)scope;
- (void)addScope:(JLScope *)scope;

/// Array of parent scopes
@property (nonatomic, strong) NSMutableArray *scopes;

/**
 *  A weak reference to a textStorage in which the scope is operating. Will be passed down to subscopes.
 */
@property (nonatomic, weak) NSTextStorage *textStorage;

/**
 *  A shared instance of the textStorage's string.
 */
@property (nonatomic, readonly, strong) NSString *string;

/**
 *  Describes wether the instance removes it's indexes from the containg scope. Default is YES.
 */
@property (nonatomic, assign, getter = isOpaque) BOOL opaque;

/**
 *  If TRUE, the instance will act as if its subscopes where connected directly to the instance's parent's scope. 
 */
@property (nonatomic, assign, getter = isEmpty) BOOL empty;

/**
 *  An unique identifier of the scope
 */
@property (nonatomic, assign) NSString *identifier;

/**
 *  What kind of scope is this?
 */
@property (nonatomic, copy) NSString *type;

/**
 *  A simple delegate
 */
@property (nonatomic, weak) id<JLScopeDelegate> delegate;

/**
 *  If provided, the scope will only perform when matches of the set is found in the string returned from the -mergedModifiedStringForScope: delegate method.
 */
@property (nonatomic, strong) NSCharacterSet *triggeringCharacterSet;

@end

@protocol JLScopeDelegate <NSObject>
@optional

- (NSDictionary *)attributesForScope:(JLScope *)scope;

/// @see JLTokenizer and -triggeringCharacterSet
- (NSString *)mergedModifiedStringForScope:(JLScope *)scope;

- (BOOL)scopeShouldPerform:(JLScope *)scope;
- (void)scope:(JLScope *)scope didChangeIndexesFrom:(NSIndexSet *)oldSet to:(NSIndexSet *)newSet;

@end
