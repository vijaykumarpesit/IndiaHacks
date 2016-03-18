//
//  ViewController.m
//  GoIbibo
//
//  Created by Vijay on 22/09/15.
//  Copyright © 2015 Vijay. All rights reserved.
//

#import "GoHomeViewController.h"
#import "GoLayoutHandler.h"
#import "GoBusListViewController.h"
#import "GoUserModelManager.h"
#import "GoUser.h"
#import "GoSearchPlaceViewController.h"
#import "GoIbibo-swift.h"
#import "GoMapCell.h"
#import "GoLocation.h"
#import "GoRouteViewController.h"

@import GoogleMaps;



@interface GoHomeViewController () <MKMapViewDelegate,CLLocationManagerDelegate>

@property (nonatomic, strong) NSMutableDictionary *eventsByDate;
@property (nonatomic, strong) NSDate *todayDate;
@property (nonatomic, strong) NSDate *minDate;
@property (nonatomic, strong) NSDate *maxDate;
@property (nonatomic, strong) NSDate *dateSelected;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UIView *sourceView;
@property (weak, nonatomic) IBOutlet UIView *destinationView;
@property (weak, nonatomic) IBOutlet UILabel *searchBusesLabel;
@property (weak, nonatomic) IBOutlet IGSwitch *typeSelectionSwitch;
@property (weak, nonatomic) IBOutlet UITableView *optionTableView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL isInLongTripMode;
@property (nonatomic, strong) GoLocation *sourceLocation;
@property (nonatomic, strong) GoLocation *destinationLocation;


@property (weak, nonatomic) IBOutlet UIView *offerRide;

@property (weak, nonatomic) IBOutlet UIView *buttonsView;
@property (weak, nonatomic) IBOutlet UIView *findRide;

@end

@implementation GoHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isInLongTripMode = YES;

    self.title = @"Go Buddies";
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left-side-bar-hamburger.png"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemPressed:)];
    _calendarManager = [JTCalendarManager new];
    _calendarManager.delegate = self;
    
    [self.optionTableView registerNib:[UINib nibWithNibName:@"GoMapCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cellID"];

    
    // Generate random events sort by date using a dateformatter for the demonstration
    [self createRandomEvents];
    
    // Create a min and max date for limit the calendar, optional
    [self createMinAndMaxDate];
    
    [_calendarManager setMenuView:_calendarMenuView];
    [_calendarManager setContentView:_calendarContentView];
    [_calendarManager setDate:_todayDate];

    
    [self configureAndAddTapGestureToView:self.sourceView andSelector:@selector(sourceViewTapped:)];
    self.sourceView.userInteractionEnabled = YES;
    [self configureAndAddTapGestureToView:self.destinationView andSelector:@selector(destinationViewTapped:)];
    self.destinationView.userInteractionEnabled = YES;
    [self configureAndAddTapGestureToView:self.searchBusesLabel andSelector:@selector(searchBusesLabelTapped:)];
    self.searchBusesLabel.userInteractionEnabled = YES;
    
    [self didChangeModeTouch];
    
    
    
    self.typeSelectionSwitch.titleLeft = @"Long Journey";
    self.typeSelectionSwitch.titleRight = @"Short Journey";
    self.typeSelectionSwitch.cornerRadius = 0.0f;
    self.typeSelectionSwitch.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
    self.typeSelectionSwitch.sliderColor = [UIColor colorWithRed:100/255.0 green:177/255.0 blue:185/255.0 alpha:1.0];
    self.typeSelectionSwitch.textColorFront = [UIColor whiteColor];
    self.typeSelectionSwitch.textColorBack = [UIColor whiteColor];
    [self.typeSelectionSwitch addTarget:self action:@selector(journeyTypeChanged:) forControlEvents:UIControlEventValueChanged];
    
    UIGestureRecognizer *offeresture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(offerRideAndService)];
    [self.offerRide addGestureRecognizer:offeresture];
    [self.offerRide setUserInteractionEnabled:YES];
    
    UIGestureRecognizer *findgesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(findRideAndService)];
    [self.findRide addGestureRecognizer:findgesture];
    [self.findRide setUserInteractionEnabled:YES];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self.typeSelectionSwitch setFrame:CGRectMake(20, self.typeSelectionSwitch.frame.origin.y, self.view.bounds.size.width - 40, 40)];
    
}

- (void)configureAndAddTapGestureToView:(UIView *)view andSelector:(SEL)selector {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:selector];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    [view addGestureRecognizer:tapGestureRecognizer];
}


#pragma mark - Buttons callback

- (IBAction)didGoTodayTouch
{
    [_calendarManager setDate:_todayDate];
}

- (IBAction)didChangeModeTouch
{
    _calendarManager.settings.weekModeEnabled = !_calendarManager.settings.weekModeEnabled;
    [_calendarManager reload];
    
    CGFloat newHeight = 300;
    [self.view bringSubviewToFront:self.overlayView];
    self.overlayView.userInteractionEnabled = NO;
    self.overlayView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0f];
    if(_calendarManager.settings.weekModeEnabled){
        newHeight = 85.;
        self.overlayView.backgroundColor = [UIColor clearColor];
        [self.view sendSubviewToBack:self.overlayView];
        self.overlayView.userInteractionEnabled = YES;
    }
    [UIView animateWithDuration:0.2f animations:^{
        self.calendarContentViewHeight.constant = newHeight;
        [self.view layoutIfNeeded];
    }];
}

- (void)sourceViewTapped:(id)sender {
    [self presentSearchPlaceViewControllerIsForSourcePlace:YES];
}

- (void)presentSearchPlaceViewControllerIsForSourcePlace:(BOOL)isSourcePlace {
    GoSearchPlaceViewController *gosearchPlaceViewController = [[GoSearchPlaceViewController alloc] initWithNibName:@"GoSearchPlaceViewController" bundle:nil];
    gosearchPlaceViewController.isSourcePlace = isSourcePlace;
    gosearchPlaceViewController.updateSelectedPlace = ^void(GoLocation *location){
        if (location) {
            if (isSourcePlace) {
                self.sourceLocation = location;
            } else {
                self.destinationLocation = location;
                
            }
        }
        [self.optionTableView reloadData];
    };
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:gosearchPlaceViewController];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)destinationViewTapped:(id)sender {
    [self presentSearchPlaceViewControllerIsForSourcePlace:NO];
}

- (void)findRideTapped {
    NSString *source = self.sourceLocation.name.lowercaseString;
    NSString *destination = self.destinationLocation.name.lowercaseString;
    
    if (self.isInLongTripMode) {
        GoBusListViewController *vc = [[GoBusListViewController alloc] initWithSource:source destination:destination departureDate:(_dateSelected ? _dateSelected : _todayDate) arrivalDate:nil];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        GoRouteViewController *routeVC = [[GoRouteViewController alloc] initWithNibName:@"GoRouteViewController" bundle:nil];
        routeVC.sourceLocation = self.sourceLocation;
        routeVC.destinationLocation = self.destinationLocation;
        [self.navigationController pushViewController:routeVC animated:YES];
        
    }
}

- (void)offerRideAndService {
    
    
}

- (void)findRideAndService {
    
    [self findRideTapped];
}

- (IBAction)journeyTypeChanged:(id)sender {
    self.isInLongTripMode = (self.typeSelectionSwitch.selectedIndex == 0);
    self.sourceLocation = nil;
    self.destinationLocation = nil;
    [self.optionTableView reloadData];
}



#pragma mark - CalendarManager delegate

// Exemple of implementation of prepareDayView method
// Used to customize the appearance of dayView
- (void)calendar:(JTCalendarManager *)calendar prepareDayView:(JTCalendarDayView *)dayView
{
    // Today
    if([_calendarManager.dateHelper date:[NSDate date] isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor whiteColor];
        dayView.dotView.backgroundColor = [UIColor colorWithWhite:0.4f alpha:0.3f];
        dayView.textLabel.textColor = [UIColor colorWithRed:1.0f green:(130.0f/255.0f) blue:(125.0f/255.0f) alpha:1.0f];
    }
    // Selected date
    else if(_dateSelected && [_calendarManager.dateHelper date:_dateSelected isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor redColor];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Other month
    else if(![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:dayView.date]){
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor redColor];
        dayView.textLabel.textColor = [UIColor colorWithWhite:1.0f alpha:0.4f];
    }
    // Another day of the current month
    else{
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor redColor];
        dayView.textLabel.textColor = [UIColor blackColor];
    }
    
    if([self haveEventForDay:dayView.date]){
        dayView.dotView.hidden = NO;
    }
    else{
        dayView.dotView.hidden = YES;
    }
}

- (void)calendar:(JTCalendarManager *)calendar didTouchDayView:(JTCalendarDayView *)dayView
{
    _dateSelected = dayView.date;
    
    // Animation for the circleView
    dayView.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    [UIView transitionWithView:dayView
                      duration:.3
                       options:0
                    animations:^{
                        dayView.circleView.transform = CGAffineTransformIdentity;
                        [_calendarManager reload];
                    } completion:nil];
    
    
    // Load the previous or next page if touch a day from another month
    
    if(![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:dayView.date]){
        if([_calendarContentView.date compare:dayView.date] == NSOrderedAscending){
            [_calendarContentView loadNextPageWithAnimation];
        }
        else{
            [_calendarContentView loadPreviousPageWithAnimation];
        }
    }
}

#pragma mark - CalendarManager delegate - Page mangement

// Used to limit the date for the calendar, optional
- (BOOL)calendar:(JTCalendarManager *)calendar canDisplayPageWithDate:(NSDate *)date
{
    return [_calendarManager.dateHelper date:date isEqualOrAfter:_minDate andEqualOrBefore:_maxDate];
}

- (void)calendarDidLoadNextPage:(JTCalendarManager *)calendar
{
    //    NSLog(@"Next page loaded");
}

- (void)calendarDidLoadPreviousPage:(JTCalendarManager *)calendar
{
    //    NSLog(@"Previous page loaded");
}

#pragma mark - Fake data

- (void)createMinAndMaxDate
{
    _todayDate = [NSDate date];
    
    // Min date will be 2 month before today
    _minDate = [_calendarManager.dateHelper addToDate:_todayDate months:-2];
    
    // Max date will be 2 month after today
    _maxDate = [_calendarManager.dateHelper addToDate:_todayDate months:2];
}

// Used only to have a key for _eventsByDate
- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"dd-MM-yyyy";
    }
    
    return dateFormatter;
}

- (BOOL)haveEventForDay:(NSDate *)date
{
    NSString *key = [[self dateFormatter] stringFromDate:date];
    
    if(_eventsByDate[key] && [_eventsByDate[key] count] > 0){
        return YES;
    }
    
    return NO;
    
}

- (void)createRandomEvents
{
    _eventsByDate = [NSMutableDictionary new];
    
    for(int i = 0; i < 30; ++i){
        // Generate 30 random dates between now and 60 days later
        NSDate *randomDate = [NSDate dateWithTimeInterval:(rand() % (3600 * 24 * 60)) sinceDate:[NSDate date]];
        
        // Use the date as key for eventsByDate
        NSString *key = [[self dateFormatter] stringFromDate:randomDate];
        
        if(!_eventsByDate[key]){
            _eventsByDate[key] = [NSMutableArray new];
        }
        
        [_eventsByDate[key] addObject:randomDate];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)leftBarButtonItemPressed:(id)sender {
    [[[GoLayoutHandler sharedInstance] sideMenu] presentLeftMenuViewController];
}

-(void)digitsAuthenticationFinishedWithSession:(DGTSession *)aSession error:(NSError *)error {
    
    GoUser *user = [[GoUserModelManager sharedManager] currentUser];
    NSMutableString *phoneNo = [NSMutableString stringWithString:aSession.phoneNumber];
    user.phoneNumber =  [phoneNo substringFromIndex:3];
    user.userID = aSession.userID;
    [user saveUser];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return  (tableView.bounds.size.height -20)/2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GoMapCell *mapCell = [tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    MKCoordinateRegion region = { {0.0, 0.0 }, { 0.0, 0.0 } };
    
    if (indexPath.section == 0) {
        mapCell.optionLabel.text = @"Source";
        
        GoLocation *sourceLoc = self.sourceLocation;
        if (!sourceLoc) {
            sourceLoc = [self defaultSourceLocation];
            self.sourceLocation = sourceLoc;
        }
        
        region.center.latitude = sourceLoc.location.coordinate.latitude;
        region.center.longitude = sourceLoc.location.coordinate.longitude;
        
        CGFloat delta = 0.05f;
        if (!self.isInLongTripMode) {
            delta = 0.005f;
        }
        region.span.longitudeDelta = delta;
        region.span.latitudeDelta = delta;
        
        CLLocation *theLocation = [[CLLocation alloc]initWithLatitude:region.center.latitude longitude:region.center.longitude];
        [point setCoordinate:(theLocation.coordinate)];
        [mapCell setLocation:theLocation];
        mapCell.optionValueLabel.text = sourceLoc.name;
    } else {
        
        GoLocation *destLoc = self.destinationLocation;
        if (!destLoc) {
            destLoc = [self defaultDestLocation];
            self.destinationLocation = destLoc;
        }
        mapCell.optionLabel.text = @"Destination";
        region.center.latitude = destLoc.location.coordinate.latitude;
        region.center.longitude = destLoc.location.coordinate.longitude;
        CGFloat delta = 0.05f;
        if (!self.isInLongTripMode) {
            delta = 0.005f;
        }
        region.span.longitudeDelta = delta;
        region.span.latitudeDelta = delta;
        CLLocation *theLocation = [[CLLocation alloc]initWithLatitude:region.center.latitude longitude:region.center.longitude];
        [point setCoordinate:(theLocation.coordinate)];
        [mapCell setLocation:theLocation];
        mapCell.optionValueLabel.text = destLoc.name;
        mapCell.optionValueLabel.textColor = [UIColor colorWithRed:1.0 green:0 blue:0 alpha:0.8
                                              ];
        
    }
    
    
    
    [mapCell.mapView addAnnotation:point];
    [mapCell.mapView setMapType:MKMapTypeStandard];
    [mapCell.mapView setZoomEnabled:YES];
    [mapCell.mapView setScrollEnabled:YES];
    [mapCell.mapView setRegion:region animated:YES];
    [mapCell.mapView setScrollEnabled:NO];
    return mapCell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (self.isInLongTripMode) {
        
        if (indexPath.section == 0) {
            [self presentSearchPlaceViewControllerIsForSourcePlace:YES];
        } else {
            [self presentSearchPlaceViewControllerIsForSourcePlace:NO];
        }
    } else  {
        
        MKCoordinateRegion region = { {0.0, 0.0 }, { 0.0, 0.0 } };

        if (indexPath.section == 0) {
            GoLocation *sourceLoc = self.sourceLocation;
            region.center.latitude = sourceLoc.location.coordinate.latitude;
            region.center.longitude = sourceLoc.location.coordinate.longitude;
        } else  {
            GoLocation *destinatioLoc = self.destinationLocation;
            region.center.latitude = destinatioLoc.location.coordinate.latitude;
            region.center.longitude = destinatioLoc.location.coordinate.longitude;
        }
 
        CLLocationCoordinate2D center = region.center;
        CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001);
        CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001);
        
        
        GMSCoordinateBounds *viewport = [[GMSCoordinateBounds alloc] initWithCoordinate:northEast
                                                                             coordinate:southWest];
        GMSPlacePickerConfig *config = [[GMSPlacePickerConfig alloc] initWithViewport:viewport];
        GMSPlacePicker *placePicker = [[GMSPlacePicker alloc] initWithConfig:config];
        
        [placePicker pickPlaceWithCallback:^(GMSPlace *place, NSError *error) {
            if (error != nil) {
                NSLog(@"Pick Place error %@", [error localizedDescription]);
                return;
            }
            
            if (place != nil) {
                GoLocation *goLoc = [[GoLocation alloc] init];
                goLoc.name = place.name;
                goLoc.formattedAddress = place.formattedAddress;
                goLoc.location = [[CLLocation alloc] initWithLatitude:place.coordinate.latitude longitude:place.coordinate.longitude];
                if (indexPath.section == 0) {
                    self.sourceLocation = goLoc;
                } else {
                    self.destinationLocation = goLoc;
                }
                NSLog(@"Place address %@", place.formattedAddress);
                NSLog(@"Place attributions %@", place.attributions.string);
            } else {
                NSLog(@"No place selected");
            }
            
            [self.optionTableView reloadData];
        }];
        
        
    }
    
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    [self.locationManager stopUpdatingLocation];
    [self.optionTableView reloadData];
    
}


- (GoLocation *)defaultSourceLocation {
    
    GoLocation *location = [[GoLocation alloc] init];

    if (self.isInLongTripMode) {
        location.name = @"Bengaluru";
        location.location = [[CLLocation alloc] initWithLatitude:12.9667f longitude:77.5667f];
        
    } else {
        location.location = [[self locationManager] location];
    }
    return location;
}


- (GoLocation *)defaultDestLocation {
    
    GoLocation *location = [[GoLocation alloc] init];
    
    if (self.isInLongTripMode) {
        location.name = @"Sirsi";
        location.location = [[CLLocation alloc] initWithLatitude:14.6195f longitude:74.8354f];
        
    } else {
        location.location = [[self locationManager] location];
    }
    return location;
}


@end
