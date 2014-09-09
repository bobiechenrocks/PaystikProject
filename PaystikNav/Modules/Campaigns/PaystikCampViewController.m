//
//  PaystikCampViewController.m
//  PaystikNav
//
//  Created by Bobie Chen on 9/3/14.
//  Copyright (c) 2014 Bobie Chen. All rights reserved.
//

#import "PaystikCampViewController.h"
#import "PaystikCampCell.h"
#import "PaystikCampDetailsViewController.h"

@interface PaystikCampViewController () <UISearchDisplayDelegate>

/* UI elements */
@property (nonatomic, strong)UISearchBar* searchBar;
@property (nonatomic, strong)UISearchDisplayController* campSearchDisplayController;

/* controls */
@property (nonatomic, strong)NSString* strOrgGUID;
@property (nonatomic, strong)NSArray* arrayCampaigns;
@property (nonatomic, strong)NSArray* arrayCampSearchResults;

@end

@implementation PaystikCampViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareCampView:(NSString*)strOrgGUID
{
    self.title = @"Campaigns";
    if (strOrgGUID && ![strOrgGUID isEqualToString:@""]) {
        self.strOrgGUID = strOrgGUID;
    }

    if (!self.campSearchDisplayController) {
        
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, -44.0f, self.view.frame.size.width, 44.0f)];
        self.tableView.tableHeaderView = self.searchBar;
        
        self.campSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
        self.campSearchDisplayController.delegate = self;
        self.campSearchDisplayController.searchResultsTableView.dataSource = self;
        self.campSearchDisplayController.searchResultsTableView.delegate = self;
    }
    
    BOOL bFetchLatestData = YES;
    [self prepareCampData:bFetchLatestData];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@ OR description contains[c] %@", searchText, searchText];
    self.arrayCampSearchResults = [self.arrayCampaigns filteredArrayUsingPredicate:resultPredicate];
}

- (void)prepareCampData:(BOOL)bFetchLatestData
{
    /* if there is cached data in user-defaults, use the data to load the table first */
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"PaystikOrganizations"]) {
        NSArray* arrayOrgs = [[NSUserDefaults standardUserDefaults] objectForKey:@"PaystikOrganizations"];
        
        NSMutableArray* arrayCampaigns = [NSMutableArray arrayWithCapacity:0];
        if (self.strOrgGUID && ![self.strOrgGUID isEqualToString:@""]) {
            for (NSDictionary* dictOrg in arrayOrgs) {
                NSString* strGUID = [dictOrg[@"guid"] stringValue];
                if (dictOrg[@"campaigns"] && strGUID && [strGUID isEqualToString:self.strOrgGUID]) {
                    NSArray* arrayCamps = dictOrg[@"campaigns"];
                    for (NSDictionary* dictCamp in arrayCamps) {
                        [arrayCampaigns addObject:dictCamp];
                    }
                    break;
                }
            }
        }
        else {
            for (NSDictionary* dictOrg in arrayOrgs) {
                if (dictOrg[@"campaigns"]) {
                    NSArray* arrayCamps = dictOrg[@"campaigns"];
                    for (NSDictionary* dictCamp in arrayCamps) {
                        [arrayCampaigns addObject:dictCamp];
                    }
                }
            }
        }
        
        self.arrayCampaigns = arrayCampaigns;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
    
    /* in the mean time, fetch latest data via network asynchronously */
    if (bFetchLatestData) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self _fetchCampData];
        });
    }
}

- (void)_fetchCampData
{
    BOOL bTestingPhase = YES;
    
    if (bTestingPhase) {
        [self _fetchCampDataViaFile];
    }
    else {
        [self _fetchCampDataViaNetwork];
    }
}

- (void)_fetchCampDataViaFile
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"PaystikOrganizations"]) {
        NSArray* arrayOrgs = [[NSUserDefaults standardUserDefaults] objectForKey:@"PaystikOrganizations"];
        
        for (NSDictionary* dictOrg in arrayOrgs) {
            if (dictOrg[@"guid"]) {
                NSString* strGUID = [dictOrg[@"guid"] stringValue];
                if (![strGUID isEqualToString:@""]) {
                    NSString* strCampId = [NSString stringWithFormat:@"campaigns_%@", strGUID];
                    
                    NSString* strJSONFilePath = [[NSBundle mainBundle] pathForResource:strCampId ofType:@"json"];
                    NSString* fileContent = [[NSString alloc] initWithContentsOfFile:strJSONFilePath encoding:NSUTF8StringEncoding error:nil];
                    NSData* campData = [fileContent dataUsingEncoding:NSUTF8StringEncoding];
                    NSError* error = nil;
                    if (campData) {
                        NSArray* arrayData = [NSJSONSerialization JSONObjectWithData:campData
                                                                             options:NSJSONReadingMutableLeaves
                                                                               error:&error];
                        
                        /* remember to update back to user-defaults */
                        [self _updateCampaignOfOrg:strGUID campaigns:arrayData];
                    }
                }
            }
        }
        
        /* use this function to refresh tableview with latest organization/campaign data */
        BOOL bFetchLatestData = NO;
        [self prepareCampData:bFetchLatestData];
    }
}

- (void)_updateCampaignOfOrg:(NSString*)strGUID campaigns:(NSArray*)arrayCampaigns
{
    if (!strGUID || [strGUID isEqualToString:@""]) {
        return;
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"PaystikOrganizations"]) {
        NSMutableArray* arrayUpdatedOrgs = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PaystikOrganizations"] mutableCopy];
        for (int nIndex = 0; nIndex < [arrayUpdatedOrgs count]; ++nIndex) {
            NSDictionary* dictOrg = [arrayUpdatedOrgs objectAtIndex:nIndex];
            NSString* strId = [dictOrg[@"guid"] stringValue];
            if ([strId isEqualToString:strGUID]) {
                NSMutableDictionary* dictUpdatedOrg = [dictOrg mutableCopy];
                dictUpdatedOrg[@"campaigns"] = arrayCampaigns;
                [arrayUpdatedOrgs replaceObjectAtIndex:nIndex withObject:dictUpdatedOrg];
                break;
            }
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:arrayUpdatedOrgs forKey:@"PaystikOrganizations"];
    }
}

- (void)_fetchCampDataViaNetwork
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"PaystikOrganizations"]) {
        NSArray* arrayOrgs = [[NSUserDefaults standardUserDefaults] objectForKey:@"PaystikOrganizations"];
        
        for (NSDictionary* dictOrg in arrayOrgs) {
            if (dictOrg[@"guid"]) {
                NSString* strGUID = [dictOrg[@"guid"] stringValue];
                if (![strGUID isEqualToString:@""]) {
                    
                    /* fake API base */
                    NSString* strAPIBase = @"http://paystik.com/s/api/campaigns";
                    NSURL* apiURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?guid=%@", strAPIBase, strGUID]];
                    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:apiURL];
                    NSOperationQueue* q = [[NSOperationQueue alloc] init];

                    [NSURLConnection sendAsynchronousRequest:request queue:q completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                        
                        if (connectionError) {
                            /* do something */
                            NSLog(@"%@", [connectionError localizedDescription]);
                        }
                        
                        /* check status in response */
                        
                        /* data serialization: details skipped since we don't really know the exact returned data from the server */
                        NSArray* arrayResults = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                        [self _updateCampaignOfOrg:strGUID campaigns:arrayResults];
                    }];
                }
            }
        }
        
        /* use this function to refresh tableview with latest organization/campaign data */
        BOOL bFetchLatestData = NO;
        [self prepareCampData:bFetchLatestData];
    }
}

#pragma mark - tableview data-source & delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.campSearchDisplayController.searchResultsTableView) {
        if (self.arrayCampSearchResults && [self.arrayCampSearchResults count] != 0) {
            return [self.arrayCampSearchResults count];
        }
        else {
            return 0;
        }
    }
    else {
        if (self.arrayCampaigns && [self.arrayCampaigns count] != 0) {
            return [self.arrayCampaigns count];
        }
        else {
            return 0;
        }
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* strReusableId = @"PaystikCampaignCellId";
    PaystikCampCell* cell = (PaystikCampCell*)[tableView dequeueReusableCellWithIdentifier:strReusableId];
    if (!cell) {
        cell = [[PaystikCampCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strReusableId];
    }
    
    NSDictionary* dictCamp;
    if (tableView == self.campSearchDisplayController.searchResultsTableView) {
        if (indexPath.row < [self.arrayCampSearchResults count]) {
            dictCamp = [self.arrayCampSearchResults objectAtIndexedSubscript:indexPath.row];
        }
    }
    else {
        if (indexPath.row < [self.arrayCampaigns count]) {
            dictCamp = [self.arrayCampaigns objectAtIndexedSubscript:indexPath.row];
        }
    }
    [cell prepareCampCell:dictCamp];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* dictCamp;
    if (tableView == self.campSearchDisplayController.searchResultsTableView) {
        if (indexPath.row < [self.arrayCampSearchResults count]) {
            dictCamp = [self.arrayCampSearchResults objectAtIndexedSubscript:indexPath.row];
        }
    }
    else {
        if (indexPath.row < [self.arrayCampaigns count]) {
            dictCamp = [self.arrayCampaigns objectAtIndexedSubscript:indexPath.row];
        }
    }
    
    PaystikCampDetailsViewController* campDetailsVC = [[PaystikCampDetailsViewController alloc] init];
    [campDetailsVC prepareCampDetailedView:dictCamp];
    [self.navigationController pushViewController:campDetailsVC animated:YES];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

@end
