//
//  PaystikOrgViewController.m
//  PaystikNav
//
//  Created by Bobie Chen on 9/3/14.
//  Copyright (c) 2014 Bobie Chen. All rights reserved.
//

#import "PaystikOrgViewController.h"
#import "PaystikOrgCell.h"
#import "PaystikOrgMapViewController.h"
#import "PaystikCampViewController.h"

@interface PaystikOrgViewController () <UISearchDisplayDelegate, PaystikOrgCellDelegate, UIActionSheetDelegate>

/* UI elements */
@property (nonatomic, strong)UISearchBar* searchBar;
@property (nonatomic, strong)UISearchDisplayController* orgSearchDisplayController;

/* controls */
@property (nonatomic, strong)NSArray* arrayOrganizations;
@property (nonatomic, strong)NSArray* arrayOrgSearchResults;

@end

@implementation PaystikOrgViewController {
    BOOL m_bAscendingAlphabetic;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        m_bAscendingAlphabetic = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self prepareOrgView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareOrgView
{
    self.title = @"Organizations";
    
    UIBarButtonItem* btnSort = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize
                                                                             target:self action:@selector(presentSortingOptions)];
    self.navigationItem.rightBarButtonItem = btnSort;
    
    [self prepareOrgData];

    if (!self.orgSearchDisplayController) {
        
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, -44.0f, self.view.frame.size.width, 44.0f)];
        self.tableView.tableHeaderView = self.searchBar;
        
        self.orgSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
        self.orgSearchDisplayController.delegate = self;
        self.orgSearchDisplayController.searchResultsTableView.dataSource = self;
        self.orgSearchDisplayController.searchResultsTableView.delegate = self;
    }
}

- (void)prepareOrgData
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"PaystikOrganizations"]) {
        self.arrayOrganizations = [[NSUserDefaults standardUserDefaults] objectForKey:@"PaystikOrganizations"];
    }
    
    /* in the mean time, fetch latest data via network asynchronously */
    [self _fetchOrgData];
}

- (void)_fetchOrgData
{
    BOOL bTestingPhase = YES;
    
    if (bTestingPhase) {
        [self _fetchOrgDataViaFile:^(NSArray* arrayResults, NSError* error) {
            if (!error && [arrayResults count]) {
                self.arrayOrganizations = arrayResults;
                [self.tableView reloadData];
                [[NSUserDefaults standardUserDefaults] setObject:arrayResults forKey:@"PaystikOrganizations"];
            }
            else {
                /* show some alert */
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription]
                                                               delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }
        }];
    }
    else {
        [self _fetchOrgDataViaNetwork:^(NSArray* arrayResults, NSError* error) {
            if (!error && [arrayResults count]) {
                self.arrayOrganizations = arrayResults;
                [self.tableView reloadData];
                [[NSUserDefaults standardUserDefaults] setObject:arrayResults forKey:@"PaystikOrganizations"];
            }
            else {
                /* show some alert */
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription]
                                                               delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }
        }];
    }
}

- (void)_fetchOrgDataViaFile:(void (^)(NSArray*, NSError*))completion
{
    NSString* strJSONFilePath = [[NSBundle mainBundle] pathForResource:@"organizations" ofType:@"json"];
    NSString* fileContent = [[NSString alloc] initWithContentsOfFile:strJSONFilePath encoding:NSUTF8StringEncoding error:nil];
    NSData* orgData = [fileContent dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error = nil;
    NSArray* arrayData = [NSJSONSerialization JSONObjectWithData:orgData
                                                         options:NSJSONReadingMutableLeaves
                                                           error:&error];
    
    if (completion) {
        completion(arrayData, error);
    }
}

- (void)_fetchOrgDataViaNetwork:(void (^)(NSArray*, NSError*))completion
{
    NSURL* url = [NSURL URLWithString:@""];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    NSOperationQueue* q = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:q completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (connectionError) {
            if (completion) {
                completion(nil, connectionError);
            }
        }
        
        /* check status in response */
        
        /* data serialization: details skipped since we don't really know the exact returned data from the server */
        NSArray* arrayResults = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        if (completion) {
            completion(arrayResults, nil);
        }
    }];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
    self.arrayOrgSearchResults = [self.arrayOrganizations filteredArrayUsingPredicate:resultPredicate];
}

- (void)presentSortingOptions
{
    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:@"Sort by" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Alphabetical Order",nil];

    [sheet showInView:self.view];
}

#pragma mark - action-sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        /* alphabetical */
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                     ascending:!m_bAscendingAlphabetic];
        m_bAscendingAlphabetic = !m_bAscendingAlphabetic;
        self.arrayOrganizations = [self.arrayOrganizations sortedArrayUsingDescriptors:@[descriptor]];
        [self.tableView reloadData];
    }
}

#pragma mark - tableview data-source & delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.orgSearchDisplayController.searchResultsTableView) {
        if (self.arrayOrgSearchResults) {
            return [self.arrayOrgSearchResults count];
        }
        else {
            return 0;
        }
    }
    else {
        if (self.arrayOrganizations && [self.arrayOrganizations count] != 0) {
            return [self.arrayOrganizations count];
        }
        else {
            return 0;
        }
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* strReusableId = @"PaystikOrganizationCellId";
    PaystikOrgCell* cell = (PaystikOrgCell*)[tableView dequeueReusableCellWithIdentifier:strReusableId];
    if (!cell) {
        cell = [[PaystikOrgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strReusableId];
        cell.delegate = self;
    }
    
    NSDictionary* dictOrg;
    if (tableView == self.orgSearchDisplayController.searchResultsTableView) {
        if (indexPath.row < [self.arrayOrgSearchResults count]) {
            dictOrg = [self.arrayOrgSearchResults objectAtIndexedSubscript:indexPath.row];
        }
    }
    else {
        if (indexPath.row < [self.arrayOrganizations count]) {
            dictOrg = [self.arrayOrganizations objectAtIndexedSubscript:indexPath.row];
        }
    }
    
    [cell prepareOrgCell:dictOrg];
    
    return cell;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

#pragma mark - PaystikOrgCellDelegate
- (void)showMapViewOfOrganizationWithLocation:(NSDictionary *)dictCoordinate andName:(NSString *)strName
{
    PaystikOrgMapViewController* mapVC = [[PaystikOrgMapViewController alloc] init];
    [mapVC prepareMapViewWithLocation:dictCoordinate andName:strName];
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:mapVC];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)showCampOfOrganization:(NSString *)strOrgGUID
{
    PaystikCampViewController* campVC = [[PaystikCampViewController alloc] init];
    [campVC prepareCampView:strOrgGUID];
    [self.navigationController pushViewController:campVC animated:YES];
}

@end
