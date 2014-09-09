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

@interface PaystikCampViewController () <UISearchDisplayDelegate, UIActionSheetDelegate>

/* UI elements */
@property (nonatomic, strong)UISearchBar* searchBar;
@property (nonatomic, strong)UISearchDisplayController* campSearchDisplayController;

/* controls */
@property (nonatomic, strong)NSString* strOrgGUID;
@property (nonatomic, strong)NSArray* arrayCampaigns;
@property (nonatomic, strong)NSArray* arrayCampSearchResults;
@property (nonatomic, strong)NSArray* arrayCampaignsByOrganizations;

@end

@implementation PaystikCampViewController {
    BOOL m_bAscendingAlphabetic;
    BOOL m_bSortingByOrganizations;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        m_bAscendingAlphabetic = NO;
        m_bSortingByOrganizations = NO;
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
    
    UIBarButtonItem* btnSort = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize
                                                                             target:self action:@selector(presentSortingOptions)];
    self.navigationItem.rightBarButtonItem = btnSort;

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
        self.arrayCampaignsByOrganizations = @[];
        if (self.strOrgGUID && ![self.strOrgGUID isEqualToString:@""]) {
            for (NSDictionary* dictOrg in arrayOrgs) {
                NSString* strGUID = [dictOrg[@"guid"] stringValue];
                if (dictOrg[@"campaigns"] && strGUID && [strGUID isEqualToString:self.strOrgGUID]) {
                    NSArray* arrayCamps = dictOrg[@"campaigns"];
                    for (NSDictionary* dictCamp in arrayCamps) {
                        [arrayCampaigns addObject:dictCamp];
                    }
                    
                    if ([arrayCamps count] > 0) {
                        self.arrayCampaignsByOrganizations = [self.arrayCampaignsByOrganizations arrayByAddingObject:dictOrg];
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
                    
                    if ([arrayCamps count] > 0) {
                        self.arrayCampaignsByOrganizations = [self.arrayCampaignsByOrganizations arrayByAddingObject:dictOrg];
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

- (void)presentSortingOptions
{
    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:@"Sort by" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Alphabetical Order", @"Organizations", nil];
    
    [sheet showInView:self.view];
}

#pragma mark - action-sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        /* alphabetical */
        m_bSortingByOrganizations = NO;
        
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                     ascending:!m_bAscendingAlphabetic];
        m_bAscendingAlphabetic = !m_bAscendingAlphabetic;
        self.arrayCampaigns = [self.arrayCampaigns sortedArrayUsingDescriptors:@[descriptor]];
        [self.tableView reloadData];
    }
    else if (buttonIndex == 1) {
        /* by organizations */
        m_bSortingByOrganizations = YES;
        [self.tableView reloadData];
    }
}

#pragma mark - tableview data-source & delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (m_bSortingByOrganizations) {
        return [self.arrayCampaignsByOrganizations count];
    }
    else {
        return 1;
    }
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
        if (m_bSortingByOrganizations) {
            NSInteger nCount = 0;
            if (section < [self.arrayCampaignsByOrganizations count]) {
                NSDictionary* dictOrg = [self.arrayCampaignsByOrganizations objectAtIndex:section];
                NSArray* arrayCamps = dictOrg[@"campaigns"];
                nCount = [arrayCamps count];
            }
            return nCount;
        }
        else {
            return [self.arrayCampaigns count];
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
        if (m_bSortingByOrganizations) {
            if (indexPath.section < [self.arrayCampaignsByOrganizations count]) {
                NSDictionary* dictOrg = [self.arrayCampaignsByOrganizations objectAtIndex:indexPath.section];
                NSArray* arrayCamps = dictOrg[@"campaigns"];
                if (indexPath.row < [arrayCamps count]) {
                    dictCamp = [arrayCamps objectAtIndex:indexPath.row];
                }
            }
        }
        else {
            if (indexPath.row < [self.arrayCampaigns count]) {
                dictCamp = [self.arrayCampaigns objectAtIndexedSubscript:indexPath.row];
            }
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
        if (m_bSortingByOrganizations) {
            if (indexPath.section < [self.arrayCampaignsByOrganizations count]) {
                NSDictionary* dictOrg = [self.arrayCampaignsByOrganizations objectAtIndex:indexPath.section];
                NSArray* arrayCamps = dictOrg[@"campaigns"];
                if (indexPath.row < [arrayCamps count]) {
                    dictCamp = [arrayCamps objectAtIndex:indexPath.row];
                }
            }
        }
        else {
            if (indexPath.row < [self.arrayCampaigns count]) {
                dictCamp = [self.arrayCampaigns objectAtIndexedSubscript:indexPath.row];
            }
        }
    }
    
    PaystikCampDetailsViewController* campDetailsVC = [[PaystikCampDetailsViewController alloc] init];
    [campDetailsVC prepareCampDetailedView:dictCamp];
    [self.navigationController pushViewController:campDetailsVC animated:YES];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* strSectionHeader = @"";
    if (tableView == self.tableView && m_bSortingByOrganizations) {
        if (section < [self.arrayCampaignsByOrganizations count]) {
            NSDictionary* dictOrg = [self.arrayCampaignsByOrganizations objectAtIndex:section];
            strSectionHeader = dictOrg[@"name"];
            if (!strSectionHeader) {strSectionHeader = @"";}
        }
    }
    
    return strSectionHeader;
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
