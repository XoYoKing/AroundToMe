//
//  TableViewCell.m
//  NearToYou
//
//  Created by Sagar Shirbhate on 26/05/16.
//  Copyright © 2016 Sagar Shirbhate. All rights reserved.
//

#import "TableViewCell.h"
#import "Toast+UIView.h"
@implementation TableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    _logoLbl.font=[UIFont fontWithName:@"icomoon" size:25];
   _logoLbl.layer.cornerRadius=25;
    _logoLbl.clipsToBounds=YES;
    [_logoLbl addShaddow];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




@end
