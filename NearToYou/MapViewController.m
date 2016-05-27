//
//  MapViewController.m
//  NearToYou
//
//  Created by Sagar Shirbhate on 26/05/16.
//  Copyright © 2016 Sagar Shirbhate. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "DetailsViewController.h"
#import <UIView+WebCacheOperation.h>
@interface MapViewController ()<MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MapViewController


-(void)viewWillAppear:(BOOL)animated{
    
    _mapView.delegate=self;
    
    for (int i =0; i < [_mapView.annotations count]; i++) {
        if ([[_mapView.annotations objectAtIndex:i] isKindOfClass:[MyAnnotation class]]) {
            [_mapView removeAnnotation:[_mapView.annotations objectAtIndex:i]];
        }
    }
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(_user_Lat, _user_lng);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.03, 0.03);
    MKCoordinateRegion region = {coord, span};
    [_mapView setRegion:region];
    
    
    for (int i =0; i<_resultArray.count; i++) {
        
        NSDictionary * latLOng =[[[_resultArray objectAtIndex:i]valueForKey:@"geometry" ]valueForKey:@"location"];
        double lat =[[latLOng valueForKey:@"lat"]doubleValue];
        double lon =[[latLOng valueForKey:@"lng"]doubleValue];
        
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(lat, lon);
        MyAnnotation *annotation = [MyAnnotation alloc];
        annotation.coordinate = coord;
        annotation.selectedObject=[_resultArray objectAtIndex:i];
        annotation.title = [[_resultArray objectAtIndex:i]valueForKey:@"name"];
        annotation.subtitle = [[_resultArray objectAtIndex:i]valueForKey:@"vicinity"];

        NSString * urlStringForPostImage =[[_resultArray objectAtIndex:i]valueForKey:@"icon"];
        NSURL * url =[NSURL URLWithString:urlStringForPostImage];
        if (url) {
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager downloadImageWithURL:url options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize)
             {} completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                 if(image){
                     annotation.image=image;
                 }
                 [_mapView addAnnotation:annotation];
             }];

        }
       
    }
    
}

-(void)viewWillDisappear:(BOOL)animated{
      [_mapView removeAnnotations:_mapView.annotations];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    _showUserLocBtn.titleLabel.font=[UIFont fontWithName:@"icomoon" size:25];
    _showUserLocBtn.layer.cornerRadius=25;
    _showUserLocBtn.clipsToBounds=YES;
    [_showUserLocBtn setTitle:[NSString stringWithUTF8String:"\ue909"] forState:UIControlStateNormal];

    [_showUserLocBtn addShaddow];
    

    
   
  
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    
    static NSString *AnnotationIdentifier = @"AnnotationIdentifier";
    MKPinAnnotationView *pinView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];
    pinView.animatesDrop = YES;
    
    
    if ([annotation isKindOfClass:[MyAnnotation class]]) {
        
    pinView.canShowCallout = YES;
    pinView.pinTintColor = [UIColor greenColor];
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeInfoLight];
    pinView.rightCalloutAccessoryView = rightBtn;
    [rightBtn setTitle:annotation.title forState:UIControlStateNormal];
    
    
    MyAnnotation * ann =(MyAnnotation *)annotation;
    UIImageView *profileIconView = [[UIImageView alloc] init];
    profileIconView.frame = CGRectMake(5, 5, 30, 30);
    if (ann.image) {
         profileIconView.image=ann.image;
    }
    pinView.leftCalloutAccessoryView = profileIconView;
    
    }
    return pinView;
    
}
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    DetailsViewController *objDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailsViewController"];
    MyAnnotation * ann =(MyAnnotation *)view.annotation;
    objDetailViewController.selectedObj = ann.selectedObject;
    
    objDetailViewController.user_lng=_user_lng;
    objDetailViewController.user_Lat=_user_Lat;
    
    [self.navigationController pushViewController:objDetailViewController animated:YES];
}


- (IBAction)userLocBtnClick:(id)sender {
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(_user_Lat, _user_lng);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.03, 0.03);
    MKCoordinateRegion region = {coord, span};
    [_mapView setRegion:region];
}
@end
