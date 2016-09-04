//
//  ZAApiService.h
//  zaragoza
//
//  Created by Sven Straubinger on 04/09/16.
//  Copyright © 2016 Sven Straubinger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import "ZABusStop.h"
#import "ZAEstimate.h"

@interface ZAApiService : NSObject

+ (instancetype)sharedInstance;

- (void)requestBusStopsWithSuccessBlock:(void (^)(NSArray *busStops))onSuccess
                           failureBlock:(void (^)(NSString *errorMessage))onFailure;

- (void)estimateForBusStopWithId:(NSString*)identifier
            withSuccessBlock:(void (^)(ZAEstimate *estimate))onSuccess
                failureBlock:(void (^)(NSString *errorMessage))onFailure;

@end
