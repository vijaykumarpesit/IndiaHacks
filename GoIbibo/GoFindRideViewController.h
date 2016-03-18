//
//  GoFindRideViewController.h
//  GoIbibo
//
//  Created by Vijay on 18/03/16.
//  Copyright © 2016 Vijay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoLocation.h"

@interface GoFindRideViewController : UIViewController

@property (nonatomic, strong) GoLocation *sourceLocation;
@property (nonatomic, strong) GoLocation *destinationLocation;

@end
