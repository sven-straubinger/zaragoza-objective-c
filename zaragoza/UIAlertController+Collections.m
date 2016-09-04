//
//  UIAlertController+Collections.m
//  zaragoza
//
//  Created by Sven Straubinger on 04/09/16.
//  Copyright © 2016 Sven Straubinger. All rights reserved.
//

#import "UIAlertController+Collections.h"

@implementation UIAlertController (Collections)

+ (UIAlertController*)controllerWithTitle:(NSString*)title
                                  message:(NSString*)message
                              actionTitle:(NSString*)actionTitle {
    // Initalize alert controller
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    // Initalize alert action
    UIAlertAction *action = [UIAlertAction
                             actionWithTitle:actionTitle
                             style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                 [alertController dismissViewControllerAnimated:YES completion:nil];
                             }];
    // Combine & return
    [alertController addAction:action];
    return alertController;
}

@end
