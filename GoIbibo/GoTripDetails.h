//
//  GoTripDetails.h
//  GoIbibo
//
//  Created by Vijay on 18/03/16.
//  Copyright © 2016 Vijay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoLocation.h"

@interface GoTripDetails : NSObject
@property (nonatomic, strong) GoLocation *fromLocation;
@property (nonatomic, strong) GoLocation *toLocation;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, strong) NSNumber *seatFare;
@property (nonatomic, strong) NSString *driverMSISDN;
@property (nonatomic, strong) NSNumber *numberOfSeats;
@property (nonatomic, strong) NSNumber *numberOfKg;
@property (nonatomic, strong) NSNumber *luggageFare;
@property (nonatomic, strong) NSMutableArray *mapPointsArray;
@property (nonatomic, strong) NSNumber *isInLongTripMode;
@end
