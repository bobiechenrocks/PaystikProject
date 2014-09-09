//
//  PaystikNavMainView.m
//  PaystikNav
//
//  Created by Bobie Chen on 9/8/14.
//  Copyright (c) 2014 Bobie Chen. All rights reserved.
//

#import "PaystikNavMainView.h"
#import "PaystikOrgViewController.h"
#import "PaystikCampViewController.h"
#import "PaystikOrgCell.h"
#import "PaystikCampCell.h"
#import "PaystikOrgMapViewController.h"
#import "PaystikCampDetailsViewController.h"

@interface PaystikNavMainView () <UISearchDisplayDelegate, PaystikOrgCellDelegate>

@property (nonatomic, strong)UISearchBar* searchBar;
@property (nonatomic, strong)UISearchDisplayController* orgCampSearchDisplayController;

@property (nonatomic, strong)NSArray* arrayOrgs;
@property (nonatomic, strong)NSArray* arrayCamps;
@property (nonatomic, strong)NSArray* arrayOrgSearchResults;
@property (nonatomic, strong)NSArray* arrayCampSearchResults;

@end

@implementation PaystikNavMainView

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self prepareMainView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareMainView
{
    self.title = @"Evergive";
    [self.tableView setClipsToBounds:NO];
    [self.view setClipsToBounds:NO];
    
    [self _prepareData];

    if (!self.orgCampSearchDisplayController) {
        
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, -44.0f, self.view.frame.size.width, 44.0f)];
        self.tableView.tableHeaderView = self.searchBar;
        
        self.orgCampSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
        self.orgCampSearchDisplayController.delegate = self;
        self.orgCampSearchDisplayController.searchResultsTableView.dataSource = self;
        self.orgCampSearchDisplayController.searchResultsTableView.delegate = self;
    }
}

- (void)_prepareData
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"PaystikOrganizations"]) {
        self.arrayOrgs = [[NSUserDefaults standardUserDefaults] objectForKey:@"PaystikOrganizations"];
        
        self.arrayCamps = @[];
        for (NSDictionary* dictOrg in self.arrayOrgs) {
            if (dictOrg[@"campaigns"]) {
                NSArray* arrayCamps = dictOrg[@"campaigns"];
                self.arrayCamps = [self.arrayCamps arrayByAddingObjectsFromArray:arrayCamps];
            }
        }
    }
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@ OR description contains[c] %@", searchText, searchText];
    self.arrayOrgSearchResults = [self.arrayOrgs filteredArrayUsingPredicate:resultPredicate];
    self.arrayCampSearchResults = [self.arrayCamps filteredArrayUsingPredicate:resultPredicate];
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

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (tableView == self.orgCampSearchDisplayController.searchResultsTableView) {
        return 2;
    }
    else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView == self.orgCampSearchDisplayController.searchResultsTableView) {
        if (section == 0) {
            return [self.arrayOrgSearchResults count];
        }
        else {
            return [self.arrayCampSearchResults count];
        }
    }
    else {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.orgCampSearchDisplayController.searchResultsTableView) {
        if (indexPath.section == 0) {
            NSString* strReusableId = @"PaystikOrganizationCellId";
            PaystikOrgCell* cell = (PaystikOrgCell*)[tableView dequeueReusableCellWithIdentifier:strReusableId];
            if (!cell) {
                cell = [[PaystikOrgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strReusableId];
                cell.delegate = self;
            }
            
            NSDictionary* dictOrg;
            if (indexPath.row < [self.arrayOrgSearchResults count]) {
                dictOrg = [self.arrayOrgSearchResults objectAtIndexedSubscript:indexPath.row];
            }
            
            [cell prepareOrgCell:dictOrg];
            
            return cell;
        }
        else {
            NSString* strReusableId = @"PaystikCampaignCellId";
            PaystikCampCell* cell = (PaystikCampCell*)[tableView dequeueReusableCellWithIdentifier:strReusableId];
            if (!cell) {
                cell = [[PaystikCampCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strReusableId];
            }
            
            NSDictionary* dictCamp;
            if (indexPath.row < [self.arrayCampSearchResults count]) {
                dictCamp = [self.arrayCampSearchResults objectAtIndex:indexPath.row];
            }
            [cell prepareCampCell:dictCamp];
            
            return cell;
        }
    }
    else {
        NSString* strReusableId = @"PaystikOrgCampCellId";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:strReusableId];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strReusableId];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        
        cell.textLabel.text = (indexPath.row == 0)? @"Organizations" : @"Campaigns";
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.orgCampSearchDisplayController.searchResultsTableView) {
        if (indexPath.section == 1) {
            /* campaigns */
            NSDictionary* dictCamp;
            if (indexPath.row < [self.arrayCampSearchResults count]) {
                dictCamp = [self.arrayCampSearchResults objectAtIndex:indexPath.row];
            }
            
            PaystikCampDetailsViewController* campDetailsVC = [[PaystikCampDetailsViewController alloc] init];
            [campDetailsVC prepareCampDetailedView:dictCamp];
            [self.navigationController pushViewController:campDetailsVC animated:YES];
        }
    }
    else {
        if (indexPath.row == 0) {
            /* organizations */
            PaystikOrgViewController* orgVC = [[PaystikOrgViewController alloc] init];
            [self.navigationController pushViewController:orgVC animated:YES];
        }
        else {
            /* campaigns */
            PaystikCampViewController* campVC = [[PaystikCampViewController alloc] init];
            [campVC prepareCampView:nil];
            [self.navigationController pushViewController:campVC animated:YES];
        }
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* strSectionHeader = @"";
    if (tableView == self.orgCampSearchDisplayController.searchResultsTableView) {
        strSectionHeader = (section == 0)? @"Organizations" : @"Campaigns";
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
