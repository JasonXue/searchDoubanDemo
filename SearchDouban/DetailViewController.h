//
//  DetailViewController.h
//  SearchDouban
//
//  Created by zhang bruce on 12-10-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLImageView.h"

@interface DetailViewController : UIViewController
{
    NSString* _detailApiUrl;
}

@property (retain, nonatomic) IBOutlet UIScrollView *contentScrollView;


@property (retain, nonatomic) IBOutlet FLImageView *coverImageView;
@property (retain, nonatomic) IBOutlet UILabel *titleLable;


@property (retain, nonatomic) IBOutlet UILabel *descriptionView;
@property (retain, nonatomic) IBOutlet UILabel *tagsView;
@property (retain, nonatomic) IBOutlet UIButton *returnButton;
- (void)loadViewWithURLString:(NSString*)apiUrl withImageURLString:(NSString*)imageURL;
@end
