/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Helper object for managing the downloading of a particular app's icon.
  It uses NSURLSession/NSURLSessionDataTask to download the app's icon in the background if it does not
  yet exist and works in conjunction with the RootViewController to manage which apps need their icon.
 */

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
    self.sessionTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    
        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];

                                                       
        if (error != nil) {
            NSLog(error.localizedDescription);
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

