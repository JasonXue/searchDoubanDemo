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
}

- (IBAction)searchBooksTouched:(id)sender {
    _currentSearchType = SearchTypeBook;
    _searchBar.placeholder = SEARCH_BOOK_STRING;
}

- (IBAction)SearchMusicTouched:(id)sender {
    _currentSearchType = SearchTypeMusic;
    _searchBar.placeholder = SEARCH_MUSIC_STRING;
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
    _anyMoreInfo = FALSE;
    _currentResultCount = 0;
    _currentSearchText = nil;
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
            searchAPI = SEARCH_MOIVE_API;
            break;
        case SearchTypeMusic:
            searchAPI = SEARCH_MUSIC_API;
            break;
        default:
            searchAPI = SEARCH_MOIVE_API;
            break;
    }
    NSString* urlWithGetRequest = [NSString stringWithFormat:@"%@?q=%@&start-index=%d&max-results=%d&alt=json", searchAPI, text,currentResultCount+1, RESULT_PAGE_SIZE + 1];
    NSLog(@"URL:%@",urlWithGetRequest);
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
    NSInteger _totalResult = [[[search_result objectForKey:@"opensearch:totalResults"] objectForKey:@"$t"] intValue];
    NSLog(@"totalResult = %d", _totalResult);
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
    NSMutableArray* linkArray = [data objectForKey:@"link"];
    NSInteger arrayIndex;
    NSString* relString;
    for (arrayIndex = 0; arrayIndex < linkArray.count; arrayIndex++) {
        relString = [[linkArray objectAtIndex:arrayIndex] objectForKey:@"@rel"];
        
        if([relString compare:@"self"] == NSOrderedSame) {
            subAPI = [[linkArray objectAtIndex:arrayIndex] objectForKey:@"@href"];
        } else if([relString compare:@"image"] == NSOrderedSame) {
            imageURL = [[linkArray objectAtIndex:arrayIndex] objectForKey:@"@href"];
        }
    }

    NSMutableDictionary *newData = [NSMutableDictionary new];
    [newData setObject:subAPI forKey:@"API_URL"];
    [newData setObject:imageURL forKey:@"IMAGE_URL"];
    [newData setObject:[[data objectForKey:@"title"] objectForKey:@"$t"] forKey:@"title"];
    [newData setObject:[[data objectForKey:@"gd:rating"] objectForKey:@"@average"] forKey:@"RATING_SCORE"];
    [newData setObject:[[data objectForKey:@"gd:rating"] objectForKey:@"@numRaters"] forKey:@"RATING_COUNT"];
    NSLog(@"title:%@, api_url:%@, image_url:%@,score:%@,count:%@", [newData objectForKey:@"title"], subAPI, imageURL,
          [newData objectForKey:@"RATING_SCORE"],[newData objectForKey:@"RATING_COUNT"]);
    
    [_dataSource addObject:newData];
    [newData release];
    return;
}

#pragma UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_dataSource != nil  && indexPath.row < _dataSource.count) {
        return 110;
    }else {
        return 30;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_dataSource != nil  && indexPath.row < _dataSource.count) {
        DetailViewController* detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
        NSDictionary* data = [_dataSource objectAtIndex:indexPath.row];
        //NSLog(@"URL:%@", [data objectForKey:@"API_URL"]);
        [detailViewController loadViewWithURLString:[data objectForKey:@"API_URL"] withImageURLString:[data objectForKey:@"IMAGE_URL"]];
        [self presentModalViewController:detailViewController animated:YES];
    }else {
        if (_anyMoreInfo == TRUE) {
            [self doSearchWithText:_currentSearchText withSearchType:_lastSearchType withCurrentResultCount:_currentResultCount];
        }
    }
    NSLog(@"select:%d", indexPath.row);
}

#pragma UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_dataSource == nil) {
        return 1;
    } else {
        if (_anyMoreInfo == TRUE) {
            return _dataSource.count+1;
        } else {
            return _dataSource.count;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *searchResultCellIdentifier = @"SearchResultCell";
    static NSString *defaultCellIdentifier = @"DefaultCell";
    if (_dataSource != nil  && indexPath.row < _dataSource.count) {
        NSDictionary* data = [_dataSource objectAtIndex:indexPath.row];
        searchResultCell* cell = (searchResultCell*)[tableView dequeueReusableCellWithIdentifier:searchResultCellIdentifier];
        if (!cell) {
            cell = [[searchResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:searchResultCellIdentifier];
        }
        [cell loadDataInfo:data];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    } else {
        UITableViewCell *default_cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:defaultCellIdentifier]autorelease];
        if (_anyMoreInfo == TRUE) {
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
