//
//  ZAApiService.m
//  zaragoza
//
//  Created by Sven Straubinger on 04/09/16.
//  Copyright © 2016 Sven Straubinger. All rights reserved.
//

#import "ZAApiService.h"

static NSString *kApiBasePath = @"http://api.dndzgz.com/services/bus";

@implementation ZAApiService

#pragma mark - Public Methods

+ (instancetype)sharedInstance {
    static ZAApiService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ZAApiService alloc] init];
    });
    return sharedInstance;
}

- (void)requestBusStopsWithSuccessBlock:(void (^)(NSArray *busStops))onSuccess
                           failureBlock:(void (^)(NSString *errorMessage))onFailure {
    
    // First, Define request-onSuccess block
    void (^onRequestSuccess)(NSURLSessionTask*, id) = ^(NSURLSessionTask *task, id responseObject) {
        
        // The responseObject should be a NSDictionary, early return if not
        if(![responseObject isKindOfClass:[NSDictionary class]]) {
            NSLog(@"Response object is not kind of class `NSDictionary`.");
            return;
        }
        
        // Retrieve locations
        NSArray *locations = [responseObject valueForKey:@"locations"];
        NSArray *busStops = [EKMapper arrayOfObjectsFromExternalRepresentation:locations
                                                               withMapping:[ZABusStop objectMapping]];
        onSuccess(busStops);
    };
    
    // Second, define request-onFailure block
    void (^onRequestFailure)(NSURLSessionTask*, NSError*) = ^(NSURLSessionTask *task, NSError *error) {
        onFailure(error.localizedDescription);
    };
    
    // Finally: Execute request
    [self requestUrl:kApiBasePath
    withSuccessBlock:onRequestSuccess
        failureBlock:onRequestFailure];
}


- (void)estimateForBusStopWithId:(NSString*)identifier
            withSuccessBlock:(void (^)(ZAEstimate *estimate))onSuccess
                failureBlock:(void (^)(NSString *errorMessage))onFailure {
    
    // Define url
    NSString *url = [NSString stringWithFormat:@"%@/%@", kApiBasePath, identifier];
    
    // Define request-onSuccess block
    void (^onRequestSuccess)(NSURLSessionTask*, id) = ^(NSURLSessionTask *task, id responseObject) {
        
        // The responseObject should be a NSDictionary, early return if not
        if(![responseObject isKindOfClass:[NSDictionary class]]) {
            onFailure(@"Response object is not kind of class `NSDictionary`.");
            return;
        }
        
        // Retrieve estimates
        NSArray *rawEstimates = [responseObject valueForKey:@"estimates"];
        NSArray *estimates = [EKMapper arrayOfObjectsFromExternalRepresentation:rawEstimates
                                                                    withMapping:[ZAEstimate objectMapping]];
        
        // Sort to retrieve shortest estimate first, which is the most relevant
        NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"estimate" ascending:YES]];
        NSArray *sortedEstimates = [estimates sortedArrayUsingDescriptors:sortDescriptors];
        ZAEstimate *head = sortedEstimates.firstObject;
        
        // Check, if result is a non-nil value
        if(head) {
            onSuccess(head);
        } else {
            onFailure(@"No results were returned.");
        }
    };
    
    // Define request-onFailure block
    void (^onRequestFailure)(NSURLSessionTask*, NSError*) = ^(NSURLSessionTask *task, NSError *error) {
        onFailure(error.localizedDescription);
    };
    
    // Execute request
    [self requestUrl:url
    withSuccessBlock:onRequestSuccess
        failureBlock:onRequestFailure];
}


#pragma mark - Private Methods

- (void)requestUrl:(NSString *)url
  withSuccessBlock:(void (^)(NSURLSessionTask *task, id responseObject))onSuccess
      failureBlock:(void (^)(NSURLSessionTask *task, NSError *error))onFailure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:url
      parameters:nil
        progress:nil
         success:onSuccess     // Please note from the docs: Since we did not specify any dispatch queue,
         failure:onFailure];   // the main queue is used for all completion blocks --> so UI updates are fine.
}


@end
