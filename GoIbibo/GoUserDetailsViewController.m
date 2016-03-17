//
//  GoUserDetailsViewController.m
//  GoIbibo
//
//  Created by Sachin Vas on 10/17/15.
//  Copyright © 2015 Vijay. All rights reserved.
//

#import "GoUserDetailsViewController.h"
#import "GoUserDetailsCell.h"
#import "GoPaymentConfirmation.h"

@interface GoUserDetailsViewController () <UITableViewDataSource, UITabBarDelegate, UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic, strong) NSMutableDictionary *userDetailsDictionary;
@property (nonatomic, strong) NSArray *userDetialsInfo;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *selectedSeats;
@property (weak, nonatomic) IBOutlet UILabel *busFare;
@property (weak, nonatomic) IBOutlet UISwitch *userPrivacySwitch;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (nonatomic, strong) NSArray *permissions;
@property (nonatomic, assign) BOOL canShareWithFriends;
@end

@implementation GoUserDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    self.userDetialsInfo = @[@"Passenger Name", @"Mobile", @"Seat No."];
    self.userDetailsDictionary = [NSMutableDictionary dictionary];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 70, 0);
    
    [self.tableView registerNib:[UINib nibWithNibName:@"GoUserDetailsCell" bundle:nil] forCellReuseIdentifier:@"GoUserDetailsCellIdentifier"];
    
    NSMutableString *selectedSeats = [NSMutableString string];
    for (int i = 0; i < self.busBookingDetails.count; i++) {
        [self.userDetailsDictionary setObject:[NSMutableDictionary dictionaryWithDictionary:@{self.userDetialsInfo[0]: @"",
                                                self.userDetialsInfo[1]: @"",
                                                self.userDetialsInfo[2]:self.busBookingDetails[i]}]
                                       forKey:self.busBookingDetails[i]];
        [selectedSeats appendFormat:@" %@,",self.busBookingDetails[i]];
    }
    self.selectedSeats.text = [[selectedSeats substringFromIndex:1] substringToIndex:selectedSeats.length-2];
    self.busFare.text = [NSString stringWithFormat:@"\u20B9 %lu", [self.goBusDetails.minimumFare integerValue] * self.busBookingDetails.count];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped:)];

    self.permissions = @[@"None",@"Phonebook",@"Phonebook+FB",@"Public"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.busBookingDetails.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Main Passenger Details";
    }
    return @"Passenger Details";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 77.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    GoUserDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GoUserDetailsCellIdentifier" forIndexPath:indexPath];
    cell.textFieldDescription.text = self.userDetialsInfo[indexPath.row];
    cell.textField.tag = 100 * indexPath.section + indexPath.row;
    cell.textField.text = [[self.userDetailsDictionary valueForKey:[self.busBookingDetails objectAtIndex:indexPath.section]] valueForKey:self.userDetialsInfo[indexPath.row]];
    if (indexPath.row == 2) {
        cell.textField.userInteractionEnabled = NO;
        cell.textField.delegate = nil;
    } else {
        cell.textField.delegate = self;
    }
    return cell;
}

- (void)doneButtonTapped:(id)sender {
    GoPaymentConfirmation *paymentConfirmation = [[GoPaymentConfirmation alloc] initWithBusDetails:self.goBusDetails withSeatNoDictionary:self.userDetailsDictionary];
    paymentConfirmation.shouldSend =  self.canShareWithFriends;
    [self.navigationController pushViewController:paymentConfirmation animated:YES];
}

- (IBAction)flip:(id)sender {
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSInteger section = textField.tag / 100;
    NSInteger row = textField.tag % 100;
    NSMutableDictionary *dict = [self.userDetailsDictionary valueForKey:[self.busBookingDetails objectAtIndex:section]];
    [dict setObject:textField.text forKey:[self.userDetialsInfo objectAtIndex:row]];
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
    
    return CGSizeMake(self.pickerView.bounds.size.width, 60.0f);
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (void)pickerView:(UIPickerView *)pV didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.canShareWithFriends = (row !=0);
}
@end
