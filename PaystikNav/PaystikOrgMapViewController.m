//
//  PaystikOrgMapViewController.m
//  PaystikNav
//
//  Created by Bobie Chen on 9/5/14.
//  Copyright (c) 2014 Bobie Chen. All rights reserved.
//

#import "PaystikOrgMapViewController.h"

@interface PaystikOrgMapViewController () <MKMapViewDelegate>

/* UI elements */
@property (nonatomic, strong) MKMapView* mapView;

@end

@implementation PaystikOrgMapViewController

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

- (void)prepareMapViewWithLocation:(NSDictionary*)dictCoordinate andName:(NSString*)strName
{
    self.title = @"Location";
    
    UIBarButtonItem* closeBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                    target:self action:@selector(closeMapView)];
    self.navigationItem.rightBarButtonItem = closeBarButton;
    
    if (!self.mapView) {
        self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0.0f, 64.0f, self.view.frame.size.width, self.view.frame.size.height)];
        [self.view addSubview:self.mapView];

        self.mapView.delegate = self;
    }
    
    MKPointAnnotation* annotatePoint = [[MKPointAnnotation alloc] init];
    float fLat = 0.0f, fLong = 0.0f;
    if (dictCoordinate[@"latitude"]) {
        fLat = [dictCoordinate[@"latitude"] floatValue];
    }
    if (dictCoordinate[@"longitude"]) {
        fLong = [dictCoordinate[@"longitude"] floatValue];
    }
    annotatePoint.coordinate = CLLocationCoordinate2DMake(fLat, fLong);
    annotatePoint.title = strName;
    
    [self.mapView addAnnotation:annotatePoint];
    double delayInSeconds = 0.3f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.mapView selectAnnotation:annotatePoint animated:YES];
        
        MKCoordinateRegion regionCenter = MKCoordinateRegionMake(annotatePoint.coordinate, MKCoordinateSpanMake(0.01, 0.01));
        regionCenter = [self.mapView regionThatFits:regionCenter];
        [self.mapView setRegion:regionCenter animated:YES];
    });
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    static NSString *reuseId = @"pin";
    MKPinAnnotationView *pav = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    if (!pav) {
        pav = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
    }
    else {
        pav.annotation = annotation;
    }
    
    pav.pinColor = MKPinAnnotationColorGreen;
    pav.canShowCallout = YES;
    pav.animatesDrop = NO;
    
    return pav;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    
}

- (void)closeMapView
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
