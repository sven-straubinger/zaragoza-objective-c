//
//  ImageDownloader.m
//  zaragoza
//
//  Created by Sven Straubinger on 04/09/16.
//  Copyright © 2016 Sven Straubinger. All rights reserved.
//
//  This file partially implements samples from
//  https://developer.apple.com/library/ios/samplecode/LazyTableImages/Introduction/Intro.html
//

#import "ImageDownloader.h"
#import "ZABusStop.h"

#define kAppIconSize 90

@interface ImageDownloader ()

@property (nonatomic, strong) NSURLSessionDataTask *sessionTask;

@end

@implementation ImageDownloader

- (void)startDownload {
    NSURLRequest *request = [NSURLRequest requestWithURL:self.busStop.imageUrl];

    // Create a session data task to obtain and download the app icon
    self.sessionTask = [[NSURLSession sharedSession]
                        dataTaskWithRequest:request
                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    
        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                                                       
        if (error != nil) {
            NSLog(@"%@", error.localizedDescription);
            return;
        }
                                                       
        if(statusCode != 200) {
            NSLog(@"Status code was not ok 200");
            return;
        }
                                                       
        [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
            
            // Set appIcon and clear temporary data/image
            UIImage *image = [[UIImage alloc] initWithData:data];
            
            if (image.size.width != kAppIconSize || image.size.height != kAppIconSize) {
                CGSize itemSize = CGSizeMake(kAppIconSize, kAppIconSize);
                UIGraphicsBeginImageContextWithOptions(itemSize, NO, 0.0f);
                CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
                [image drawInRect:imageRect];
                self.busStop.image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            } else {
                self.busStop.image = image;
            }
            
            // Call our completion handler to tell our client that our icon is ready for display
            if (self.completionHandler != nil) {
                self.completionHandler();
            }
        }];
    }];
    
    [self.sessionTask resume];
}

- (void)cancelDownload {
    [self.sessionTask cancel];
    self.sessionTask = nil;
}

@end

