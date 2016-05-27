//
//  MyAnnotation.h
//  My Map Assignment
//
//  Created by Sagar Shirbhate on 01/03/14.
//  Copyright (c) 2014 com._myCompanyName. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface MyAnnotation : NSObject<MKAnnotation>
@property (copy, nonatomic)NSString *title;
@property (copy, nonatomic)NSString *subtitle;
@property (assign, nonatomic)CLLocationCoordinate2D coordinate;
@property (nonatomic,retain) UIImage  *image;
@property(nonatomic,strong)NSDictionary * selectedObject;
@end