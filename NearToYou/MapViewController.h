//
//  MapViewController.h
//  NearToYou
//
//  Created by Sagar Shirbhate on 26/05/16.
//  Copyright © 2016 Sagar Shirbhate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyAnnotation.h"

@interface MapViewController : UIViewController

@property(assign)double user_Lat;
@property(assign)double user_lng;


@property(nonatomic,strong)NSMutableArray * resultArray;
@property (weak, nonatomic) IBOutlet UIButton *showUserLocBtn;
- (IBAction)userLocBtnClick:(id)sender;
@end
