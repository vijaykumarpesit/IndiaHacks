//
//  GoRouteViewController.m
//  GoIbibo
//
//  Created by Vijay on 17/03/16.
//  Copyright © 2016 Vijay. All rights reserved.
//

#import "GoRouteViewController.h"
#import "GoIbibo-swift.h"

@interface GoRouteViewController ()

@property (weak, nonatomic) IBOutlet IGSwitch *rideServiceSwitch;
@property (weak, nonatomic) IBOutlet UIPickerView *permissionPicker;
@property (weak, nonatomic) IBOutlet UIButton *bookButton;
@property (weak, nonatomic) IBOutlet UILabel *shareWithFriend;
@property (weak, nonatomic) IBOutlet UILabel *seatFare;
@property (weak, nonatomic) IBOutlet UILabel *numberOfSeets;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (assign, nonatomic) BOOL isInFindRideMode;
@property (nonatomic, strong) NSArray *permissions;

@end

@implementation GoRouteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
     
        self.numberOfSeets.text  = @"Availble Seats";
        self.seatFare.text = @"Seat Fare";
    } else {
        self.numberOfSeets.text  = @"Luggage in KGs";
        self.seatFare.text = @"Fare";
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
}

@end
