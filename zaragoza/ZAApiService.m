//
//  ZAApiService.m
//  zaragoza
//
//  Created by Sven Straubinger on 04/09/16.
//  Copyright © 2016 Sven Straubinger. All rights reserved.
//

#import "ZAApiService.h"

@implementation ZAApiService

+ (instancetype)sharedInstance {
    static ZAApiService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ZAApiService alloc] init];
    });
    return sharedInstance;
}

- (void)requestUrl:(NSString *)url
  withSuccessBlock:(void (^)(NSURLSessionTask *task, id responseObject))onSuccess
      failureBlock:(void (^)(NSURLSessionTask *task, NSError *error))onFailure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:url
      parameters:nil
        progress:nil
         success:onSuccess
         failure:onFailure];
}

@end
