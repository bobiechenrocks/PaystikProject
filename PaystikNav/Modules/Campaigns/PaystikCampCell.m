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
    
    CGFloat fThumbMarginLeft = 10.0f, fThumbSize = 36.0f, fThumbMarginTop = 4.0f;
    if (!self.imageThumb) {
        self.imageThumb = [[UIImageView alloc] initWithFrame:CGRectMake(fThumbMarginLeft, fThumbMarginTop, fThumbSize, fThumbSize)];
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
        frame.origin.x = fThumbMarginLeft + fThumbSize + fNameMarginLeft;
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
    if (!strURL || [strURL isEqualToString:@""]) {
        return;
    }
    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL]];
    NSOperationQueue* q = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:q completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            if (response && ((NSHTTPURLResponse*)response).statusCode == 200) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage* image = [UIImage imageWithData:data];
                    self.imageThumb.image = image;
                    
                    CGFloat fLogoSize = 36.0f, fLogoMarginLeft = 10.0f, fLogoMarginTop = 4.0f;
                    CGRect frame = self.imageThumb.frame;
                    if (image.size.height/image.size.width > 1.0f) {
                        /* portrait image */
                        frame.size.height = fLogoSize;
                        frame.size.width = fLogoSize*image.size.width / image.size.height;
                        frame.origin.x = fLogoMarginLeft + (fLogoSize - frame.size.width)/2.0f;
                        frame.origin.y = fLogoMarginTop;
                    }
                    else {
                        /* landscape */
                        frame.size.width = fLogoSize;
                        frame.size.height = fLogoSize*image.size.height / image.size.width;
                        frame.origin.y = fLogoMarginTop + (fLogoSize - frame.size.height)/2.0f;
                        frame.origin.x = fLogoMarginLeft;
                    }
                    self.imageThumb.frame = frame;
                });
            }
        }
    }];
}

@end
