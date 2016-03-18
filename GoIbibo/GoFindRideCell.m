//
//  GoFindRideCell.m
//  GoIbibo
//
//  Created by Vijay on 18/03/16.
//  Copyright © 2016 Vijay. All rights reserved.
//

#import "GoFindRideCell.h"

@interface GoFindRideCell ()


@end

@implementation GoFindRideCell

- (void)awakeFromNib {
    
    [self.fareLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
    [self.fromToLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
    [self.timeLable setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
    [self.nameLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
