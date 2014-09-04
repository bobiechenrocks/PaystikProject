//
//  PaystikOrgCell.m
//  PaystikNav
//
//  Created by Bobie Chen on 9/3/14.
//  Copyright (c) 2014 Bobie Chen. All rights reserved.
//

#import "PaystikOrgCell.h"
#import "UICommonUtility.h"

@interface PaystikOrgCell ()

/* UI elements */
@property (nonatomic, strong)UIImageView* imageLogo;
@property (nonatomic, strong)UILabel* labelName;
@property (nonatomic, strong)UIButton* btnMap;
@property (nonatomic, strong)UIButton* btnCampaigns;

/* controls */
@property (nonatomic, strong)NSDictionary* dictOrg;

@end

@implementation PaystikOrgCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareOrgCell:(NSDictionary*)dictOrg
{
    self.dictOrg = dictOrg;
    
    CGFloat fLogoMarginLeft = 10.0f, fLogoWidth = 35.0f;
    if (!self.imageLogo) {
        self.imageLogo = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.imageLogo];
        [self.imageLogo setBackgroundColor:[UIColor lightGrayColor]];
    }
    
    if (dictOrg[@"logo_url"]) {
        NSString* strLogoURL = dictOrg[@"logo_url"];
        [self _fetchOrgLogoWithURL:strLogoURL];
    }
    
    if (dictOrg[@"name"]) {
        if (!self.labelName) {
            self.labelName = [[UILabel alloc] initWithFrame:CGRectZero];
            [self.contentView addSubview:self.labelName];
            
            [self.labelName setBackgroundColor:[UIColor clearColor]];
            [self.labelName setFont:[UIFont systemFontOfSize:14.0f]];
        }
        
        NSString* strName = dictOrg[@"name"];
        [self.labelName setText:strName];
        
        CGRect frame = self.labelName.frame;
        CGFloat fNameMaxWidth = 192.0f;
        frame.size.width = fNameMaxWidth;
        self.labelName.frame = frame;
        [self.labelName sizeToFit];
        
        frame = self.labelName.frame;
        if (frame.size.width > fNameMaxWidth) {
            frame.size.width = fNameMaxWidth;
        }
        CGFloat fNameMarginLeft = 5.0f;
        frame.origin.x = fLogoMarginLeft + fLogoWidth + fNameMarginLeft;
        frame.origin.y = (self.contentView.frame.size.height - frame.size.height)/2.0f;
        self.labelName.frame = frame;
    }
    
    CGFloat fMapCampBtnMarginRight = 10.0f, fMapCampBtnSize = 30.0f, fMapCampBtnGap = 5.0f;
    if (dictOrg[@"coordinate"]) {
        if (!self.btnMap) {
            self.btnMap = [[UIButton alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width - fMapCampBtnMarginRight - fMapCampBtnSize*2 - fMapCampBtnGap,
                                                                     (self.contentView.frame.size.height - fMapCampBtnSize)/2.0f,
                                                                     fMapCampBtnSize, fMapCampBtnSize)];
            [self.contentView addSubview:self.btnMap];
            
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
    
    if (!self.btnCampaigns) {
        self.btnCampaigns = [[UIButton alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width - fMapCampBtnMarginRight - fMapCampBtnSize,
                                                                       (self.contentView.frame.size.height - fMapCampBtnSize)/2.0f,
                                                                       fMapCampBtnSize, fMapCampBtnSize)];
        [self.contentView addSubview:self.btnCampaigns];
        
        [self.btnCampaigns setBackgroundColor:[UIColor darkGrayColor]];
        [self.btnCampaigns addTarget:self action:@selector(_campaignBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel* labelC = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.btnCampaigns addSubview:labelC];
        [labelC setBackgroundColor:[UIColor clearColor]];
        [labelC setFont:[UIFont systemFontOfSize:17.0f]];
        [labelC setTextColor:[UIColor whiteColor]];
        [labelC setText:@"C"];
        [labelC sizeToFit];
        CGRect frame = labelC.frame;
        frame.origin.x = (fMapCampBtnSize - frame.size.width)/2.0f;
        frame.origin.y = (fMapCampBtnSize - frame.size.height)/2.0f;
        labelC.frame = frame;
    }
}

- (void)_fetchOrgLogoWithURL:(NSString*)strURL
{
    
}

#pragma mark - button functions
- (void)_mapBtnClicked
{
    
}

- (void)_campaignBtnClicked
{
    
}

@end
