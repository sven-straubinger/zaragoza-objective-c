//
//  ZAApiService.h
//  zaragoza
//
//  Created by Sven Straubinger on 04/09/16.
//  Copyright © 2016 Sven Straubinger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

@interface ZAApiService : NSObject

+ (instancetype)sharedInstance;

- (void)requestUrl:(NSString *)url
  withSuccessBlock:(void (^)(NSURLSessionTask *task, id responseObject))onSuccess
      failureBlock:(void (^)(NSURLSessionTask *task, NSError *error))onFailure;

@end
