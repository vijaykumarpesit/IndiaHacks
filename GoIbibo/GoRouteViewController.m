//
//  GoRouteViewController.m
//  GoIbibo
//
//  Created by Vijay on 17/03/16.
//  Copyright © 2016 Vijay. All rights reserved.
//

#import "GoRouteViewController.h"
#import "GoIbibo-swift.h"
#import "GoTripDetails.h"
#import <Parse/Parse.h>
#import "GoUserModelManager.h"
#import "MBProgressHUD.h"

@interface GoRouteViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet IGSwitch *rideServiceSwitch;
@property (weak, nonatomic) IBOutlet UIPickerView *permissionPicker;
@property (weak, nonatomic) IBOutlet UIButton *bookButton;
@property (weak, nonatomic) IBOutlet UILabel *shareWithFriend;
@property (weak, nonatomic) IBOutlet UILabel *seatFare;
@property (weak, nonatomic) IBOutlet UILabel *numberOfSeets;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (assign, nonatomic) BOOL isInFindRideMode;
@property (nonatomic, strong) NSArray *permissions;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITextField *enterFareTextField;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIStepper *countStepper;
@property (assign, nonatomic)  NSUInteger *seatCount;
@property (nonatomic, assign) NSUInteger selectedPermissionIndex;
@property (nonatomic, strong) NSMutableArray *lattitudeArray;
@property (nonatomic, strong) NSMutableArray *longitudeArray;
@property (nonatomic, strong) NSMutableArray *pointsArray;


@end

@implementation GoRouteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isInFindRideMode = YES;
    
    //Calulate zoom dynamically
    CLLocationCoordinate2D center = self.sourceLocation.location.coordinate;
    self.mapView.myLocationEnabled = YES;
    self.mapView.camera = [[GMSCameraPosition alloc] initWithTarget:center zoom:13 bearing:0 viewingAngle:0];;
    [self drawRoute];
    
    
    self.rideServiceSwitch.titleLeft = @"Ride";
    self.rideServiceSwitch.titleRight = @"Service";
    self.rideServiceSwitch.cornerRadius = 0.0f;
    self.rideServiceSwitch.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
    self.rideServiceSwitch.sliderColor = [UIColor colorWithRed:100/255.0 green:177/255.0 blue:185/255.0 alpha:1.0];
    self.rideServiceSwitch.textColorFront = [UIColor whiteColor];
    self.rideServiceSwitch.textColorBack = [UIColor whiteColor];
    
    self.permissions = @[@"None",@"Phonebook",@"Phonebook+FB",@"Public"];
    
    self.shareWithFriend.text = @"Share with Friends";
    [self toggleRideService];
    
    [self.datePicker setValue:[UIColor whiteColor] forKeyPath:@"textColor"];
    SEL selector = NSSelectorFromString(@"setHighlightsToday:");
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDatePicker instanceMethodSignatureForSelector:selector]];
    BOOL no = NO;
    [invocation setSelector:selector];
    [invocation setArgument:&no atIndex:2];
    [invocation invokeWithTarget:self.datePicker];
    

    [self.seatFare setFont:[UIFont fontWithName:@"Helvetica" size:17]];
    [self.numberOfSeets setFont:[UIFont fontWithName:@"Helvetica" size:17]];
    [self.shareWithFriend setFont:[UIFont fontWithName:@"Helvetica" size:17]];
    self.enterFareTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter Fare" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [self.countLabel setText:@"1"];
    self.countStepper.value = 1.0f;
    
    self.date = [self dateAfterStrippingDayAndTimeComponentsWithCalendar:[NSCalendar currentCalendar] fromDate:self.date];
    //NSDate *timeNow = [self dateAfterStrippingDayAndMonthTimeComponentsWithCalendar:[NSCalendar currentCalendar] fromDate:[NSDate date]];
    
    self.datePicker.date = self.date;
    
    self.lattitudeArray = [[NSMutableArray alloc] init];
    self.longitudeArray = [[NSMutableArray alloc] init];
    self.pointsArray = [[NSMutableArray alloc] init];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)drawRoute
{
        [self fetchPolylineWithOrigin:self.sourceLocation.location destination:self.destinationLocation.location completionHandler:^(GMSPolyline *polyline)
         {
             if(polyline)
                 polyline.map = self.mapView;
         }];
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
                                                                 PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:coordiante.latitude longitude:coordiante.longitude];
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

- (IBAction)rideSerivceToggle:(id)sender {

    self.isInFindRideMode = (self.rideServiceSwitch.selectedIndex == 0);
    [self toggleRideService];
}

- (void)toggleRideService {

    if (self.isInFindRideMode) {
        self.numberOfSeets.text  = @"Available Seats";
        self.seatFare.text = @"Seat Fare";
        [self.bookButton setTitle:@"Offer Ride" forState:UIControlStateNormal];
    } else {
        self.numberOfSeets.text  = @"Luggage in KG";
        self.seatFare.text = @"Fare";
        [self.bookButton setTitle:@"Offer Service" forState:UIControlStateNormal];

    }
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
        [tView setFont:[UIFont fontWithName:@"Helvetica" size:17]];
        [tView setTextAlignment:NSTextAlignmentCenter];
        [tView setTextColor:[UIColor whiteColor]];
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
}

- (IBAction)dateChanged:(id)sender {

}

- (IBAction)countValueChanged:(id)sender {

    UIStepper *stepper = (UIStepper *)sender;
    double value = stepper.value;
    
    [self.countLabel setText:[NSString stringWithFormat:@"%d", (int)value]];
}

- (IBAction)submitClicked:(id)sender {

    PFObject * tripDetails = [PFObject objectWithClassName:@"GoTripDetails"];
    
    tripDetails[@"sourceLattitude"] = @(self.sourceLocation.location.coordinate.latitude);
    tripDetails[@"sourceLongitude"] = @(self.sourceLocation.location.coordinate.longitude);

    
    tripDetails[@"destinationLattitude"] = @(self.destinationLocation.location.coordinate.latitude);
    tripDetails[@"destinationLongitude"] = @(self.destinationLocation.location.coordinate.longitude);

    
    if (self.sourceLocation.name) {
        tripDetails[@"sourcePlaceName"] = self.sourceLocation.name;

    }
    if (self.destinationLocation.name) {
        tripDetails[@"destinationPlaceName"] = self.destinationLocation.name;

    }
    
    tripDetails[@"msisdn"] = @"996499396";//[[[GoUserModelManager sharedManager] currentUser] phoneNumber];
    
    if (self.numberOfSeets.text.length >0) {
        tripDetails[@"numberOfSeats"] = self.numberOfSeets.text;
   
    }
    if (self.enterFareTextField.text.length >0) {
        tripDetails[@"fare"] = self.enterFareTextField.text;
   
    }
    
    if (self.datePicker.date) {
        tripDetails[@"tripDate"] = self.datePicker.date;

    }
    
    tripDetails[@"isInRideMode"] = @(self.isInFindRideMode);
    tripDetails [@"sharePermissions"] = @(self.selectedPermissionIndex);
    
//    if (self.lattitudeArray.count >0) {
//        tripDetails[@"lattitudeArray"] = self.lattitudeArray;
//
//    }
//    
//    if (self.longitudeArray.count >0) {
//        tripDetails[@"longitudeArray"] = self.lattitudeArray;
//        
//    }
//    
   
    if (self.pointsArray.count >0) {
        tripDetails [@"pointsArray"] = self.pointsArray;
  
    }
    
    [tripDetails saveInBackground];
    
    MBProgressHUD *HUDView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUDView.mode = MBProgressHUDModeIndeterminate;
    HUDView.labelText = @"Processing...";
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        MBProgressHUD *HUDViewCompleted = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUDViewCompleted.mode = MBProgressHUDModeCustomView;
        HUDViewCompleted.labelText = @"Completed";
        HUDViewCompleted.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark.png"]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    });

}


- (NSDate *)dateAfterStrippingDayAndTimeComponentsWithCalendar:(NSCalendar *)calendar fromDate:(NSDate *)fromDate {
    NSDateComponents *comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit
                                          fromDate:fromDate];
    return [calendar dateFromComponents:comps];
}



- (NSDate *)dateAfterStrippingDayAndMonthTimeComponentsWithCalendar:(NSCalendar *)calendar fromDate:(NSDate *)fromDate {
    NSDateComponents *comps = [calendar components:NSHourCalendarUnit | NSMinuteCalendarUnit
                                          fromDate:fromDate];
    return [calendar dateFromComponents:comps];
}

//Apply this logic later

//- (NSDate *)dateAfterAdding

@end
