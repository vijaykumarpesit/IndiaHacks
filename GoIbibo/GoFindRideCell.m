//
//  GoFindRideCell.m
//  GoIbibo
//
//  Created by Vijay on 18/03/16.
//  Copyright © 2016 Vijay. All rights reserved.
//

#import "GoFindRideCell.h"

@interface GoFindRideCell ()

@property (weak, nonatomic) IBOutlet UILabel *fromToLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLable;
@property (weak, nonatomic) IBOutlet UILabel *fareLabel;
@end

@implementation GoFindRideCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
