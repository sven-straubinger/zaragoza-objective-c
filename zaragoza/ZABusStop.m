//
//  ZABusStop.m
//  zaragoza
//
//  Created by Sven Straubinger on 01/09/16.
//  Copyright © 2016 Sven Straubinger. All rights reserved.
//

#import "ZABusStop.h"

@implementation ZABusStop

+(EKObjectMapping *)objectMapping
{
    return [EKObjectMapping mappingForClass:self withBlock:^(EKObjectMapping *mapping) {
        [mapping mapKeyPath:@"id" toProperty:@"identifier"];
        [mapping mapKeyPath:@"title" toProperty:@"name"];
        [mapping mapKeyPath:@"lat" toProperty:@"lat"];
        [mapping mapKeyPath:@"lon" toProperty:@"lng"];
#warning Implement estimated time of arrival
    }];
}

@end
