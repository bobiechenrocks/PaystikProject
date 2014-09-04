//
//  PaystikCampCell.m
//  PaystikNav
//
//  Created by Bobie Chen on 9/3/14.
//  Copyright (c) 2014 Bobie Chen. All rights reserved.
//

#import "PaystikCampCell.h"

@interface PaystikCampCell ()

/* UI elements */
@property (nonatomic, strong)UIImageView* imageThumb;
@property (nonatomic, strong)UILabel* labelName;
@property (nonatomic, strong)UILabel* labelAmount;

/* controls */
@property (nonatomic, weak)NSDictionary* dictCamp;

@end

@implementation PaystikCampCell

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

- (void)prepareCampCell:(NSDictionary*)dictCamp
{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    self.dictCamp = dictCamp;
    
    CGFloat fThumbMarginLeft = 10.0f, fThumbWidth = 35.0f;
    if (!self.imageThumb) {
        self.imageThumb = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.imageThumb];
        [self.imageThumb setBackgroundColor:[UIColor lightGrayColor]];
    }
    
    if (dictCamp[@"thumb_url"]) {
        NSString* strThumbURL = dictCamp[@"thumb_url"];
        [self _fetchCampThumbWithURL:strThumbURL];
    }
    
    if (dictCamp[@"name"]) {
        if (!self.labelName) {
            self.labelName = [[UILabel alloc] initWithFrame:CGRectZero];
            [self.contentView addSubview:self.labelName];
            
            [self.labelName setBackgroundColor:[UIColor clearColor]];
            [self.labelName setFont:[UIFont systemFontOfSize:14.0f]];
            [self.labelName setNumberOfLines:2];
        }
        
        NSString* strName = dictCamp[@"name"];
        [self.labelName setText:strName];
        
        CGFloat fNameMaxWidth = 215.0f;
        CGRect frame = self.labelName.frame;
        frame.size.width = fNameMaxWidth;
        self.labelName.frame = frame;
        [self.labelName sizeToFit];
        
        frame = self.labelName.frame;
        if (frame.size.width > fNameMaxWidth) {
            frame.size.width = fNameMaxWidth;
        }
        CGFloat fNameMarginLeft = 5.0f;
        frame.origin.x = fThumbMarginLeft + fThumbWidth + fNameMarginLeft;
        frame.origin.y = (self.contentView.frame.size.height - frame.size.height)/2.0f;
        self.labelName.frame = frame;
    }
    
    if (dictCamp[@"amount"]) {
        if (!self.labelAmount) {
            self.labelAmount = [[UILabel alloc] initWithFrame:CGRectZero];
            [self.contentView addSubview:self.labelAmount];
            
            [self.labelAmount setBackgroundColor:[UIColor clearColor]];
            [self.labelAmount setFont:[UIFont systemFontOfSize:14.0f]];
        }
        
        NSString* strAmount = [NSString stringWithFormat:@"$: %@", dictCamp[@"amount"]];
        [self.labelAmount setText:strAmount];
        [self.labelAmount sizeToFit];
        
        CGRect frame = self.labelAmount.frame;
        CGFloat fAmountMarginRight = 10.0f;
        frame.origin.x = self.contentView.frame.size.width - fAmountMarginRight - frame.size.width;
        frame.origin.y = (self.contentView.frame.size.height - frame.size.height)/2.0f;
        self.labelAmount.frame = frame;
    }
}

- (void)_fetchCampThumbWithURL:(NSString*)strURL
{
    
}

@end
