//
//  SeaechKindViewController.h
//  SearchDouban
//
//  Created by zhang bruce on 12-10-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MacroDef.h"

typedef enum {
    SearchTypeMovie,
    SearchTypeBook,
    SearchTypeMusic
} SearchType;


@interface SeaechKindViewController : UIViewController<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray* _dataSource;
    NSString* _currentSearchText;
    SearchType _currentSearchType;
    SearchType _lastSearchType;
    BOOL _anyMoreInfo;
    NSInteger _currentResultCount;
}
@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;
@property (retain, nonatomic) IBOutlet UITableView *tableView;

@property (retain, nonatomic) IBOutlet UIBarButtonItem *searchMoiveButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *searchBooksButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *searchMusicButton;

@end
