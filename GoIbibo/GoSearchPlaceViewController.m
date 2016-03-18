//
//  GoSearchPlaceViewController.m
//  GoIbibo
//
//  Created by Sachin Vas on 9/24/15.
//  Copyright © 2015 Vijay. All rights reserved.
//

#import "GoSearchPlaceViewController.h"
#import "GoLocation.h"

@interface GoSearchPlaceViewController () <UISearchBarDelegate>

@property (nonatomic, strong) GoLocation *selectedPlace;
@property (nonatomic, strong) NSMutableArray *placeArray;
@property (nonatomic, strong) NSMutableArray *searchPlaceArray;
@property (nonatomic) BOOL isSearching;
@property (weak, nonatomic) IBOutlet UISearchBar *seachBar;


@end

@implementation GoSearchPlaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _placeArray = [NSMutableArray array];
    _searchPlaceArray = [NSMutableArray array];
    
    [self addLocationWithName:@"Bangalore" lattitude:12.9667 longitude:77.5667];
    [self addLocationWithName:@"Chennai" lattitude:13.0827 longitude:80.2707];
    [self addLocationWithName:@"Hyderabad" lattitude:17.3700 longitude:78.4800];
    [self addLocationWithName:@"Sirsi" lattitude:14.6195 longitude:74.8354];
    [self addLocationWithName:@"Kollam" lattitude:8.8800 longitude:76.6000];
    [self addLocationWithName:@"Mandya" lattitude:12.5200 longitude:76.9000];
    [self addLocationWithName:@"Mumbai" lattitude:18.9750 longitude:72.8258];
    [self addLocationWithName:@"Pondicherry" lattitude:11.9310 longitude:79.7852];
    [self addLocationWithName:@"Mysore" lattitude:12.9702 longitude:77.5603];
    [self addLocationWithName:@"Hubli" lattitude:15.3617 longitude:75.0850];
    
    self.seachBar.delegate = self;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(rightBarButtonItemPressed:)];
    
}

- (void)addLocationWithName:(NSString *)name lattitude:(CGFloat)lattitude longitude:(CGFloat)longitude {
    GoLocation *location  = [[GoLocation alloc] init];
    location.name = name;
    location.location = [[CLLocation alloc] initWithLatitude:lattitude longitude:longitude];
    [self.placeArray addObject:location];
    
}

- (void)viewWillAppear:(BOOL)animated {
    self.title = self.isSourcePlace ? @"Seach Source Places" : @"Search Destination Places";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)rightBarButtonItemPressed:(id)sender {
    self.updateSelectedPlace(self.selectedPlace);
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isSearching) {
        return self.searchPlaceArray.count;
    }
    return self.placeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchPlace"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SearchPlace"];
    }
    if (self.isSearching) {
        GoLocation *location = self.searchPlaceArray[indexPath.row];
        cell.textLabel.text = location.name;
    } else {
        GoLocation *location = self.placeArray[indexPath.row];
        cell.textLabel.text = location.name;
    }
    if ([self.selectedPlace.name isEqualToString:cell.textLabel.text]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.isSearching) {
        self.selectedPlace = self.searchPlaceArray[indexPath.row];
    } else {
        self.selectedPlace = self.placeArray[indexPath.row];
    }
    [self rightBarButtonItemPressed:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    _isSearching = YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    _searchPlaceArray = [[self.placeArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self CONTAINS[cd] %@", searchText]] mutableCopy];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    _isSearching = NO;
}

@end
