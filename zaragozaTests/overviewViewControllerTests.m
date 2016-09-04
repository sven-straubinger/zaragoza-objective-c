//
//  overviewViewControllerTests.m
//  overviewViewControllerTests
//
//  Created by Sven Straubinger on 01/09/16.
//  Copyright © 2016 Sven Straubinger. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface overviewViewControllerTests : XCTestCase

@property(nonatomic, strong) UIViewController *viewController;

@end

@implementation overviewViewControllerTests

- (void)setUp {
    [super setUp];
    
    // Load view controller from storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.viewController = [storyboard instantiateViewControllerWithIdentifier:@"ZAOverviewViewController"];
}

- (void)tearDown {
    self.viewController = nil;
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

#warning Review performance test
- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
