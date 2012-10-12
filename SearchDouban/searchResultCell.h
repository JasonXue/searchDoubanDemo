//
//  searchResultCell.h
//  SearchDouban
//
//  Created by zhang bruce on 12-10-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLImageView.h"

@interface searchResultCell : UITableViewCell

@property (retain, nonatomic) IBOutlet FLImageView *coverImageView;
@property (retain, nonatomic) IBOutlet UILabel *title;
@property (retain, nonatomic) IBOutlet UILabel *rate_sroce;
@property (retain, nonatomic) IBOutlet UILabel *rate_count;

-(void)loadDataInfo:(NSDictionary*)data;
@end
