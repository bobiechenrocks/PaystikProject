//
//  PaystikOrgViewController.m
//  PaystikNav
//
//  Created by Bobie Chen on 9/3/14.
//  Copyright (c) 2014 Bobie Chen. All rights reserved.
//

#import "PaystikOrgViewController.h"
#import "PaystikOrgCell.h"

@interface PaystikOrgViewController () <UITableViewDataSource, UITableViewDelegate>

/* UI elements */
@property (nonatomic, strong)UITableView* tableOrganizations;

/* controls */
@property (nonatomic, strong)NSArray* arrayOrganizations;

@end

@implementation PaystikOrgViewController

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
    
    [self prepareOrgData];
    
    if (!self.tableOrganizations) {
        self.tableOrganizations = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)
                                                               style:UITableViewStylePlain];
        [self.view addSubview:self.tableOrganizations];
        
        self.tableOrganizations.dataSource = self;
        self.tableOrganizations.delegate = self;
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
                [self.tableOrganizations reloadData];
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
                [self.tableOrganizations reloadData];
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

#pragma mark - tableview data-source & delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.arrayOrganizations && [self.arrayOrganizations count] != 0) {
        return [self.arrayOrganizations count];
    }
    else {
        return 0;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* strReusableId = @"PaystikOrganizationCellId";
    PaystikOrgCell* cell = (PaystikOrgCell*)[tableView dequeueReusableCellWithIdentifier:strReusableId];
    if (!cell) {
        cell = [[PaystikOrgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strReusableId];
        cell.parentOrgView = self;
    }
    
    NSDictionary* dictOrg;
    if (indexPath.row < [self.arrayOrganizations count]) {
        dictOrg = [self.arrayOrganizations objectAtIndexedSubscript:indexPath.row];
    }

    [cell prepareOrgCell:dictOrg];
    
    return cell;
}

@end
