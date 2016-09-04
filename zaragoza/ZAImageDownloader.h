//
//  ZAImageDownloader.h
//  zaragoza
//
//  Created by Sven Straubinger on 04/09/16.
//  Copyright © 2016 Sven Straubinger. All rights reserved.
//
//  This file partially implements samples from
//  https://developer.apple.com/library/ios/samplecode/LazyTableImages/Introduction/Intro.html
//

#import <Foundation/Foundation.h>

@class ZABusStop;
@interface ZAImageDownloader : NSObject

@property (nonatomic, strong) ZABusStop *busStop;
@property (nonatomic, copy) void (^completionHandler)(void);

- (void)startDownload;
- (void)cancelDownload;

@end
