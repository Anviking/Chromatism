//
//  JLScope.h
//  iGitpad
//
//  Created by Johannes Lund on 2013-06-30.
//  Copyright (c) 2013 Anviking. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JLScopeDelegate;

@interface JLScope : NSObject

// Designated initializors
+ (instancetype)scopeWithRange:(NSRange)range inTextStorage:(NSTextStorage *)textStorage;
+ (instancetype)scopeWithTextStorage:(NSTextStorage *)textStorage;

@property (nonatomic, strong) NSMutableIndexSet *set;
/**
 *  Causes the every scope to perform cascadingly
 */
- (void)perform;
- (void)performInIndexSet:(NSIndexSet *)set;

/// The color
@property (nonatomic, strong) UIColor *color;

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
 *  Creates a copy of the instance, and adds 
 */

- (void)addScope:(JLScope *)scope;


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
 *  A identifier of the scope
 */
@property (nonatomic, copy) NSString *identifier;

/**
 *  A simple delegate
 */
@property (nonatomic, weak) id<JLScopeDelegate> delegate;

@end

@protocol JLScopeDelegate <NSObject>

- (void)scopeDidFinishPerforming:(JLScope *)scope;

@end
