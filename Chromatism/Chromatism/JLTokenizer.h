//
//  Tokenizer.h
//  iGitpad
//
//  Created by Johannes Lund on 2012-11-24.
//
//

#import <Foundation/Foundation.h>
#import "Helpers.h"
#import "Chromatism+Internal.h"

@class TextViewChange, JLTextView;
@interface JLTokenizer : NSObject <UITextViewDelegate, NSTextStorageDelegate, NSLayoutManagerDelegate>

// Override to create your own syntax highlighting
- (void)tokenizeTextStorage:(NSTextStorage *)storage withRange:(NSRange)range;

- (void)clearColorAttributesInRange:(NSRange)range textStorage:(NSTextStorage *)storage;
- (NSMutableAttributedString *)tokenizeString:(NSString *)string withDefaultAttributes:(NSDictionary *)attributes;

@property (nonatomic, strong) NSDictionary *colors;
@property (nonatomic, strong) NSDictionary *defaultAttributes;

@property (nonatomic, strong) UIColor *highlightColor;
@property (nonatomic, assign) JLTokenizerTheme theme;
@property (nonatomic, strong, readonly) NSArray *themes;
@property (nonatomic, weak) UITextView *textView;
@end
