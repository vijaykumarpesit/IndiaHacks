//
//  GoLocation.h
//  GoIbibo
//
//  Created by Vijay on 17/03/16.
//  Copyright © 2016 Vijay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface GoLocation : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) NSString *formattedAddress;

@end
