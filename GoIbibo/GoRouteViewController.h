//
//  GoRouteViewController.h
//  GoIbibo
//
//  Created by Vijay on 17/03/16.
//  Copyright © 2016 Vijay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoLocation.h"
@import GoogleMaps;

@interface GoRouteViewController : UIViewController

@property (nonatomic, strong) GoLocation *sourceLocation;
@property (nonatomic, strong) GoLocation *destinationLocation;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (nonatomic, strong) NSDate *date;
@end
