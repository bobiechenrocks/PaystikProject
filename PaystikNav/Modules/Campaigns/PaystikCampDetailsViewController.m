//
//  PaystikCampDetailsViewController.m
//  PaystikNav
//
//  Created by Bobie Chen on 9/3/14.
//  Copyright (c) 2014 Bobie Chen. All rights reserved.
//

#import "PaystikCampDetailsViewController.h"

@interface PaystikCampDetailsViewController ()

/* UI elements */
@property (nonatomic, strong)UIImageView* imageCover;
@property (nonatomic, strong)UILabel* labelName;
@property (nonatomic, strong)UILabel* labelAmount;
@property (nonatomic, strong)UIScrollView* scrollDescription;
@property (nonatomic, strong)UIButton* btnMap;
@property (nonatomic, strong)UILabel* labelDescription;

/* controls */
@property (nonatomic, weak)NSDictionary* dictCamp;

@end

@implementation PaystikCampDetailsViewController

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

- (void)prepareCampDetailedView:(NSDictionary*)dictCamp
{
    self.title = @"Camp Details";
    
    CGFloat fDefaultCoverWidth = self.view.frame.size.width, fDefaultCoverHeight = 214.0f;
    if (!self.imageCover) {
        self.imageCover = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, fDefaultCoverWidth, fDefaultCoverHeight)];
        [self.view addSubview:self.imageCover];
        [self.imageCover setBackgroundColor:[UIColor lightGrayColor]];
    }
    
    if (dictCamp[@"cover_url"]) {
        NSString* strThumbURL = dictCamp[@"cover_url"];
        [self _fetchCampCoverWithURL:strThumbURL];
    }
    
    if (dictCamp[@"amount"]) {
        if (!self.labelAmount) {
            self.labelAmount = [[UILabel alloc] initWithFrame:CGRectZero];
            [self.imageCover addSubview:self.labelAmount];
            
            [self.labelAmount setBackgroundColor:[UIColor clearColor]];
            [self.labelAmount setFont:[UIFont systemFontOfSize:14.0f]];
        }
        
        NSString* strAmount = [NSString stringWithFormat:@"$: %@", dictCamp[@"amount"]];
        [self.labelAmount setText:strAmount];
        [self.labelAmount sizeToFit];
        
        CGRect frame = self.labelAmount.frame;
        CGFloat fAmountMargin = 10.0f;
        frame.origin.x = self.imageCover.frame.size.width - fAmountMargin - frame.size.width;
        frame.origin.y = self.imageCover.frame.size.height - fAmountMargin - frame.size.height;
        self.labelAmount.frame = frame;
    }
    
    if (!self.scrollDescription) {
        self.scrollDescription = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, fDefaultCoverHeight,
                                                                                self.view.frame.size.width, self.view.frame.size.height - fDefaultCoverHeight)];
        [self.view addSubview:self.scrollDescription];
        
        [self.scrollDescription setBackgroundColor:[UIColor whiteColor]];
        [self.scrollDescription setContentSize:CGSizeMake(self.scrollDescription.frame.size.width, self.scrollDescription.frame.size.height)];
        [self.scrollDescription setScrollEnabled:YES];
    }
    
    if (dictCamp[@"name"]) {
        if (!self.labelName) {
            self.labelName = [[UILabel alloc] initWithFrame:CGRectZero];
            [self.scrollDescription addSubview:self.labelName];
            
            [self.labelName setBackgroundColor:[UIColor clearColor]];
            [self.labelName setFont:[UIFont systemFontOfSize:14.0f]];
            [self.labelName setNumberOfLines:2];
        }
        
        NSString* strName = dictCamp[@"name"];
        [self.labelName setText:strName];
        
        CGFloat fNameMaxWidth = (dictCamp[@"coordination"])? 255.0f : 290.0f;
        CGRect frame = self.labelName.frame;
        frame.size.width = fNameMaxWidth;
        self.labelName.frame = frame;
        [self.labelName sizeToFit];
        
        frame = self.labelName.frame;
        if (frame.size.width > fNameMaxWidth) {
            frame.size.width = fNameMaxWidth;
        }
        CGFloat fNameMargin = 10.0f;
        frame.origin.x = fNameMargin;
        frame.origin.y = fNameMargin;
        self.labelName.frame = frame;
    }
    
    CGFloat fMapCampBtnMarginTop = 5.0f, fMapCampBtnMarginRight = 10.0f, fMapCampBtnSize = 30.0f;
    if (dictCamp[@"coordinate"]) {
        if (!self.btnMap) {
            self.btnMap = [[UIButton alloc] initWithFrame:CGRectMake(self.scrollDescription.frame.size.width - fMapCampBtnMarginRight - fMapCampBtnSize,
                                                                     fMapCampBtnMarginTop, fMapCampBtnSize, fMapCampBtnSize)];
            [self.scrollDescription addSubview:self.btnMap];
            
            [self.btnMap setBackgroundColor:[UIColor darkGrayColor]];
            [self.btnMap addTarget:self action:@selector(_mapBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            
            UILabel* labelM = [[UILabel alloc] initWithFrame:CGRectZero];
            [self.btnMap addSubview:labelM];
            [labelM setBackgroundColor:[UIColor clearColor]];
            [labelM setFont:[UIFont systemFontOfSize:17.0f]];
            [labelM setTextColor:[UIColor whiteColor]];
            [labelM setText:@"M"];
            [labelM sizeToFit];
            CGRect frame = labelM.frame;
            frame.origin.x = (fMapCampBtnSize - frame.size.width)/2.0f;
            frame.origin.y = (fMapCampBtnSize - frame.size.height)/2.0f;
            labelM.frame = frame;
        }
    }
    
    CGFloat fDescMaxWidth = 290.0f, fDescMarginLeft = 13.0f, fDescMarginTop = 40.0f, fDescMarginBottom = 13.0f;
    if (dictCamp[@"description"]) {
        if (!self.labelDescription) {
            self.labelDescription = [[UILabel alloc] initWithFrame:CGRectZero];
            [self.scrollDescription addSubview:self.labelDescription];
            
            [self.labelDescription setBackgroundColor:[UIColor clearColor]];
            [self.labelDescription setFont:[UIFont systemFontOfSize:13.0f]];
            [self.labelDescription setNumberOfLines:0];
        }
        
        NSString* strDesc = dictCamp[@"description"];
        [self.labelDescription setText:strDesc];
        CGRect frame = self.labelDescription.frame;
        frame.size.width = fDescMaxWidth;
        self.labelDescription.frame = frame;
        
        [self.labelDescription sizeToFit];
        frame = self.labelDescription.frame;
        if (frame.size.width > fDescMaxWidth) {
            frame.size.width = fDescMaxWidth;
        }
        frame.origin.x = fDescMarginLeft;
        frame.origin.y = fDescMarginTop;
        self.labelDescription.frame = frame;
    }
    
    if (self.labelDescription.frame.origin.y + self.labelDescription.frame.size.height > self.scrollDescription.contentSize.height - fDescMarginBottom) {
        [self.scrollDescription setContentSize:CGSizeMake(self.scrollDescription.frame.size.width,
                                                          self.labelDescription.frame.origin.y + self.labelDescription.frame.size.height + fDescMarginBottom)];
    }
}

- (void)_fetchCampCoverWithURL:(NSString*)strURL
{
    
}

#pragma mark - button functions
- (void)_mapBtnClicked
{
    
}

@end
