//
//  ZABusStop.h
//  zaragoza
//
//  Created by Sven Straubinger on 01/09/16.
//  Copyright © 2016 Sven Straubinger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EasyMapping.h>
#import <UIKit/UIKit.h>
#import "ZAEstimate.h"

@interface ZABusStop : NSObject <EKMappingProtocol>

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *imageUrl;
@property (nonatomic, strong) ZAEstimate *estimate; // From the returned JSON, we only select the most relevant one
@property (nonatomic, assign) double lat;
@property (nonatomic, assign) double lng;

- (NSString*)formattedEstimateText;

@end
