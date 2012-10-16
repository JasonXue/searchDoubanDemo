//
//  DetailViewController.m
//  SearchDouban
//
//  Created by zhang bruce on 12-10-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "SBJson.h"
#import "MacroDef.h"
@interface DetailViewController ()

@end

@implementation DetailViewController
@synthesize contentScrollView = _contentScrollView;
@synthesize titleLable = _titleLable;
@synthesize coverImageView = _coverImageView;
@synthesize descriptionView = _descriptionView;
@synthesize tagsView = _tagsView;
@synthesize returnButton = _returnButton;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _contentScrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
        _contentScrollView.contentSize = CGSizeMake(self.view.frame.size.width, 530);
        [self.view addSubview:_contentScrollView];
        [_contentScrollView release];
        
        
        _coverImageView = [[FLImageView alloc] initWithFrame:CGRectMake(20, 5, 68, 96)];
        [_contentScrollView addSubview:_coverImageView];
        [_coverImageView release];
        
        _titleLable = [[UILabel alloc] initWithFrame:CGRectMake(90, 5, 220, 96)];
        _titleLable.textAlignment = UITextAlignmentCenter; 
        _titleLable.lineBreakMode = UILineBreakModeWordWrap;
        _titleLable.numberOfLines = 0; 
        [_contentScrollView addSubview:_titleLable];
        [_titleLable release];
        
        _descriptionView = [[UILabel alloc] initWithFrame:CGRectMake(10, 120, 300, 48)];
        _descriptionView.textAlignment = UITextAlignmentLeft; 
        _descriptionView.lineBreakMode = UILineBreakModeWordWrap;
        _descriptionView.numberOfLines = 0; 
        [_descriptionView setFont:[UIFont systemFontOfSize:12]];
        [_contentScrollView addSubview:_descriptionView];
        [_descriptionView release];
/*        
        _tagsView = [[UILabel alloc] initWithFrame:CGRectMake(10, 432, 300, 50)];
        [_contentScrollView addSubview:_tagsView];
        [_tagsView release];
*/        
        _returnButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_returnButton setTitle:@"返回" forState:UIControlStateNormal];
        [_returnButton addTarget:self action:@selector(returnButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _returnButton.frame = CGRectMake(10, 490, 300, 30);
        [_contentScrollView addSubview:_returnButton];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)loadViewWithURLString:(NSString*)apiUrl withImageURLString:(NSString*)imageURL
{
    _detailApiUrl = [apiUrl stringByAppendingString:@"?alt=json"];
    NSError* err = nil;
    NSString* responseStr = [NSString stringWithContentsOfURL:[NSURL URLWithString:_detailApiUrl] encoding:NSUTF8StringEncoding error:&err];
    NSLog(@"SelectProduct:%@", responseStr);
    SBJsonParser * parser = [[SBJsonParser alloc] init];
    NSError* error = nil;
    NSMutableDictionary* detailDic = [parser objectWithString:responseStr error:&error]; 
    [parser release];
    
    NSString* titleString = [[detailDic objectForKey:DoubanKEY_TITLE] objectForKey:DoubanKEY_VALUE];
    NSString* descriptionString = [[detailDic objectForKey:DoubanKEY_SUMMARY] objectForKey:DoubanKEY_VALUE];
    
    [self.coverImageView loadImageAtURLString:imageURL placeholderImage:nil];
    [self.titleLable setText:titleString];
    [self.descriptionView setText:descriptionString];
    /* 计算高度 */
    CGSize boundingSize = CGSizeMake(300, CGFLOAT_MAX);
    CGSize requiredSize = [descriptionString sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:boundingSize lineBreakMode:UILineBreakModeWordWrap];
    [self.descriptionView setFrame:CGRectMake(self.descriptionView.frame.origin.x, 
                                             self.descriptionView.frame.origin.y, 
                                             self.descriptionView.frame.size.width, 
                                             requiredSize.height)];
    [self.returnButton setFrame:CGRectMake(self.returnButton.frame.origin.x, 
                                          self.descriptionView.frame.origin.y + requiredSize.height + 10, 
                                          self.returnButton.frame.size.width, 
                                          self.returnButton.frame.size.height)];
    self.contentScrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.returnButton.frame.origin.y +35);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}
-(void)returnButtonPressed:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}


@end
