//
//  DetailsViewController.m
//  NearToYou
//
//  Created by Sagar Shirbhate on 27/05/16.
//  Copyright © 2016 Sagar Shirbhate. All rights reserved.
//

#import "DetailsViewController.h"
#import <UIView+WebCacheOperation.h>
@interface DetailsViewController ()

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@",_selectedObj);
    
    NSDictionary * latLOng =[[_selectedObj  valueForKey:@"geometry" ]valueForKey:@"location"];
    placeLat =[[latLOng valueForKey:@"lat"]doubleValue];
    placeLan =[[latLOng valueForKey:@"lng"]doubleValue];
    
    titleLbl.text= [_selectedObj valueForKey:@"name"];
    addressLbl.text= [_selectedObj valueForKey:@"vicinity"];
    self.title=[_selectedObj valueForKey:@"name"];
    
    [imageView addShaddow];
    [onOfflbl addShaddow];
    
    NSString * urlStringForPostImage =[_selectedObj valueForKey:@"icon"];
    NSURL * url =[NSURL URLWithString:urlStringForPostImage];
    if (url) {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadImageWithURL:url options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize)
         {} completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
             if(image){
                 imageView.image=image;
             }
          
         }];
    }

    
    onOfflbl.layer.cornerRadius=65;
    onOfflbl.clipsToBounds=YES;
    
    NSDictionary * open =[_selectedObj valueForKey:@"opening_hours"];
    if (open) {
    if ([[open valueForKey:@"open_now"]intValue]==1) {
        onOfflbl.text=@"YES";
        onOfflbl.backgroundColor=[UIColor greenColor];
    }else{
        onOfflbl.text=@"NO";
        onOfflbl.backgroundColor=[UIColor redColor];
    }
    }else{
        onOfflbl.text=@"N/A";
        onOfflbl.backgroundColor=[UIColor blackColor];
    }

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

- (IBAction)goToThere:(id)sender {
    
        NSString* url = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f",_user_Lat, _user_lng, placeLat, placeLan];
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
    
}
@end
