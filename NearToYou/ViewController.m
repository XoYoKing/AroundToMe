//
//  ViewController.m
//  NearToYou
//
//  Created by Sagar Shirbhate on 26/05/16.
//  Copyright © 2016 Sagar Shirbhate. All rights reserved.
//

#import "ViewController.h"
#import "TableViewCell.h"
#import "MapViewController.h"
#import "Reachability.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "Toast+UIView.h"

#define ICOMOON_CHECK "\ue904"

@interface ViewController ()<UIAlertViewDelegate>

@end

@implementation ViewController

-(void)viewWillAppear:(BOOL)animated{
    [self setDataArray];
    ResultArray=[NSMutableArray new];
    _mainTableView.tableFooterView=[UIView new];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont
                                                                           fontWithName:@"TrebuchetMS" size:18], NSFontAttributeName,
                                [UIColor blackColor], NSForegroundColorAttributeName, nil];
    
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    if ( [CLLocationManager locationServicesEnabled] ==NO || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        UIAlertView *locationAlert = [[UIAlertView alloc] initWithTitle:@"Location Service Disabled"
                                                                message:@"To re-enable, please go to Settings and turn on Location Service for this app."
                                                               delegate:self
                                                      cancelButtonTitle:@"Settings"
                                                      otherButtonTitles:nil];
        [locationAlert show];
    }else{
        NSLog(@"YES");
    }
    
    
    
    searchBTN.titleLabel.font=[UIFont fontWithName:@"icomoon" size:25];
    searchBTN.layer.cornerRadius=20;
    searchBTN.clipsToBounds=YES;
    [searchBTN setTitle:[NSString stringWithUTF8String:"\ue925"] forState:UIControlStateNormal];
}

-(void)refreshLocation{
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    if ( [CLLocationManager locationServicesEnabled] ==NO || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        UIAlertView *locationAlert = [[UIAlertView alloc] initWithTitle:@"Location Service Disabled"
                                                                message:@"To re-enable, please go to Settings and turn on Location Service for this app."
                                                               delegate:self
                                                      cancelButtonTitle:@"Settings"
                                                      otherButtonTitles:nil];
        [locationAlert show];
    }else{
        NSLog(@"YES");
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshLocation) name:@"refreshLocation" object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   return  globalAray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TableViewCell * cell =[_mainTableView dequeueReusableCellWithIdentifier:@"TableViewCell" forIndexPath:indexPath];
    NSDictionary * dict =[globalAray objectAtIndex:indexPath.row];
    cell.titleLbl.text=[dict valueForKey:@"Key"];
    cell.logoLbl.text=[dict valueForKey:@"image"] ;
    cell.logoLbl.backgroundColor=[self getUIColorObjectFromHexString:[dict valueForKey:@"Color"] alpha:0.9];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
    selectedTypeDict =[_dataArr objectAtIndex:indexPath.row];
    NSString * statusMsg = [NSString stringWithFormat:@"Loading %@",[selectedTypeDict valueForKey:@"Key"]];
     [JDStatusBarNotification showWithStatus:statusMsg styleName:@"JDStatusBarStyleDark"];
     NSString * type =[selectedTypeDict valueForKey:@"value"];
    
    if (longitude&&latitude) {
        mainUrl= [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%@,%@&radius=1000&sensor=true&types=%@&key=AIzaSyA5AGzM9KAvTbBbfuoZwQel4XrTrvYoQuo",latitude,longitude,type];
        
        [self performSelectorInBackground:@selector(getDataFromUrl:) withObject:mainUrl];
    }else{
        UIAlertView *locationAlert = [[UIAlertView alloc] initWithTitle:@"Location Service Disabled"
                                                                message:@"To re-enable, please go to Settings and turn on Location Service for this app."
                                                               delegate:self
                                                      cancelButtonTitle:@"Settings"
                                                      otherButtonTitles:nil];
        [locationAlert show];
    }
    
    
    
}

-(void)getDataFromUrl:(NSString *)url{
    NSDictionary * dict = [self getDataFromWebservice:mainUrl];
    if (dict) {
        [self performSelectorOnMainThread:@selector(parseAndUpdateView:) withObject:dict waitUntilDone:YES];
    }
}
-(void)parseAndUpdateView:(NSDictionary *)dict{
    NSLog(@"%@",dict);
    NSMutableArray * arr =[[NSMutableArray alloc]initWithArray:[dict valueForKey:@"results"]];
    [ResultArray addObjectsFromArray:arr];
    if (ResultArray.count!=0) {
        MapViewController * vc =[self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
        vc.resultArray=ResultArray;
        vc.user_Lat=[latitude doubleValue];
        vc.user_lng =[longitude doubleValue];
        vc.title=[NSString stringWithFormat:@"%@",[selectedTypeDict valueForKey:@"Key"]];
        [self.navigationController pushViewController:vc animated:YES];
        
        ResultArray=[NSMutableArray new];
        selectedTypeDict=nil;
    }else{
        NSString * msg =[NSString stringWithFormat:@"No %@ Found in this area.",[selectedTypeDict valueForKey:@"Key"]];
           [self.view makeToast:msg duration:2 position:@"bottom"];
    }
    [JDStatusBarNotification dismiss];
}



-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    NSLog(@"didUpdateLocations");
    CLLocation *lo = [locations objectAtIndex:0];
    NSLog(@"latitude = %f, longitude = %f", lo.coordinate.latitude, lo.coordinate.longitude);
    latitude=[NSString stringWithFormat:@"%f",lo.coordinate.latitude];
    longitude=[NSString stringWithFormat:@"%f",lo.coordinate.longitude];
    [manager stopUpdatingHeading];
}
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    NSLog(@"didUpdateToLocation");}
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"didFailWithError");
    [manager stopUpdatingLocation];
}

-(void)setDataArray{
    self.title=@"Select Place AroundToMe";
    _dataArr =[[NSMutableArray alloc]initWithObjects:
               
               @{@"Key":@"Accountants ",
                 @"image":[NSString stringWithUTF8String:"\ue91a"],
                 @"Color":@"349a5d",
                 @"value":@"accounting"} ,
               
               @{@"Key":@"Airports ",
                 @"image":[NSString stringWithUTF8String:"\ue909"],
                 @"Color":@"8a95af",
                 @"value":@"airport"} ,
               
               @{@"Key":@"Amusment Park ",
                 @"image":[NSString stringWithUTF8String:"\ue91f"],
                 @"Color":@"9ef87c",
                 @"value":@"amusement_park"} ,
               
               @{@"Key":@"Aquarium ",
                 @"image":[NSString stringWithUTF8String:"\ue91f"],
                 @"Color":@"00f883",
                 @"value":@"aquarium"} ,
               
               @{@"Key":@"Art Gallery",
                 @"image":[NSString stringWithUTF8String:"\ue91c"],
                 @"Color":@"4d96be",
                 @"value":@"art_gallery"} ,
               
               @{@"Key":@"ATM ",
                 @"image":[NSString stringWithUTF8String:"\ue91a"],
                 @"Color":@"7ae8b6",
                 @"value":@"atm"} ,
               
               @{@"Key":@"Bakery ",
                 @"image":[NSString stringWithUTF8String:"\ue909"],
                 @"Color":@"4356e5",
                 @"value":@"bakery"} ,
               
               @{@"Key":@"Bank ",
                 @"image":[NSString stringWithUTF8String:"\ue91a"],
                 @"Color":@"ca2e8e",
                 @"value":@"bank"} ,
               
               @{@"Key":@"Bar",
                 @"image":[NSString stringWithUTF8String:"\ue907"],
                 @"Color":@"0f6fb1",
                 @"value":@"bar"} ,
               
               @{@"Key":@"Salon",
                 @"image":[NSString stringWithUTF8String:"\ue902"],
                 @"Color":@"11184f",
                 @"value":@"beauty_salon"} ,
               
               @{@"Key":@"Bicycle Store ",
                 @"image":[NSString stringWithUTF8String:"\ue909"],
                 @"Color":@"d22a66",
                 @"value":@"bicycle_store"} ,
               
               @{@"Key":@"Book Store ",
                 @"image":[NSString stringWithUTF8String:"\ue909"],
                 @"Color":@"50a4f7",
                 @"value":@"book_store"} ,
               
               @{@"Key":@"Bowling Alley",
                 @"image":[NSString stringWithUTF8String:"\ue905"],
                 @"Color":@"8d8803",
                 @"value":@"bowling_alley"} ,
               
               @{@"Key":@"Bus Station ",
                 @"image":[NSString stringWithUTF8String:"\ue900"],
                 @"Color":@"87d488",
                 @"value":@"bus_station"} ,
               
               @{@"Key":@"Cafe ",
                 @"image":[NSString stringWithUTF8String:"\ue904"],
                 @"Color":@"3f8988",
                 @"value":@"cafe"} ,
               
               @{@"Key":@"Campground ",
                 @"image":[NSString stringWithUTF8String:"\ue909"],
                 @"Color":@"b5a602",
                 @"value":@"campground"} ,
               
               @{@"Key":@"Car Dealer ",
                 @"image":[NSString stringWithUTF8String:"\ue910"],
                 @"Color":@"0a7839",
                 @"value":@"car_dealer"} ,
               
               @{@"Key":@"Car Rental",
                 @"image":[NSString stringWithUTF8String:"\ue910"],
                 @"Color":@"fb67a7",
                 @"value":@"car_rental"} ,
               
               @{@"Key":@"Car Repair",
                 @"image":[NSString stringWithUTF8String:"\ue910"],
                 @"Color":@"aabf8f",
                 @"value":@"car_repair"} ,
               
               @{@"Key":@"Car Wash",
                 @"image":[NSString stringWithUTF8String:"\ue910"],
                 @"Color":@"1880f1",
                 @"value":@"car_wash"} ,
               
               @{@"Key":@"Casino",
                 @"image":[NSString stringWithUTF8String:"\ue91c"],
                 @"Color":@"43a9cd",
                 @"value":@"casino"} ,
               
               @{@"Key":@"Cemetery",
                 @"image":[NSString stringWithUTF8String:"\ue90e"],
                 @"Color":@"2c3b23",
                 @"value":@"cemetery"} ,
               
               @{@"Key":@"Church",
                 @"image":[NSString stringWithUTF8String:"\ue90e"],
                 @"Color":@"d336f4",
                 @"value":@"church"} ,
               
               @{@"Key":@"City Hall",
                 @"image":[NSString stringWithUTF8String:"\ue91a"],
                 @"Color":@"379a3e",
                 @"value":@"city_hall"} ,
               
               @{@"Key":@"Clothing Store",
                 @"image":[NSString stringWithUTF8String:"\ue909"],
                 @"Color":@"5a6603",
                 @"value":@"clothing_store"} ,
               
               @{@"Key":@"Convenience Store",
                 @"image":[NSString stringWithUTF8String:"\ue909"],
                 @"Color":@"3a9b41",
                 @"value":@"convenience_store"} ,
               
               @{@"Key":@"Courthouse",
                 @"image":[NSString stringWithUTF8String:"\ue909"],
                 @"Color":@"d839fa",
                 @"value":@"courthouse"} ,
               
               @{@"Key":@"Dentist",
                 @"image":[NSString stringWithUTF8String:"\ue917"],
                 @"Color":@"558c70",
                 @"value":@"dentist"} ,
               
               @{@"Key":@"Department Store",
                 @"image":[NSString stringWithUTF8String:"\ue909"],
                 @"Color":@"47d344",
                 @"value":@"department_store"} ,
               
               @{@"Key":@"Doctor",
                 @"image":[NSString stringWithUTF8String:"\ue922"],
                 @"Color":@"114ba4",
                 @"value":@"doctor"} ,
               
               @{@"Key":@"Electrician",
                 @"image":[NSString stringWithUTF8String:"\ue91b"],
                 @"Color":@"42d095",
                 @"value":@"electrician"} ,
               
               @{@"Key":@"Electronics Store",
                 @"image":[NSString stringWithUTF8String:"\ue91b"],
                 @"Color":@"9e2f2e",
                 @"value":@"electronics_store"} ,
               
               @{@"Key":@"Embassy",
                 @"image":[NSString stringWithUTF8String:"\ue909"],
                 @"Color":@"e97c31",
                 @"value":@"embassy"} ,
               
               @{@"Key":@"Fire Station",
                 @"image":[NSString stringWithUTF8String:"\ue909"],
                 @"Color":@"f131af",
                 @"value":@"fire_station"} ,
               
               @{@"Key":@"Florist",
                 @"image":[NSString stringWithUTF8String:"\ue909"],
                 @"Color":@"b84fa6",
                 @"value":@"florist"} ,
               
               @{@"Key":@"Funeral Home",
                 @"image":[NSString stringWithUTF8String:"\ue90e"],
                 @"Color":@"5d225b",
                 @"value":@"funeral_home"} ,
               
               @{@"Key":@"Furniture Store",
                 @"image":[NSString stringWithUTF8String:"\ue909"],
                 @"Color":@"a01147",
                 @"value":@"furniture_store"} ,
               
               @{@"Key":@"Gas Station",
                 @"image":[NSString stringWithUTF8String:"\ue923"],
                 @"Color":@"a06aad",
                 @"value":@"gas_station"} ,
               
               @{@"Key":@"GYM",
                 @"image":[NSString stringWithUTF8String:"\ue91d"],
                 @"Color":@"5e2b8d",
                 @"value":@"gym"} ,
               
               @{@"Key":@"Hair Care",
                 @"image":[NSString stringWithUTF8String:"\ue922"],
                 @"Color":@"d955e7",
                 @"value":@"hair_care"} ,
               
               @{@"Key":@"Hardware Store",
                 @"image":[NSString stringWithUTF8String:"\ue918"],
                 @"Color":@"13e8bb",
                 @"value":@"hardware_store"} ,
               
               @{@"Key":@"Hindu Temple",
                 @"image":[NSString stringWithUTF8String:"\ue916"],
                 @"Color":@"c047d1",
                 @"value":@"hindu_temple"} ,
               
               @{@"Key":@"Home Goods Store",
                 @"image":[NSString stringWithUTF8String:"\ue91c"],
                 @"Color":@"331414",
                 @"value":@"home_goods_store"} ,
               
               @{@"Key":@"Hospital",
                 @"image":[NSString stringWithUTF8String:"\ue922"],
                 @"Color":@"644ad0",
                 @"value":@"hospital"} ,
               
               @{@"Key":@"Insurance Agency",
                 @"image":[NSString stringWithUTF8String:"\ue909"],
                 @"Color":@"53e807",
                 @"value":@"insurance_agency"} ,
               
               @{@"Key":@"Jewelry Store",
                 @"image":[NSString stringWithUTF8String:"\ue909"],
                 @"Color":@"b483ca",
                 @"value":@"jewelry_store"} ,
               
               @{@"Key":@"Laundry",
                 @"image":[NSString stringWithUTF8String:"\ue909"],
                 @"Color":@"9bc5e9",
                 @"value":@"laundry"} ,
               
               @{@"Key":@"Lawyer",
                 @"image":[NSString stringWithUTF8String:"\ue914"],
                 @"Color":@"3f6f82",
                 @"value":@"lawyer"} ,
               
               @{@"Key":@"Library",
                 @"image":[NSString stringWithUTF8String:"\ue909"],
                 @"Color":@"a18295",
                 @"value":@"library"} ,
               
               @{@"Key":@"Liquor Store",
                 @"image":[NSString stringWithUTF8String:"\ue907"],
                 @"Color":@"c1fd22",
                 @"value":@"liquor_store"} ,
               
               @{@"Key":@"Local Government Office",
                 @"image":[NSString stringWithUTF8String:"\ue909"],
                 @"Color":@"9ee229",
                 @"value":@"local_government_office"} ,
               
               @{@"Key":@"Locksmith",
                 @"image":[NSString stringWithUTF8String:"\ue909"],
                 @"Color":@"3a2faa",
                 @"value":@"locksmith"} ,
               
               
               @{@"Key":@"Lodging",
                 @"image":[NSString stringWithUTF8String:"\ue919"],
                 @"Color":@"93e5a6",
                 @"value":@"lodging"} ,
               
               @{@"Key":@"Meal Delivery",
                 @"image":[NSString stringWithUTF8String:"\ue909"],
                 @"Color":@"bbaa13",
                 @"value":@"meal_delivery"} ,
               
               @{@"Key":@"Meal Takeaway",
                 @"image":[NSString stringWithUTF8String:"\ue909"],
                 @"Color":@"9866fe",
                 @"value":@"meal_takeaway"} ,
               
               @{@"Key":@"Movie Rental",
                 @"image":[NSString stringWithUTF8String:"\ue90b"],
                 @"Color":@"113f21",
                 @"value":@"movie_rental"} ,
               
               @{@"Key":@"Movie Theater",
                 @"image":[NSString stringWithUTF8String:"\ue90b"],
                 @"Color":@"4881bd",
                 @"value":@"movie_theater"} ,
               
               @{@"Key":@"Moving Company",
                 @"image":[NSString stringWithUTF8String:"\ue90b"],
                 @"Color":@"3d2bd4",
                 @"value":@"moving_company"} ,
               
               @{@"Key":@"Museum",
                 @"image":[NSString stringWithUTF8String:"\ue91a"],
                 @"Color":@"f03f65",
                 @"value":@"museum"} ,

               @{@"Key":@"Night Club",
                 @"image":[NSString stringWithUTF8String:"\ue909"],
                 @"Color":@"60bb70",
                 @"value":@"night_club"} ,

               @{@"Key":@"Painter",
                 @"image":[NSString stringWithUTF8String:"\ue90c"],
                 @"Color":@"8fa0f5",
                 @"value":@"painter"} ,

               @{@"Key":@"Parking",
                 @"image":[NSString stringWithUTF8String:"\ue921"],
                 @"Color":@"7bedf4",
                 @"value":@"parking"} ,

               @{@"Key":@"Park",
                 @"image":[NSString stringWithUTF8String:"\ue913"],
                 @"Color":@"25a46e",
                 @"value":@"park"} ,

               @{@"Key":@"Pet Store",
                 @"image":[NSString stringWithUTF8String:"\ue90d"],
                 @"Color":@"8dc361",
                 @"value":@"pet_store"} ,

               @{@"Key":@"Pharmacy",
                 @"image":[NSString stringWithUTF8String:"\ue922"],
                 @"Color":@"59e15a",
                 @"value":@"pharmacy"} ,
               

               @{@"Key":@"Physiotherapist",
                 @"image":[NSString stringWithUTF8String:"\ue922"],
                 @"Color":@"b9a336",
                 @"value":@"physiotherapist"} ,
               
               @{@"Key":@"Plumber",
                 @"image":[NSString stringWithUTF8String:"\ue91b"],
                 @"Color":@"d6ce8c",
                 @"value":@"plumber"} ,
               
               @{@"Key":@"Police",
                 @"image":[NSString stringWithUTF8String:"\ue91a"],
                 @"Color":@"b1615c",
                 @"value":@"police"} ,
               
               @{@"Key":@"Post Office",
                 @"image":[NSString stringWithUTF8String:"\ue91a"],
                 @"Color":@"4a5ea6",
                 @"value":@"post_office"} ,
               
               @{@"Key":@"Real Estate Agency",
                 @"image":[NSString stringWithUTF8String:"\ue91a"],
                 @"Color":@"a1c36a",
                 @"value":@"real_estate_agency"} ,
               
               @{@"Key":@"Restaurant",
                 @"image":[NSString stringWithUTF8String:"\ue909"],
                 @"Color":@"88c760",
                 @"value":@"restaurant"} ,
               
               @{@"Key":@"Roofing Contractor",
                 @"image":[NSString stringWithUTF8String:"\ue909"],
                 @"Color":@"b691a8",
                 @"value":@"roofing_contractor"} ,
               
               @{@"Key":@"School",
                 @"image":[NSString stringWithUTF8String:"\ue900"],
                 @"Color":@"186792",
                 @"value":@"school"} ,
               
               @{@"Key":@"Shoe Store",
                 @"image":[NSString stringWithUTF8String:"\ue915"],
                 @"Color":@"676f3e",
                 @"value":@"shoe_store"} ,
               
               @{@"Key":@"Shopping Mall",
                 @"image":[NSString stringWithUTF8String:"\ue909"],
                 @"Color":@"73e065",
                 @"value":@"shopping_mall"} ,
               
               @{@"Key":@"Spa",
                 @"image":[NSString stringWithUTF8String:"\ue902"],
                 @"Color":@"5e0548",
                 @"value":@"spa"} ,
               
               @{@"Key":@"Stadium",
                 @"image":[NSString stringWithUTF8String:"\ue915"],
                 @"Color":@"e54863",
                 @"value":@"stadium"} ,
               
               @{@"Key":@"Storage",
                 @"image":[NSString stringWithUTF8String:"\ue909"],
                 @"Color":@"2bf3f8",
                 @"value":@"storage"} ,
               
               
               @{@"Key":@"Store",
                 @"image":[NSString stringWithUTF8String:"\ue909"],
                 @"Color":@"2f0706",
                 @"value":@"store"} ,
               
               
               @{@"Key":@"Subway Station",
                 @"image":[NSString stringWithUTF8String:"\ue900"],
                 @"Color":@"f0838f",
                 @"value":@"subway_station"} ,
               
               
               @{@"Key":@"Taxi Stand",
                 @"image":[NSString stringWithUTF8String:"\ue900"],
                 @"Color":@"6f6992",
                 @"value":@"taxi_stand"} ,
               
               @{@"Key":@"Train Station",
                 @"image":[NSString stringWithUTF8String:"\ue900"],
                 @"Color":@"acb70f",
                 @"value":@"train_station"} ,
               
               @{@"Key":@"Transit Station",
                 @"image":[NSString stringWithUTF8String:"\ue900"],
                 @"Color":@"a76e06",
                 @"value":@"transit_station"} ,
               
               @{@"Key":@"Travel Agency",
                 @"image":[NSString stringWithUTF8String:"\ue900"],
                 @"Color":@"608e77",
                 @"value":@"travel_agency"} ,
               
               @{@"Key":@"University",
                 @"image":[NSString stringWithUTF8String:"\ue91a"],
                 @"Color":@"d61663",
                 @"value":@"university"} ,
               
               @{@"Key":@"Veterinary Care",
                 @"image":[NSString stringWithUTF8String:"\ue909"],
                 @"Color":@"0b07c8",
                 @"value":@"veterinary_care"} ,
               
               @{@"Key":@"Zoo",
                 @"image":[NSString stringWithUTF8String:"\ue90d"],
                 @"Color":@"1eadea",
                 @"value":@"zoo"} ,
               
               
               nil
               
               ];
    
    globalAray =[[NSMutableArray alloc]initWithArray:_dataArr];
}




- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}
-(NSDictionary *)getDataFromWebservice:(NSString *)urlString{
    
    if ([self connected]) {
//        urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        NSURL * url =[NSURL URLWithString:urlString];
        if (url==nil) {
            return nil;
        }
        NSData * data = [NSData dataWithContentsOfURL:url];
        NSError *e = nil;
        if (data!=nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &e];
            return dict;
        }else{
            return nil;
        }
    }else{
        return nil;
    }
}


#pragma mark - TextField Delegates

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    if (![textField.text isEqualToString:@""]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Key CONTAINS[cd] %@", textField.text];
        globalAray = [[_dataArr filteredArrayUsingPredicate:predicate] mutableCopy];
        [_mainTableView reloadData];
    }else{
        globalAray=_dataArr;
        [_mainTableView reloadData];
    }
    return YES;
}
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * searchStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([searchStr isEqualToString:@""]) {
        globalAray=_dataArr;
        [_mainTableView reloadData];
        textField.text=@"";
        textField.text=searchStr;
    }else{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Key CONTAINS[cd] %@", searchStr];
        globalAray = [[_dataArr filteredArrayUsingPredicate:predicate] mutableCopy];
        [_mainTableView reloadData];
    }
    return YES;
}

- (BOOL) textFieldShouldClear:(UITextField *)textField{
    globalAray=_dataArr;
    [_mainTableView reloadData];
    textField.text=@"";
    return YES;
}

- (IBAction)searchClick:(id)sender {
    if ([searchTF.text isEqualToString:@""]) {
    [self.view makeToast:@"Please add some text in search textfield" duration:2 position:@"bottom"];
    }
}


- (UIColor *)getUIColorObjectFromHexString:(NSString *)hexStr alpha:(CGFloat)alpha
{
    // Convert hex string to an integer
    unsigned int hexint = [self intFromHexString:hexStr];
    
    // Create color object, specifying alpha as well
    UIColor *color =
    [UIColor colorWithRed:((CGFloat) ((hexint & 0xFF0000) >> 16))/255
                    green:((CGFloat) ((hexint & 0xFF00) >> 8))/255
                     blue:((CGFloat) (hexint & 0xFF))/255
                    alpha:alpha];
    
    return color;
}
- (unsigned int)intFromHexString:(NSString *)hexStr
{
    unsigned int hexInt = 0;
    
    // Create scanner
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    
    // Tell scanner to skip the # character
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    
    // Scan hex value
    [scanner scanHexInt:&hexInt];
    
    return hexInt;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

@end
