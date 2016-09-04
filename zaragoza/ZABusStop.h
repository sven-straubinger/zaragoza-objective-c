//
//  ZABusStop.h
//  zaragoza
//
//  Created by Sven Straubinger on 01/09/16.
//  Copyright © 2016 Sven Straubinger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EasyMapping.h>

@interface ZABusStop : NSObject <EKMappingProtocol>

@property (nonatomic) NSString *identifier;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *eta;

@end
