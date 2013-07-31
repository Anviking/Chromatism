//
//  ChromatismTests.m
//  ChromatismTests
//
//  Created by Johannes Lund on 2013-07-01.
//  Copyright (c) 2013 Anviking. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Chromatism.h"
#import "Helpers.h"

@interface ChromatismTests : XCTestCase

@end

@implementation ChromatismTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testIntersection
{
    NSIndexSet *setA = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(5, 20)];
    NSIndexSet *setB = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 7)];
    
    NSIndexSet *result = [setA intersectionWithSet:setB];
    
    XCTAssertEqualObjects(result, [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(5, 5)], @"");
    
}

- (void)testSubscopes
{
    NSTextStorage *storage = [[NSTextStorage alloc] initWithString:@"Test test test test"];
    JLScope *scope = [JLScope scopeWithTextStorage:storage];
    
    XCTAssert(scope.opaque, @"scopes should be opaque per default");
    
    JLScope *subscope1 = [JLScope scopeWithRange:NSMakeRange(0, 1) inTextStorage:nil];
    JLScope *subscope2 = [JLScope scopeWithRange:NSMakeRange(1, 1) inTextStorage:nil];
    JLScope *subscope3 = [JLScope scopeWithRange:NSMakeRange(2, 1) inTextStorage:nil];
    JLScope *subscope4 = [JLScope scopeWithRange:NSMakeRange(3, 1) inTextStorage:nil];
    
    [scope setSubscopes:@[subscope1, subscope2]];
    [scope addSubscope:subscope3];
    
    subscope4.scope = scope;
    
    
    XCTAssertEqualObjects(subscope1.scope, scope, @"");
    XCTAssertEqualObjects(subscope2.scope, scope, @"");
    XCTAssertEqualObjects(subscope3.scope, scope, @"");
    XCTAssertEqualObjects(subscope4.scope, scope, @"");
    
    XCTAssertNotEqualObjects(subscope1.textStorage, scope.textStorage, @"");
    XCTAssertNotEqualObjects(subscope2.textStorage, scope.textStorage, @"");
    XCTAssertNotEqualObjects(subscope3.textStorage, scope.textStorage, @"");
    XCTAssertNotEqualObjects(subscope4.textStorage, scope.textStorage, @"");
    
    [scope perform];
    
    XCTAssertEqualObjects(subscope1.textStorage, scope.textStorage, @"");
    XCTAssertEqualObjects(subscope2.textStorage, scope.textStorage, @"");
    XCTAssertEqualObjects(subscope3.textStorage, scope.textStorage, @"");
    XCTAssertEqualObjects(subscope4.textStorage, scope.textStorage, @"");
    
    XCTAssertTrue([scope.subscopes isKindOfClass:[NSMutableArray class]], @"subscopes should be of type NSMutableArray");
}

@end
