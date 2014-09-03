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
    
    if (!self.tableOrganizations) {
        self.tableOrganizations = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)
                                                               style:UITableViewStylePlain];
        [self.view addSubview:self.tableOrganizations];
        
        self.tableOrganizations.dataSource = self;
        self.tableOrganizations.delegate = self;
    }
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
        return 4;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* strReusableId = @"PaystikOrganizationCellId";
    PaystikOrgCell* cell = (PaystikOrgCell*)[tableView dequeueReusableCellWithIdentifier:strReusableId];
    if (!cell) {
        cell = [[PaystikOrgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strReusableId];
    }
    
    
    /* testing code */
    NSDictionary* dictOrg = @{ @"guid" : @"1",
                               @"name" : @"Pejman and Mar's",
                               @"logo_url" : @"https://www.paystik.com/default_logo.jpg",
                               @"coordinate" : @{ @"latitude": @"37.445342",
                                                  @"longitude": @"-122.16547" }
                               };
    [cell prepareOrgCell:dictOrg];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

@end
