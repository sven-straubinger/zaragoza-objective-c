//
//  overviewViewControllerTests.m
//  overviewViewControllerTests
//
//  Created by Sven Straubinger on 01/09/16.
//  Copyright © 2016 Sven Straubinger. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZAOverviewViewController.h"

@interface overviewViewControllerTests : XCTestCase

@property(nonatomic, strong) ZAOverviewViewController *viewController;

@end

@implementation overviewViewControllerTests

- (void)setUp {
    [super setUp];
    
    // Load view controller from storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.viewController = [storyboard instantiateViewControllerWithIdentifier:@"ZAOverviewViewController"];
    [self.viewController performSelectorOnMainThread:@selector(loadView) withObject:nil waitUntilDone:YES];
}

- (void)tearDown {
    self.viewController = nil;
    [super tearDown];
}

- (void)testThatViewLoads {
    XCTAssertNotNil(self.viewController.view, @"View not initiated properly.");
}

- (void)testParentViewHasTableViewSubview {
    NSArray *subviews = self.viewController.view.subviews;
    XCTAssertTrue([subviews containsObject:self.viewController.tableView]);
}

- (void)DISABLE_testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
