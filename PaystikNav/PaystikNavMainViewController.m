//
//  PaystikNavMainViewController.m
//  PaystikNav
//
//  Created by Bobie Chen on 9/3/14.
//  Copyright (c) 2014 Bobie Chen. All rights reserved.
//

#import "PaystikNavMainViewController.h"
#import "PaystikOrgViewController.h"
#import "PaystikCampViewController.h"

@interface PaystikNavMainViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)UITableView *tableOrgCamp;

@end

@implementation PaystikNavMainViewController

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
    
    [self prepareMainView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareMainView
{
    self.title = @"evergive";
    
    if (!self.tableOrgCamp) {
        CGFloat fStatusNavBarHeight = 64.0f;
        self.tableOrgCamp = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, fStatusNavBarHeight,
                                                                          self.view.frame.size.width, self.view.frame.size.height - fStatusNavBarHeight)
                                                         style:UITableViewStylePlain];
        [self.view addSubview:self.tableOrgCamp];
        
        self.tableOrgCamp.dataSource = self;
        self.tableOrgCamp.delegate = self;
    }
}

#pragma mark - tableview data-source & delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* strReusableId = @"PaystikOrgCampCellId";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:strReusableId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strReusableId];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    cell.textLabel.text = (indexPath.row == 0)? @"Organizations" : @"Campaigns";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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

@end
