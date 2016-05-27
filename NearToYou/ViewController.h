//
//  ViewController.h
//  NearToYou
//
//  Created by Sagar Shirbhate on 26/05/16.
//  Copyright © 2016 Sagar Shirbhate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#include "JDStatusBarNotification.h"

@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate,UITextFieldDelegate>

{
    NSString * latitude;
    NSString * longitude;
    NSString * mainUrl;
    NSMutableArray * ResultArray;
    NSDictionary * selectedTypeDict;
    NSMutableArray * globalAray;
    __weak IBOutlet UITextField *searchTF;
    __weak IBOutlet UIButton *searchBTN;
}

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property(strong,nonatomic)NSMutableArray * dataArr;
- (IBAction)searchClick:(id)sender;




@end

