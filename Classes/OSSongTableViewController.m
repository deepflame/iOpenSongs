//
//  SongTableViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 6/10/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "OSSongTableViewController.h"

#import <TDBadgedCell.h>
#import <objc/message.h>

@interface OSSongTableViewController () <UISearchBarDelegate, UISearchDisplayDelegate>
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchDisplayController;
@property (nonatomic, strong) UIColor *searchBarColorInactive;
@end

@implementation OSSongTableViewController

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize searchDisplayController;

#pragma mark - UIViewController

- (NSString *)title
{
    return NSLocalizedString(@"Songs", nil);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.searchBar.placeholder = NSLocalizedString(@"Search Songs", nil);
    self.searchBar.scopeButtonTitles = @[NSLocalizedString(@"Title", nil), NSLocalizedString(@"Author", nil), NSLocalizedString(@"Lyrics", nil)];
    self.searchBar.delegate = self;
    
    self.searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate = self;
    self.searchDisplayController.delegate = self;

    // fix scope bar on iPad (with unofficial API... bug in SDK)
    // could be fixed on iPhone as well but the results would only have one row
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if ([self.searchDisplayController.searchBar respondsToSelector:@selector(setCombinesLandscapeBars:)]) {
            objc_msgSend(self.searchDisplayController.searchBar, @selector(setCombinesLandscapeBars:), NO );
        }
    }
    
    // add searchbar to tableview
    self.tableView.tableHeaderView = self.searchBar;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Song *song = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.delegate songTableViewController:self didSelectSong:song];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Song Cell";
    TDBadgedCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
        cell.hideBadgeDuringEditing = NO;
    }
    
    Song *song = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = song.title;
    cell.detailTextLabel.text = song.author;
    cell.badgeString = [self.dataSource songTableViewController:self badgeStringForSong:song];
    cell.badge.radius = 6;
    cell.badge.fontSize = 15;
    
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [super sectionIndexTitlesForTableView:tableView];
    }
    
    // add magnifying glass
    NSMutableArray* indexTitles = [NSMutableArray arrayWithObject:UITableViewIndexSearch];
    [indexTitles addObjectsFromArray:[self.fetchedResultsController sectionIndexTitles]];
    return indexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [super tableView:tableView sectionForSectionIndexTitle:title atIndex:index];
    }
    
    // magnifying glass ?
    if (title == UITableViewIndexSearch) {
        [self.tableView scrollRectToVisible:self.searchDisplayController.searchBar.frame animated:NO];
    	return -1;
    }
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index-1];
}
    
#pragma mark - UISearchDisplayDelegate
    
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    self.fetchedResultsController = nil; // perform new fetch
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    self.fetchedResultsController = nil; // perform new fetch
    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    tableView.editing = self.tableView.editing;
    tableView.allowsSelectionDuringEditing = self.tableView.allowsSelectionDuringEditing;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView
{
    self.fetchedResultsController = nil; // perform new fetch
    [self.tableView reloadData];
}

    
#pragma mark - UISearchBarDelegate

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    // reset table
    searchBar.text = @"";

    // reset searchbar
    searchBar.tintColor = self.searchBarColorInactive;
    [searchBar resignFirstResponder];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    // save the inactive color first time only
    if (!self.searchBarColorInactive) {
        self.searchBarColorInactive = searchBar.tintColor;        
    }
    // make the searchbar tint color the same as the navifation controller
    if (self.navigationController) {
        searchBar.tintColor = self.navigationController.navigationBar.tintColor;
    }
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return true;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    // reset the tint color if user is not searching anymore
    if (![self searchDisplayController].active) {
        searchBar.tintColor = self.searchBarColorInactive;
    }
}

#pragma mark - Accessor Implementations
    
- (UITableView *)currentTableView
{
    if ([self.searchDisplayController isActive]) {
        return self.searchDisplayController.searchResultsTableView;
    }
    
    return [super currentTableView];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController == nil) {
        
        NSPredicate *predicate = [self predicateForSongSearchBar:self.searchDisplayController.searchBar];
        
        // fetch data
        _fetchedResultsController = [Song MR_fetchAllGroupedBy:@"titleSectionIndex"
                                                 withPredicate:predicate
                                                      sortedBy:@"titleSectionIndex,titleNormalized"
                                                     ascending:YES
                                                      delegate:self];
    }
    return _fetchedResultsController;
}

#pragma mark - Private Methods
    
- (NSPredicate *)predicateForSongSearchBar:(UISearchBar*)searchBar
{
    // do not filter if text is blank
    if (searchBar.text.length == 0) {
        return nil; // <-- !!
    }
    
    NSString *filterBy;
    switch (searchBar.selectedScopeButtonIndex) {
        case 0:
            filterBy = @"title";
            break;
                
        case 1:
            filterBy = @"author";
            break;
                
        default:
            filterBy = @"lyrics";
            break;
    }
        
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", filterBy, searchBar.text];
    return predicate;
}

@end
