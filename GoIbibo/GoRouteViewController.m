//
//  GoRouteViewController.m
//  GoIbibo
//
//  Created by Vijay on 17/03/16.
//  Copyright © 2016 Vijay. All rights reserved.
//

#import "GoRouteViewController.h"

@interface GoRouteViewController ()

@end

@implementation GoRouteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Calulate zoom dynamically
    CLLocationCoordinate2D center = self.sourceLocation.location.coordinate;
    self.mapView.myLocationEnabled = YES;
    self.mapView.camera = [[GMSCameraPosition alloc] initWithTarget:center zoom:13 bearing:0 viewingAngle:0];;
    [self drawRoute];
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


@end
