//
//  JLTextStorage.m
//  iGitpad
//
//  Created by Johannes Lund on 2013-06-13.
//  Copyright (c) 2013 Anviking. All rights reserved.
//

#import "JLTextStorage.h"

@interface JLTextStorage ()
{
    NSMutableAttributedString *_backingStore;
    BOOL _dynamicTextNeedsUpdate;
}
@end

@implementation JLTextStorage

- (id)init
{
    self = [super init];
    if (self) {
        _backingStore = [[NSMutableAttributedString alloc] init];
    }
    return self;
}

- (NSString *)string
{
    return [_backingStore string];
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)aRange
{
    return [_backingStore attributesAtIndex:index effectiveRange:aRange];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str
{
    [_backingStore replaceCharactersInRange:range withString:str];
    [self edited:NSTextStorageEditedCharacters range:range changeInLength:str.length - range.length];
    _dynamicTextNeedsUpdate = YES;
}

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
    [_backingStore setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
}

- (void)processEditing
{
    if (_dynamicTextNeedsUpdate) {
        _dynamicTextNeedsUpdate = NO;
        [self preformReplacementsForCharacterChangeInRange:[self editedRange]];
    }
    
    [super processEditing];
}

- (void)preformReplacementsForCharacterChangeInRange:(NSRange)range
{
    NSRange extendedRange = NSUnionRange(range, [[_backingStore string] lineRangeForRange:NSMakeRange(NSMaxRange(range), 0)]);
    
    [self tokenizeRange:extendedRange];
}

- (void)tokenizeRange:(NSRange)range
{
    if (self.tokenizer && [self.tokenizer conformsToProtocol:@protocol(JLTextStorageTokenizer)])
    {
        [self.tokenizer tokenizeTextStorage:self withRange:range];
    }
}

@end