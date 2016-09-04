//
//  ZAEstimate.h
//  zaragoza
//
//  Created by Sven Straubinger on 04/09/16.
//  Copyright © 2016 Sven Straubinger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EasyMapping.h>

@interface ZAEstimate : NSObject <EKMappingProtocol>

@property(nonatomic, strong) NSString *line;
@property(nonatomic, strong) NSString *direction;
@property(nonatomic, strong) NSString *estimate;

@end
