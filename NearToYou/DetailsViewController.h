//
//  DetailsViewController.h
//  NearToYou
//
//  Created by Sagar Shirbhate on 27/05/16.
//  Copyright © 2016 Sagar Shirbhate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Toast+UIView.h"
@interface DetailsViewController : UIViewController

{
    double placeLat;
    double placeLan;
    __weak IBOutlet UILabel *onOfflbl;
    __weak IBOutlet UIImageView *imageView;
    __weak IBOutlet UILabel *titleLbl;
    __weak IBOutlet UILabel *addressLbl;
}

@property(assign)double user_Lat;
@property(assign)double user_lng;
@property(nonatomic,strong)NSDictionary * selectedObj;
- (IBAction)goToThere:(id)sender;
@end
