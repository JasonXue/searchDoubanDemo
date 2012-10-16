//
//  searchResultCell.m
//  SearchDouban
//
//  Created by zhang bruce on 12-10-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "searchResultCell.h"
#import "MacroDef.h"

@implementation searchResultCell
@synthesize coverImageView = _coverImageView;
@synthesize title = _title;
@synthesize rate_sroce = _rate_sroce;
@synthesize rate_count = _rate_count;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.coverImageView = [[FLImageView alloc] initWithFrame:CGRectMake(5, 5, 68, 96)];
        [self addSubview:self.coverImageView];
        [self.coverImageView release];
        
        self.title = [[UILabel alloc] initWithFrame:CGRectMake(80, 5, 220, 66)];
        [self addSubview:self.title];
        [self.title release];
        
        self.rate_count = [[UILabel alloc] initWithFrame:CGRectMake(80, 80, 150, 30)];
        [self addSubview:self.rate_count];
        [self.rate_count release];
        
        self.rate_sroce = [[UILabel alloc] initWithFrame:CGRectMake(230, 80, 100, 30)];
        [self addSubview:self.rate_sroce];
        [self.rate_sroce release];
    }
    return self;
}
-(void)loadDataInfo:(NSDictionary*)data
{
//    NSLog(@"imageURL:%@", [data objectForKey:@"IMAGE_URL"]);
    [self.coverImageView loadImageAtURLString:[data objectForKey:LocalDataKEY_IMAGE_URL] placeholderImage:nil];
    
    [self.title setText:[data objectForKey:LocalDataKEY_TITLE]];
    [self.rate_count setText:[NSString stringWithFormat:@"%@人喜欢",[data objectForKey:LocalDataKEY_RATE_COUNT]]];
    [self.rate_sroce setText:[NSString stringWithFormat:@"评分:%@",[data objectForKey:LocalDataKEY_SCORE]]];

}

@end
