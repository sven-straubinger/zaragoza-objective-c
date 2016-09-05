//
//  UIScrollView+Helper.m
//  zaragoza
//
//  Created by Sven Straubinger on 05/09/16.
//  Copyright © 2016 Sven Straubinger. All rights reserved.
//

#import "UIScrollView+Helper.h"

@implementation UIScrollView (Helper)

- (BOOL)isScrollEnding {
    return (self.dragging == NO && self.decelerating == NO);
}

@end
