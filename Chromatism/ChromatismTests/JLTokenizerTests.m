//
//  JLTokenizerTests.m
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

#import <XCTest/XCTest.h>
#import "Chromatism.h"
#import "JLTokenizer.h"

@interface JLTokenizer ()
- (JLTokenPattern *)addToken:(NSString *)type withPattern:(NSString *)pattern andScope:(JLScope *)scope;
@end

@interface JLTokenizerTests : XCTestCase

@end

@implementation JLTokenizerTests
{
    JLTokenizer *tokenizer;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    tokenizer = [[JLTokenizer alloc] init];
    tokenizer.colors = [Chromatism colorsForTheme:JLTokenizerThemeDefault];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBasicTokenizing
{
    NSString *string = @"self //test";
    //                   01234567891
    NSTextStorage* textStorage = [[NSTextStorage alloc] initWithString:string attributes:@{ @"attribute" : @42 }];
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

- (void)testDemoTextDescription
{
    // Load demo text
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    NSURL *URL = [bundle URLForResource:@"demo" withExtension:@"txt"];
    NSString *string = [[NSString alloc] initWithData:[NSData dataWithContentsOfURL:URL] encoding:NSUTF8StringEncoding];
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:string];
    
    NSRange range = NSMakeRange(0, textStorage.length);
    
    JLScope *documentScope = [JLScope scopeWithTextStorage:textStorage];
    JLScope *rangeScope = [JLScope scopeWithRange:range inTextStorage:textStorage];
    
    // Block and line comments
    [tokenizer addToken:JLTokenTypeComment withPattern:@"/\\*([^*]|[\\r\\n]|(\\*+([^*/]|[\\r\\n])))*\\*+/" andScope:documentScope];
    [tokenizer addToken:JLTokenTypeComment withPattern:@"//.*+$" andScope:rangeScope];
    
    // Preprocessor macros
    JLTokenPattern *preprocessor = [tokenizer addToken:JLTokenTypePreprocessor withPattern:@"#.*+$" andScope:rangeScope];
    
    // #import <Library/Library.h>
    // In xcode it only works for #import and #include, not all preprocessor statements.
    [tokenizer addToken:JLTokenTypeString withPattern:@"<.*?>" andScope:preprocessor];
    
    // Strings
    [[tokenizer addToken:JLTokenTypeString withPattern:@"(\"|@\")[^\"\\n]*(@\"|\")" andScope:rangeScope] addScope:preprocessor];
    
    // Numbers
    [tokenizer addToken:JLTokenTypeNumber withPattern:@"(?<=\\s)\\d+" andScope:rangeScope];
    
    // New literals, for example @[]
    // TODO: Literals don't search through multiple lines. Nor does it keep track of nested things.
    [[tokenizer addToken:JLTokenTypeNumber withPattern:@"@[\\(|\\{|\\[][^\\(\\{\\[]+[\\)|\\}|\\]]" andScope:rangeScope] setOpaque:NO];
    
    // C function names
    [[tokenizer addToken:JLTokenTypeOtherMethodNames withPattern:@"\\w+\\s*(?>\\(.*\\)" andScope:rangeScope] setCaptureGroup:1];
    
    // Dot notation
    [[tokenizer addToken:JLTokenTypeOtherMethodNames withPattern:@"\\.(\\w+)" andScope:rangeScope] setCaptureGroup:1];
    
    // Method Calls
    [[tokenizer addToken:JLTokenTypeOtherMethodNames withPattern:@"\\[\\w+\\s+(\\w+)\\]" andScope:rangeScope] setCaptureGroup:1];
    
    // Method call parts
    [[tokenizer addToken:JLTokenTypeOtherMethodNames withPattern:@"(?<=\\w+):\\s*[^\\s;\\]]+" andScope:rangeScope] setCaptureGroup:1];
    
    // NS and UI prefixes words
    [tokenizer addToken:JLTokenTypeOtherClassNames withPattern:@"(\\b(?>NS|UI))\\w+\\b" andScope:rangeScope];
    
    [tokenizer addToken:JLTokenTypeKeyword withPattern:@"(?<=\\b)(?>true|false|yes|no|TRUE|FALSE|bool|BOOL|nil|id|void|self|NULL|if|else|strong|weak|nonatomic|atomic|assign|copy|typedef|enum|auto|break|case|const|char|continue|do|default|double|extern|float|for|goto|int|long|register|return|short|signed|sizeof|static|struct|switch|typedef|union|unsigned|volatile|while|nonatomic|atomic|nonatomic|readonly|super )(\\b)" andScope:rangeScope];
    [tokenizer addToken:JLTokenTypeKeyword withPattern:@"@[a-zA-Z0-9_]+" andScope:rangeScope];
    
    [documentScope addSubscope:rangeScope];
    [documentScope perform];
    
    NSURL *descriptionURL = [bundle URLForResource:@"description" withExtension:@"txt"];
    NSMutableString *description = [[NSString alloc] initWithData:[NSData dataWithContentsOfURL:descriptionURL] encoding:NSUTF8StringEncoding].mutableCopy;
    NSMutableString *newDescription = [documentScope description].mutableCopy;
    
    // Remove hexadecimal garbage
    NSError *error = nil;
    NSRegularExpression *expression = [[NSRegularExpression alloc] initWithPattern:@"0(x|X)[0-9a-fA-F]{7}>" options:0 error:&error];
    [expression replaceMatchesInString:description options:0 range:NSMakeRange(0, description.length) withTemplate:@""];
    [expression replaceMatchesInString:newDescription options:0 range:NSMakeRange(0, newDescription.length) withTemplate:@""];
    
    XCTAssertNil(nil, @"");
    XCTAssertEqualObjects(description, newDescription, @"");
    
}

- (NSTimeInterval)timeOfTokenizingString:(NSString *)string multiplied:(NSInteger)multiplier
{
    string = [string stringByPaddingToLength:(string.length * multiplier) withString:string startingAtIndex:0];
    NSTextStorage *storage = [[NSTextStorage alloc] initWithString:string];
    NSDate *date = [NSDate date];
    [tokenizer tokenizeTextStorage:storage withRange:NSMakeRange(0, string.length)];
    return ABS([date timeIntervalSinceNow]);
}

- (NSTimeInterval)timeOfTokenizingString:(NSString *)string range:(NSRange)range multiplied:(NSInteger)multiplier
{
    string = [string stringByPaddingToLength:(string.length * multiplier) withString:string startingAtIndex:0];
    NSTextStorage *storage = [[NSTextStorage alloc] initWithString:string];
    NSDate *date = [NSDate date];
    [tokenizer tokenizeTextStorage:storage withRange:range];
    return ABS([date timeIntervalSinceNow]);
}

/*
- (void)testAndPlotLater
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *URL = [bundle URLForResource:@"demo" withExtension:@"txt"];
    NSString *string = [[NSString alloc] initWithData:[NSData dataWithContentsOfURL:URL] encoding:NSUTF8StringEncoding];
    NSMutableString *result = [[NSMutableString alloc] init];
    for (int i = 1; i<50; i++) {
        NSTimeInterval interval = [self timeOfTokenizingString:string multiplied:i];
        [result appendFormat:@"%f,",interval];
    }
    NSLog(@"Result:%@",result);
}
 */

- (void)testLargeFilePerformance
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *URL = [bundle URLForResource:@"demo" withExtension:@"txt"];
    NSString *string = [[NSString alloc] initWithData:[NSData dataWithContentsOfURL:URL] encoding:NSUTF8StringEncoding];
    NSTimeInterval interval = [self timeOfTokenizingString:string multiplied:10];
    NSLog(@"\n\nLarge file tokenizing: %fms\n\n", interval*1000);
}

- (void)testSmallEditPerformance
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *URL = [bundle URLForResource:@"demo" withExtension:@"txt"];
    NSString *string = [[NSString alloc] initWithData:[NSData dataWithContentsOfURL:URL] encoding:NSUTF8StringEncoding];
    NSTimeInterval interval = [self timeOfTokenizingString:string range:[string lineRangeForRange:NSMakeRange(500, 5)] multiplied:1];
    NSLog(@"\n\nLine edit Performance: %fms\n\n", interval*1000);
}

@end
