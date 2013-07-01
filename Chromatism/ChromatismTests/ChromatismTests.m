//
//  ChromatismTests.m
//  ChromatismTests
//
//  Created by Johannes Lund on 2013-07-01.
//  Copyright (c) 2013 Anviking. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Chromatism.h"

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

- (void)testSubscopes
{
    JLScope *scope = [JLScope new];
    JLScope *subscope1 = [JLScope new];
    JLScope *subscope2 = [JLScope new];
    JLScope *subscope3 = [JLScope new];
    JLScope *subscope4 = [JLScope new];
    
    [scope setSubscopes:@[subscope1, subscope2]];
    [scope addSubscope:subscope3];
    
    subscope4.scope = scope;
    
    XCTAssertEqualObjects(subscope1.scope, scope, @"");
    XCTAssertEqualObjects(subscope2.scope, scope, @"");
    XCTAssertEqualObjects(subscope3.scope, scope, @"");
    XCTAssertEqualObjects(subscope4.scope, scope, @"");
    
    XCTAssertTrue([scope.subscopes isKindOfClass:[NSMutableArray class]], @"subscopes should be of type NSMutableArray");
}

@end
