//
//  GoSeatMetrixViewController.m
//  GoIbibo
//
//  Created by Vijay on 24/09/15.
//  Copyright © 2015 Vijay. All rights reserved.
//

#import "GoSeatMetrixViewController.h"
#import "GoSeatCollectionViewCell.h"
#import <AFNetworking/AFNetworking.h>
#import "GoBusSeatLayout.h"
#import "GoPaymentConfirmation.h"
#import "GoSeatSeletionHeaderView.h"
#import "GoUserDetailsViewController.h"
#import "CMPopTipView.h"

@interface GoSeatMetrixViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) NSMutableArray *seats;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UIView *searchingView;
@property (nonatomic, strong) GoBusDetails *busDetails;
@property (nonatomic, strong) NSDictionary *seatNoReservedByFriendDict;
@property (nonatomic, strong) NSMutableArray *selectedSeats;
@property (nonatomic, strong) CMPopTipView *popTip;

@end

@implementation GoSeatMetrixViewController

- (instancetype)initWithBusDetails:(GoBusDetails *)busDetails seatNoReservedByFriendDict:(NSDictionary *)seatNoDict {

    self = [super initWithNibName:@"GoSeatMetrixViewController" bundle:nil];
    if (self) {
        self.busDetails = busDetails;
        self.seatNoReservedByFriendDict = seatNoDict;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.seats = [[NSMutableArray alloc] init];
    self.selectedSeats = [NSMutableArray array];
    [self.collectionView registerNib:[UINib nibWithNibName:@"GoSeatCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"busSeatCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"GoSeatSeletionHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    [self loadBusLayoutMetrix];
    [self.collectionView setHidden:YES];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped:)];
    UILongPressGestureRecognizer *longPressRec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    [self.collectionView addGestureRecognizer:longPressRec];
    // Do any additional setup after loading the view.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.seats.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GoSeatCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"busSeatCell" forIndexPath:indexPath];
    GoBusSeatLayout *layout = [self.seats objectAtIndex:indexPath.row];
    cell.seatNo.text = layout.seatNo;
    cell.userInteractionEnabled = YES;
    cell.backgroundImageView.alpha = 1.0f;
    cell.seatNo.alpha = 1.0f;
    
    if(layout.seatNo && [self.seatNoReservedByFriendDict.allKeys containsObject:layout.seatNo]){
        cell.seatNo.text = layout.seatNo;
        cell.backgroundImageView.image = [UIImage imageNamed:@"buddySeat.png"];
        cell.labelCenterXConstrait.constant += (cell.labelCenterXConstrait.constant == 10.0f)? 0.0f : 10.0f;
    } else if (!layout.isSeatAvailable) {
        cell.backgroundImageView.image = [UIImage imageNamed:@"bookedSeat.png"];
        cell.backgroundImageView.alpha = .5f;
        cell.seatNo.alpha = .9f;
    } else if ([self.selectedSeats containsObject:layout.seatNo]) {
        cell.selected = YES;
        cell.backgroundImageView.image = [self tintImage:[UIImage imageNamed:@"availableSeat.png"] withColor:[UIColor colorWithRed:(242.0f/255.0f) green:(245.0f/255.0f) blue:(169.0f/255.0f) alpha:1.0f]];
        cell.backgroundImageView.alpha = .5f;
    } else {
        cell.backgroundImageView.image = [UIImage imageNamed:@"availableSeat.png"];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGRect mainScreenBounds = [[UIScreen mainScreen] bounds];
    return CGSizeMake(mainScreenBounds.size.width/4 -2,
                      mainScreenBounds.size.width/2.5) ;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(collectionView.frame.size.width, 241.0f);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        UICollectionReusableView *reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        return reusableview;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    GoBusSeatLayout *layout = [self.seats objectAtIndex:indexPath.row];
    if ([self.selectedSeats containsObject:layout.seatNo]) {
        [self.selectedSeats removeObject:layout.seatNo];
        dispatch_async(dispatch_get_main_queue(), ^{
            [collectionView reloadData];
        });
    } else if (layout.isSeatAvailable) {
        [self.selectedSeats addObject:layout.seatNo];
        dispatch_async(dispatch_get_main_queue(), ^{
            [collectionView reloadData];
        });
    } else {
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
        NSString *alertControllerTitle = @"Seat Already Booked";
        NSString *alertControllerMessaage = @"Seats which are in orange and blue color is already booked, please select a seat which is in white and black color";
        if (layout.seatNo && [layout.seatNo isEqualToString:@""]) {
            alertControllerTitle = @"Travel with your friend";
            alertControllerMessaage = @"Contact goibibo to travel with your friend.";
        }
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertControllerTitle message:alertControllerMessaage preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self.navigationController presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)loadBusLayoutMetrix {
 
    NSMutableString *urlString = [NSMutableString stringWithString:@"http://developer.goibibo.com/api/bus/seatmap/?app_id=abfac0dc&app_key=5368f504b75224601dccebd153275543&format=json"];
    
    [urlString appendString:[NSString stringWithFormat:@"&skey=%@",self.busDetails.skey]];
    urlString = (NSMutableString *) [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self saveBusSeatLayoutFromResponseObject:responseObject];
        
        if (self.seats.count == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"All seats might have already booked, Please try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        [self.collectionView setHidden:NO];
        [self.searchingView setHidden:YES];
        [self.collectionView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error in Fetching seat matrix" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }];
    
    [operation start];
}

- (void)doneButtonTapped:(id)sender {
    GoUserDetailsViewController *userDetailsVC = [[GoUserDetailsViewController alloc] initWithNibName:@"GoUserDetailsViewController" bundle:nil];
    userDetailsVC.busBookingDetails = self.selectedSeats;
    userDetailsVC.goBusDetails = self.busDetails;
    [self.navigationController pushViewController:userDetailsVC animated:YES];
}

- (void)saveBusSeatLayoutFromResponseObject:(id)responseObject {
    
    NSDictionary *data = [responseObject valueForKey:@"data"];
    NSMutableArray *busSeats = [[data valueForKey:@"onwardSeats"] mutableCopy];
    [busSeats  sortUsingFunction:sortSeatNumber context:NULL];
    
    for(id busSeat in busSeats) {
        GoBusSeatLayout *busSeatLayout = [[GoBusSeatLayout alloc] init];
        busSeatLayout.seatNo = busSeat[@"SeatName"];
        NSNumber *seatStstusValue = busSeat[@"SeatStatus"];
        busSeatLayout.isSeatAvailable = seatStstusValue.boolValue;
        [self.seats addObject:busSeatLayout];
    }
    
    NSLog(@"SuccessFully Parserd and saved the results in correct format");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)longPressed:(UILongPressGestureRecognizer *)gestureReco {
    if (gestureReco.state == UIGestureRecognizerStateBegan) {
        CGPoint  location = [gestureReco locationInView:gestureReco.view];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
        GoBusSeatLayout *layout = [self.seats objectAtIndex:indexPath.row];
        if(layout.seatNo && [self.seatNoReservedByFriendDict.allKeys containsObject:layout.seatNo]){
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            NSString *key = layout.seatNo;
            NSDictionary *dict =  self.seatNoReservedByFriendDict[key];
            self.popTip = [[CMPopTipView alloc] initWithMessage:dict[@"Passenger Name"]];
            [self.popTip presentPointingAtView:cell inView:self.collectionView animated:YES];
        }
    } else if (gestureReco.state == UIGestureRecognizerStateEnded) {
        [self.popTip dismissAnimated:YES];
    }
}

NSComparisonResult sortSeatNumber(id seat1, id seat2, void * context) {
    NSString *seatNo1 = seat1[@"SeatName"];
    NSString *seatNo2 = seat2[@"SeatName"];
    if (seatNo1.length == 2) {
        seatNo1 = [NSString stringWithFormat:@"0%@", seatNo1];
    }
    if (seatNo2.length == 2) {
        seatNo2 = [NSString stringWithFormat:@"0%@", seatNo2];
    }
    return [seatNo1 caseInsensitiveCompare:seatNo2];
}

- (UIImage *)tintImage:(UIImage *)image withColor:(UIColor *)color {
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [color setFill];
    
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // set the blend mode to color burn, and the original image
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextDrawImage(context, rect, image.CGImage);
    
    CGContextClipToMask(context, rect, image.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
}

@end
