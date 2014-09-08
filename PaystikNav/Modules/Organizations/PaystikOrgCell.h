//
//  PaystikOrgCell.h
//  PaystikNav
//
//  Created by Bobie Chen on 9/3/14.
//  Copyright (c) 2014 Bobie Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PaystikOrgCellDelegate <NSObject>

@optional
- (void)showMapViewOfOrganizationWithLocation:(NSDictionary*)dictCoordinate andName:(NSString*)strName;
- (void)showCampOfOrganization:(NSString*)strOrgGUID;

@end

@interface PaystikOrgCell : UITableViewCell

@property (nonatomic, weak)id<PaystikOrgCellDelegate> delegate;

- (void)prepareOrgCell:(NSDictionary*)dictOrg;

@end
