//
//  PaystikCampViewController.m
//  PaystikNav
//
//  Created by Bobie Chen on 9/3/14.
//  Copyright (c) 2014 Bobie Chen. All rights reserved.
//

#import "PaystikCampViewController.h"
#import "PaystikCampCell.h"

@interface PaystikCampViewController () <UITableViewDataSource, UITableViewDelegate>

/* UI elements */
@property (nonatomic, strong)UITableView* tableCampaigns;

/* controls */
@property (nonatomic, strong)NSArray* arrayCampaigns;

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
    
    [self prepareCampView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareCampView
{
    self.title = @"Campaigns";
    
    if (!self.tableCampaigns) {
        self.tableCampaigns = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)
                                                           style:UITableViewStylePlain];
        [self.view addSubview:self.tableCampaigns];
        
        self.tableCampaigns.dataSource = self;
        self.tableCampaigns.delegate = self;
    }
}

#pragma mark - tableview data-source & delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.arrayCampaigns && [self.arrayCampaigns count] != 0) {
        return [self.arrayCampaigns count];
    }
    else {
        return 4;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* strReusableId = @"PaystikCampaignCellId";
    PaystikCampCell* cell = (PaystikCampCell*)[tableView dequeueReusableCellWithIdentifier:strReusableId];
    if (!cell) {
        cell = [[PaystikCampCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strReusableId];
    }
    
    
    /* testing code */
    NSDictionary* dictCamp = @{ @"name" : @"Holy Spirit Church Financial Stewardship",
                                @"description" : @"A steward is defined as a disciple of Jesus who â€œreceives Godâ€™s gifts gratefully, cultivates them responsibly, shares them lovingly in justice with others and returns them with increase to the Lord.â€",
                                @"amount" : @"0",
                                @"cover_url" : @"https://s3-us-west-1.amazonaws.com/paystiks3/Charity.png",
                                @"thumb_url" : @"https://s3-us-west-1.amazonaws.com/paystiks3/",
                                @"coordinate" : @{ @"latitude" : @"37.557033",
                                                   @"longitude" : @"-122.003629"}
                               };
    [cell prepareCampCell:dictCamp];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
