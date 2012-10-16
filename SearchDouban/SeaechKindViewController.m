//
//  SeaechKindViewController.m
//  SearchDouban
//
//  Created by zhang bruce on 12-10-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SeaechKindViewController.h"
#import "SBJson.h"
#import "ASIFormDataRequest.h"
#import "searchResultCell.h"
#import "DetailViewController.h"

@interface SeaechKindViewController ()

@end

@implementation SeaechKindViewController
@synthesize searchBar = _searchBar;
@synthesize tableView = _tableView;
@synthesize searchMoiveButton = _searchMoiveButton;
@synthesize searchBooksButton = _searchBooksButton;
@synthesize searchMusicButton = _searchMusicButton;

#pragma ButtonTouchAction

- (IBAction)searchMoiveTouched:(id)sender {
    _currentSearchType = SearchTypeMovie;
    _searchBar.placeholder = SEARCH_MOIVE_STRING;
    [_searchBooksButton setStyle:UIBarButtonItemStyleBordered];
    [_searchMusicButton setStyle:UIBarButtonItemStyleBordered];
    [_searchMoiveButton setStyle:UIBarButtonItemStyleDone];
}

- (IBAction)searchBooksTouched:(id)sender {
    _currentSearchType = SearchTypeBook;
    _searchBar.placeholder = SEARCH_BOOK_STRING;
    [_searchBooksButton setStyle:UIBarButtonItemStyleDone];
    [_searchMusicButton setStyle:UIBarButtonItemStyleBordered];
    [_searchMoiveButton setStyle:UIBarButtonItemStyleBordered];
}

- (IBAction)SearchMusicTouched:(id)sender {
    _currentSearchType = SearchTypeMusic;
    _searchBar.placeholder = SEARCH_MUSIC_STRING;
    [_searchBooksButton setStyle:UIBarButtonItemStyleBordered];
    [_searchMusicButton setStyle:UIBarButtonItemStyleDone];
    [_searchMoiveButton setStyle:UIBarButtonItemStyleBordered];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _dataSource = nil;
    // Do any additional setup after loading the view from its nib.
    self.searchBar.delegate = self;
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.searchBar.placeholder = SEARCH_MOIVE_STRING;
    self.searchBar.keyboardType = UIKeyboardTypeDefault;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    _currentSearchType = SearchTypeMovie;
    _lastSearchType = SearchTypeNone;
    _anyMoreInfo = FALSE;
    _currentResultCount = 0;
    _currentSearchText = nil;
    _totalResult = 0;
    [_searchMoiveButton setStyle:UIBarButtonItemStyleDone];
}



- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [self setTableView:nil];
    [self setSearchMoiveButton:nil];
    [self setSearchBooksButton:nil];
    [self setSearchMusicButton:nil];
    if (_dataSource != nil) {
        [_dataSource removeAllObjects];
        [_dataSource release];
        _dataSource = nil;
    }
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [_searchBar release];
    [_tableView release];
    [_searchMoiveButton release];
    [_searchBooksButton release];
    [_searchMusicButton release];
    [super dealloc];
}

#pragma UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar                     // called when keyboard search button pressed
{
    NSLog(@"Search:%@",searchBar.text);
    if (_currentSearchText != nil) {
        [_currentSearchText release];
    }
    _currentSearchText = [searchBar.text copy];
    [_dataSource removeAllObjects];
    _currentResultCount = 0;
    if(_dataSource == nil) {
        _dataSource = [NSMutableArray new];
    }
    [self doSearchWithText:_currentSearchText withSearchType:_currentSearchType withCurrentResultCount:0];
    _lastSearchType = _currentSearchType;
    [searchBar resignFirstResponder];
    [searchBar setText:@""];
}

-(void)doSearchWithText:(NSString*)text withSearchType:(SearchType)searchType withCurrentResultCount:(NSInteger)currentResultCount
{

    NSString* searchAPI;
    switch (searchType) {
        case SearchTypeBook:
            searchAPI = SEARCH_BOOK_API;
            break;
        case SearchTypeMovie:
            searchAPI = SEARCH_MOVIE_API;
            break;
        case SearchTypeMusic:
            searchAPI = SEARCH_MUSIC_API;
            break;
        default:
            searchAPI = SEARCH_MOVIE_API;
            break;
    }
    NSString* urlWithGetRequest = [NSString stringWithFormat:@"%@?q=%@&start-index=%d&max-results=%d&alt=json", searchAPI, text,currentResultCount+1, RESULT_PAGE_SIZE + 1];
    [_tableView reloadData];
    //NSLog(@"URL:%@",urlWithGetRequest);
    NSString *str =  [urlWithGetRequest stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSError* err = nil;
    NSString* responseStr = [NSString stringWithContentsOfURL:[NSURL URLWithString:str] encoding:NSUTF8StringEncoding error:&err];
    if (err != nil) {
        NSLog(@"URL REQUEST ERROR: %@", err);
    }
    NSLog(@"string:%@", responseStr);
    SBJsonParser * parser = [[SBJsonParser alloc] init];
    NSError* error = nil;
    NSMutableDictionary* search_result = [parser objectWithString:responseStr error:&error]; 
    [parser release];
    if (error != nil) {
        NSLog(@"JSON PARSER ERROR: %@", error);
    }
    _totalResult = [[[search_result objectForKey:@"opensearch:totalResults"] objectForKey:@"$t"] intValue];
    NSLog(@"totalResult = %d", _totalResult);
    if (_totalResult == 0) {
        _anyMoreInfo = FALSE;
        return;
    }
    NSMutableArray* result_array = [search_result objectForKey:@"entry"];
    NSInteger arrayIndex;
    NSInteger insertCount = result_array.count;
    if (result_array.count == RESULT_PAGE_SIZE + 1) {
        _anyMoreInfo = TRUE;
        insertCount = RESULT_PAGE_SIZE;
    } else {
        _anyMoreInfo = FALSE;
    }
    for (arrayIndex = 0; arrayIndex < insertCount; arrayIndex ++) {
        [self addDataSource:[result_array objectAtIndex:arrayIndex]];
    }
    _currentResultCount += insertCount;
    [_tableView reloadData];
}

-(void) addDataSource:(NSMutableDictionary*)data
{
    NSString* subAPI;
    NSString* imageURL;
    NSMutableArray* linkArray = [data objectForKey:DoubanKEY_LINKS];
    NSInteger arrayIndex;
    NSString* relString;
    for (arrayIndex = 0; arrayIndex < linkArray.count; arrayIndex++) {
        relString = [[linkArray objectAtIndex:arrayIndex] objectForKey:DoubanKEY_LINK_TYPE];
        
        if([relString compare:@"self"] == NSOrderedSame) {
            subAPI = [[linkArray objectAtIndex:arrayIndex] objectForKey:DoubanKEY_LINK_VLAUE];
        } else if([relString compare:@"image"] == NSOrderedSame) {
            imageURL = [[linkArray objectAtIndex:arrayIndex] objectForKey:DoubanKEY_LINK_VLAUE];
        }
    }

    NSMutableDictionary *newData = [NSMutableDictionary new];
    [newData setObject:subAPI forKey:LocalDataKEY_API_URL];
    [newData setObject:imageURL forKey:LocalDataKEY_IMAGE_URL];
    [newData setObject:[[data objectForKey:DoubanKEY_TITLE] objectForKey:DoubanKEY_VALUE] forKey:LocalDataKEY_TITLE];
    [newData setObject:[[data objectForKey:DoubanKEY_Rating] objectForKey:DoubanKEY_SCORE] forKey:LocalDataKEY_SCORE];
    [newData setObject:[[data objectForKey:DoubanKEY_Rating] objectForKey:DoubanKEY_RATE_COUNT] forKey:LocalDataKEY_RATE_COUNT];
    NSLog(@"title:%@, api_url:%@, image_url:%@,score:%@,count:%@", [newData objectForKey:LocalDataKEY_TITLE], subAPI, imageURL,
          [newData objectForKey:LocalDataKEY_SCORE],[newData objectForKey:LocalDataKEY_RATE_COUNT]);
    
    [_dataSource addObject:newData];
    [newData release];
    return;
}

#pragma UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_dataSource != nil  && indexPath.row < _dataSource.count + 1 && indexPath.row != 0) {
        return 110;
    }else {
        return 30;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_searchBar isFirstResponder]) {
        [_searchBar resignFirstResponder];
    }    
    if (_dataSource != nil  && indexPath.row < (_dataSource.count +1) && indexPath.row != 0) {
        DetailViewController* detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
        NSDictionary* data = [_dataSource objectAtIndex:(indexPath.row -1)];
        //NSLog(@"URL:%@", [data objectForKey:@"API_URL"]);
        [detailViewController loadViewWithURLString:[data objectForKey:LocalDataKEY_API_URL] withImageURLString:[data objectForKey:LocalDataKEY_IMAGE_URL]];
        [self presentModalViewController:detailViewController animated:YES];
    }else {
        if (_anyMoreInfo == TRUE && indexPath.row != 0) {
            [self doSearchWithText:_currentSearchText withSearchType:_lastSearchType withCurrentResultCount:_currentResultCount];
        }
    }
//    NSLog(@"select:%d", indexPath.row);
}

#pragma UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_dataSource == nil) {
        return 1;
    } else {
        if (_anyMoreInfo == TRUE) 
        {
            return _dataSource.count+2;
        } else {
            if (_dataSource.count == 0) {
                return 1;
            } else {
                return _dataSource.count+1;
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *searchResultCellIdentifier = @"SearchResultCell";
    static NSString *defaultCellIdentifier = @"DefaultCell";
    if (_dataSource != nil  && indexPath.row < (_dataSource.count+1) && indexPath.row != 0) {
        NSDictionary* data = [_dataSource objectAtIndex:(indexPath.row -1)];
        searchResultCell* cell = (searchResultCell*)[tableView dequeueReusableCellWithIdentifier:searchResultCellIdentifier];
        if (!cell) {
            cell = [[searchResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:searchResultCellIdentifier];
        }
        [cell loadDataInfo:data];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    } else {
        UITableViewCell *default_cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:defaultCellIdentifier]autorelease];
        if (_totalResult != 0 && indexPath.row == 0) {
            default_cell.textLabel.text = [NSString stringWithFormat:@"       共%d个搜索结果:",_totalResult];
        } else if (_anyMoreInfo == TRUE) {
            default_cell.textLabel.text = @"       加载更多结果...";
        } else if(_dataSource == nil) {
            default_cell.textLabel.text = @"       请输入关键词进行搜索...";
        } else {
            default_cell.textLabel.text = @"       没有符合的结果...";
        }
        
        default_cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return default_cell;
    }
}

#pragma mark - Scroll


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ([_searchBar isFirstResponder]) {
        [_searchBar resignFirstResponder];
    }
}

@end
