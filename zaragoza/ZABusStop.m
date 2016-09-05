//
//  ZABusStop.m
//  zaragoza
//
//  Created by Sven Straubinger on 01/09/16.
//  Copyright © 2016 Sven Straubinger. All rights reserved.
//

#import "ZABusStop.h"

static NSString *kImageBasePath= @"http://maps.googleapis.com/maps/api/staticmap";

@implementation ZABusStop

+ (EKObjectMapping *)objectMapping
{
    return [EKObjectMapping mappingForClass:self withBlock:^(EKObjectMapping *mapping) {
        [mapping mapKeyPath:@"id" toProperty:@"identifier"];
        [mapping mapKeyPath:@"title" toProperty:@"name"];
        [mapping mapKeyPath:@"lat" toProperty:@"lat"];
        [mapping mapKeyPath:@"lon" toProperty:@"lng"];
    }];
}

- (NSURL*)imageUrl {
    
    // Prepare latitude/longitude string
    NSString *latlng = [NSString stringWithFormat:@"%f,%f", self.lat, self.lng];

    // Define base path
    NSURLComponents *components = [NSURLComponents componentsWithString:kImageBasePath];
    
    // Define query parameter
    NSURLQueryItem *zoom = [NSURLQueryItem queryItemWithName:@"zoom" value:@"15"];
    NSURLQueryItem *size = [NSURLQueryItem queryItemWithName:@"size" value:@"180x180"];
    NSURLQueryItem *center = [NSURLQueryItem queryItemWithName:@"center" value:latlng];
    NSURLQueryItem *sensor = [NSURLQueryItem queryItemWithName:@"sensor" value:@"true"];
    
    // Combine and return
    components.queryItems = @[ zoom, size, center, sensor ];
    return components.URL;
}

- (NSString*)formattedEstimateText {
    
    // If an estimate is available, return formatted text ...
    if(self.estimate) {
        return [NSString stringWithFormat:@"%ld minutes via line %@", self.estimate.estimate, self.estimate.line];
    } else {
        // ... or a loading hint otherwise
        return @"Loading ...";
    }
    
}

@end
