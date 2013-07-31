//
//  JLTokenizerTests.m
//  Chromatism
//
//  Created by Anviking on 2013-07-31.
//  Copyright (c) 2013 Anviking. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JLTokenizer.h"

@interface JLTokenizerTests : XCTestCase

@end

@implementation JLTokenizerTests
{
    JLTokenizer *tokenizer;
    NSTextStorage *textStorage;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSString *string = @"self //test";
    //                   01234567891
    textStorage = [[NSTextStorage alloc] initWithString:string attributes:@{ @"attribute" : @42 }];
    tokenizer = [[JLTokenizer alloc] init];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBasicTokenizing
{
    [tokenizer tokenizeTextStorage:textStorage withRange:NSMakeRange(0, textStorage.length)];
    
    XCTAssertEqualObjects([textStorage attribute:@"attribute" atIndex:0 effectiveRange:NULL], @42, @"Should keep attribute value");
    
    NSRange selfRange;
    NSRange commentRange;
    
    UIColor *keywordColor = tokenizer.colors[JLTokenTypeKeyword];
    UIColor *commentColor = tokenizer.colors[JLTokenTypeComment];
    
    XCTAssertEqualObjects([textStorage attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:&selfRange], keywordColor, @"Self should be keyword-colored");
    XCTAssertEqualObjects([textStorage attribute:NSForegroundColorAttributeName atIndex:5 effectiveRange:&commentRange], commentColor, @"Should be comment-colored");
    
    XCTAssertEqual(selfRange, NSMakeRange(0, 4), @"self should be colored");
    XCTAssertEqual(commentRange, NSMakeRange(5, 6), @"//test should be colored");
}

@end
