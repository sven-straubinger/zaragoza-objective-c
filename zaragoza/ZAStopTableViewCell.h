//
//  ZAStopTableViewCell.h
//  zaragoza
//
//  Created by Sven Straubinger on 01/09/16.
//  Copyright © 2016 Sven Straubinger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZAStopTableViewCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UILabel *identifierLabel;
@property(nonatomic, weak) IBOutlet UILabel *nameLabel;
@property(nonatomic, weak) IBOutlet UILabel *etaLabel;
@property(nonatomic, weak) IBOutlet UIImageView *mapImageView;

@end
