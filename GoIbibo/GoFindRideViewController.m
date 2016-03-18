//
//  GoFindRideViewController.m
//  GoIbibo
//
//  Created by Vijay on 18/03/16.
//  Copyright © 2016 Vijay. All rights reserved.
//

#import "GoFindRideViewController.h"

@interface GoFindRideViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *tripDetails;
@property (weak, nonatomic) IBOutlet UILabel *selectPermissionLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectTimeLabel;
@property (nonatomic, strong) NSArray *permissions;
@property (weak, nonatomic) IBOutlet UIPickerView *permissionPicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation GoFindRideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"GoFindRideCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    self.tripDetails = [[NSMutableArray alloc] init];
    self.permissions = @[@"None",@"Phonebook",@"Phonebook+FB",@"Public"];
    
    [self.selectPermissionLabel setFont:[UIFont fontWithName:@"Helvetica" size:17]];
    [self.selectTimeLabel setFont:[UIFont fontWithName:@"Helvetica" size:17]];
    
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
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
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

}


@end
