//
//  rootViewControllerTest.m
//  zaragoza
//
//  Created by Sven Straubinger on 04/09/16.
//  Copyright © 2016 Sven Straubinger. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface rootViewControllerTest : XCTestCase

@property(nonatomic, strong) UIViewController *viewController;

@end

@implementation rootViewControllerTest

- (void)setUp {
    [super setUp];
    
    // Load initial view controller from storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.viewController = [storyboard instantiateInitialViewController];    
}

- (void)tearDown {
    self.viewController = nil;
    [super tearDown];
}

- (void)testKindOfClass {
    XCTAssertTrue([self.viewController isKindOfClass:[UINavigationController class]]);
}

- (void)DISABLE_testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
