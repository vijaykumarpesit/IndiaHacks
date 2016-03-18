//
//  GoFindRideViewController.m
//  GoIbibo
//
//  Created by Vijay on 18/03/16.
//  Copyright © 2016 Vijay. All rights reserved.
//

#import "GoFindRideViewController.h"
#import <Parse/Parse.h>
#import "GoUserModelManager.h"
#import "GoTripDetails.h"
#import "GoFindRideCell.h"
#import "GoContactSync.h"
#import "GoContactSyncEntry.h"

@import GoogleMaps;

@interface GoFindRideViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *tripDetails;
@property (weak, nonatomic) IBOutlet UILabel *selectPermissionLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectTimeLabel;
@property (nonatomic, strong) NSArray *permissions;
@property (weak, nonatomic) IBOutlet UIPickerView *permissionPicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, assign) NSUInteger selectedPermissionIndex;
@property (nonatomic, strong) NSMutableArray *lattitudeArray;
@property (nonatomic, strong) NSMutableArray *longitudeArray;
@property (nonatomic, strong) NSMutableArray *pointsArray;


@end

@implementation GoFindRideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"GoFindRideCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    self.tripDetails = [[NSMutableArray alloc] init];
    self.permissions = @[@"None",@"Phonebook",@"Phonebook+FB",@"Public"];
    
    [self.selectPermissionLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];
    [self.selectTimeLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];
    
    self.lattitudeArray = [[NSMutableArray alloc] init];
    self.longitudeArray = [[NSMutableArray alloc] init];
    self.pointsArray = [[NSMutableArray alloc] init];
    
    [self fetchPolylineWithOrigin:self.sourceLocation.location destination:self.destinationLocation.location completionHandler:^(GMSPolyline * polyLine) {
        [self seacrhRides];
    }];
    
    
    
//    [self.datePicker setValue:[UIColor whiteColor] forKeyPath:@"textColor"];
//    SEL selector = NSSelectorFromString(@"setHighlightsToday:");
//    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDatePicker instanceMethodSignatureForSelector:selector]];
//    BOOL no = NO;
//    [invocation setSelector:selector];
//    [invocation setArgument:&no atIndex:2];
//    [invocation invokeWithTarget:self.datePicker];
//    


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tripDetails.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GoFindRideCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    GoTripDetails *details = [self.tripDetails objectAtIndex:indexPath.row];
    cell.fareLabel.text = [NSString stringWithFormat:@"%@ rupees",details.seatFare];
    cell.fromToLabel.text = [NSString stringWithFormat:@"%@ --> %@",details.fromLocation.name,details.toLocation.name];
    
    NSString *dateString = [NSDateFormatter localizedStringFromDate:details.timestamp
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterShortStyle];
    cell.timeLable.text = dateString;
    GoContactSyncEntry *entry =[[[GoContactSync sharedInstance] syncedContacts] valueForKey:details.driverMSISDN];
    cell.nameLabel.text = entry.name;
    
    return cell;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    return self.permissions.count;
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* tView = (UILabel*)view;
    if (!tView)
    {
        tView = [[UILabel alloc] init];
        [tView setFont:[UIFont fontWithName:@"Helvetica" size:14]];
        [tView setTextAlignment:NSTextAlignmentCenter];
    }
    // Fill the label text here
    tView.text=[self.permissions objectAtIndex:row];
    return tView;
}


- (CGSize)rowSizeForComponent:(NSInteger)component {
    
    return CGSizeMake(self.permissionPicker.bounds.size.width, 60.0f);
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}



- (void)pickerView:(UIPickerView *)pV didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selectedPermissionIndex = row;
}

- (void)seacrhRides {
    
    //Forgetting about service mode right now
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        PFQuery *query = [PFQuery queryWithClassName:@"GoTripDetails"];
        [query whereKey:@"tripDate" lessThanOrEqualTo:[NSDate date]];
        //[query whereKey:@"sharePermissions" greaterThanOrEqualTo:@(1)];
        
        
        
        NSString *myNumber = [[[GoUserModelManager sharedManager] currentUser] phoneNumber];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            
            for (PFObject *object in objects) {
                NSArray *points = object[@"pointsArray"];
                if ([self isMatchingPointsFound:points]) {
                    
                    GoTripDetails *details = [[GoTripDetails alloc] init];
                    details.seatFare =  object[@"fare"];
                    GoLocation *fromLocation = [[GoLocation alloc] init];
                    CGFloat srcLatitude = [object[@"sourceLattitude"] floatValue];
                    CGFloat srcLongitude = [object[@"sourceLongitude"] floatValue];
                    fromLocation.location = [[CLLocation alloc] initWithLatitude:srcLatitude longitude:srcLongitude];
                    fromLocation.name = object[@"sourcePlaceName"];
                    
                    GoLocation *toLocation = [[GoLocation alloc] init];
                    CGFloat dstLatitude = [object[@"destinationLattitude"] floatValue];
                    CGFloat dstLongitude = [object[@"destinationLongitude"] floatValue];
                    toLocation.location = [[CLLocation alloc] initWithLatitude:dstLatitude longitude:dstLongitude];
                    toLocation.name = object[@"destinationPlaceName"];
                    
                    details.fromLocation = fromLocation;
                    details.toLocation = toLocation;
                    details.driverMSISDN = object[@"msisdn"];
                    details.numberOfSeats = object[@"numberOfSeats"];
                    details.timestamp = object[@"tripDate"];
                    
                    [self.tripDetails addObject:details];
                    
                    
                    
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    });
    
}

- (void)fetchPolylineWithOrigin:(CLLocation *)origin destination:(CLLocation *)destination completionHandler:(void (^)(GMSPolyline *))completionHandler
{
    NSString *originString = [NSString stringWithFormat:@"%f,%f", origin.coordinate.latitude, origin.coordinate.longitude];
    NSString *destinationString = [NSString stringWithFormat:@"%f,%f", destination.coordinate.latitude, destination.coordinate.longitude];
    NSString *directionsAPI = @"https://maps.googleapis.com/maps/api/directions/json?";
    NSString *directionsUrlString = [NSString stringWithFormat:@"%@&origin=%@&destination=%@&mode=driving", directionsAPI, originString, destinationString];
    NSURL *directionsUrl = [NSURL URLWithString:directionsUrlString];
    
    
    NSURLSessionDataTask *fetchDirectionsTask = [[NSURLSession sharedSession] dataTaskWithURL:directionsUrl completionHandler:
                                                 ^(NSData *data, NSURLResponse *response, NSError *error)
                                                 {
                                                     NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                                     if(error)
                                                     {
                                                         if(completionHandler)
                                                             completionHandler(nil);
                                                         return;
                                                     }
                                                     
                                                     NSArray *routesArray = [json objectForKey:@"routes"];
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         GMSPolyline *polyline = nil;
                                                         if ([routesArray count] > 0)
                                                         {
                                                             NSDictionary *routeDict = [routesArray objectAtIndex:0];
                                                             NSDictionary *routeOverviewPolyline = [routeDict objectForKey:@"overview_polyline"];
                                                             NSString *points = [routeOverviewPolyline objectForKey:@"points"];
                                                             GMSPath *path = [GMSPath pathFromEncodedPath:points];
                                                             
                                                             for (int i =0; i < [path count]; i++) {
                                                                 
                                                                 CLLocationCoordinate2D coordiante = [path coordinateAtIndex:i];
                                                                 //[self.lattitudeArray addObject:@(coordiante.latitude)];
                                                                 //[self.longitudeArray addObject:@(coordiante.longitude)];
                                                                 
                                                                 PFGeoPoint *geoPoint = [PFGeoPoint  geoPointWithLatitude:coordiante.latitude longitude:coordiante.longitude];
                                                                 [self.pointsArray addObject:geoPoint];
                                                                 
                                                                 NSLog(@"%f , %f", coordiante.latitude,coordiante.longitude);
                                                             }
                                                             
                                                             polyline = [GMSPolyline polylineWithPath:path];
                                                         }
                                                         
                                                         if(completionHandler)
                                                             completionHandler(polyline);
                                                     });
                                                     
                                                 }];
    [fetchDirectionsTask resume];
}

- (BOOL)isMatchingPointsFound:(NSArray *)array {
    
    BOOL isFound = NO;
    
    for (PFGeoPoint *point in array) {
        
        for (PFGeoPoint *localPoint in self.pointsArray) {
            
            if ([point distanceInKilometersTo:localPoint] <= 0.1) {
                return YES;
            }
        }
    }
    
    return isFound;
    
}


@end
