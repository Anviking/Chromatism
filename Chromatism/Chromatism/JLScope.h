//
//  JLScope.h
//  iGitpad
//
//  Created by Johannes Lund on 2013-06-30.
//  Copyright (c) 2013 Anviking. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JLScope : NSMutableIndexSet

// Designated initializors
+ (instancetype)scopeWithRange:(NSRange)range inTextStorage:(NSTextStorage *)textStorage;
+ (instancetype)scopeWithTextStorage:(NSTextStorage *)textStorage;

/**
 *  Causes the every scope to perform cascadingly
 */
- (void)perform;

/**
 *  Array of nested JLScopes and JLTokenPatterns. Reverse realationship to scope, setting one causes the other to update. No not mutate. 
 */
@property (nonatomic, strong) NSArray *subscopes;

/**
 *  Weak reference to the parent scope. Default nil means that there is no parent. Reverse realationship to subscopes, setting one causes the other to update.
 */

@property (nonatomic, weak) JLScope *scope;

- (void)addSubscope:(JLScope *)subscope;
- (void)removeSubscope:(JLScope *)subscope;


/**
 *  A weak reference to a textStorage in which the scope is operating. Will be passed down to subscopes.
 */
@property (nonatomic, weak) NSTextStorage *textStorage;

/**
 *  Describes wether the pattern matches will remove indexes from the clearIndexes property. Default is FALSE for JLScope and TRUE for JLTokenPattern.
 */
@property (nonatomic, assign, getter = isOpaque) BOOL opaque;

/**
 *  Indexes where there are no opaque subscopes.
 */
@property (nonatomic, strong) NSMutableIndexSet *clearIndexes;
@end
