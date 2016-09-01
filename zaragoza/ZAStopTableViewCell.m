//
//  ZAStopTableViewCell.m
//  zaragoza
//
//  Created by Sven Straubinger on 01/09/16.
//  Copyright © 2016 Sven Straubinger. All rights reserved.
//

#import "ZAStopTableViewCell.h"

@interface ZAStopTableViewCell()

@property(nonatomic, weak) IBOutlet UILabel* idLabel;
@property(nonatomic, weak) IBOutlet UILabel* nameLabel;
@property(nonatomic, weak) IBOutlet UILabel* etaLabel;
@property(nonatomic, weak) IBOutlet UIImageView* mapImageView;

@end

@implementation ZAStopTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
