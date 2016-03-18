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
@end

@implementation GoFindRideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"GoFindRideCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    self.tripDetails = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
