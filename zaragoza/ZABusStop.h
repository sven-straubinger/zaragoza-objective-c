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

@interface ZABusStop : NSObject <EKMappingProtocol>

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *eta;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *imageUrl;

@end
