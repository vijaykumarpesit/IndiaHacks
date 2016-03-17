//
//  GoUserDetailsViewController.h
//  GoIbibo
//
//  Created by Sachin Vas on 10/17/15.
//  Copyright © 2015 Vijay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GoBusDetails;

@interface GoUserDetailsViewController : UIViewController
@property (nonatomic, strong) NSArray *busBookingDetails;
@property (nonatomic, strong) GoBusDetails *goBusDetails;
@end
