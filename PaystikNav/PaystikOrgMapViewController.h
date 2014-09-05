//
//  PaystikOrgMapViewController.h
//  PaystikNav
//
//  Created by Bobie Chen on 9/5/14.
//  Copyright (c) 2014 Bobie Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface PaystikOrgMapViewController : UIViewController

- (void)prepareMapViewWithLocation:(NSDictionary*)dictCoordinate andName:(NSString*)strName;

@end
