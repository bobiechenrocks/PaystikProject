//
//  PaystikOrgCell.h
//  PaystikNav
//
//  Created by Bobie Chen on 9/3/14.
//  Copyright (c) 2014 Bobie Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PaystikOrgViewController;

@interface PaystikOrgCell : UITableViewCell

@property (nonatomic, weak)PaystikOrgViewController* parentOrgView;

- (void)prepareOrgCell:(NSDictionary*)dictOrg;

@end
