//
//  UIAlertController+Collections.h
//  zaragoza
//
//  Created by Sven Straubinger on 04/09/16.
//  Copyright © 2016 Sven Straubinger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (Collections)

+ (UIAlertController*)controllerWithTitle:(NSString*)title
                                  message:(NSString*)message
                              actionTitle:(NSString*)actionTitle;

@end
