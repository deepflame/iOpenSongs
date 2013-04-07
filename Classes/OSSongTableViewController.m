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

@interface OSSongTableViewController () <UISearchBarDelegate>
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchDisplayController;
@property (nonatomic, strong) UIColor *searchBarColorInactive;
@end

@implementation OSSongTableViewController
@synthesize searchDisplayController;

#pragma mark - UIViewController

- (NSString *)title
{
    return @"Songs";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
        
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.searchBar.placeholder = @"Search Songs";
    self.searchBar.scopeButtonTitles = @[@"Title", @"Author", @"Lyrics"];
    self.searchBar.delegate = self;
    
    self.searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate = self;

    // fix scope bar on iPad (with unofficial API... bug in SDK)
    // could be fixed on iPhone as well but the results would only have one row
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if ([self.searchDisplayController.searchBar respondsToSelector:@selector(setCombinesLandscapeBars:)]) {
            objc_msgSend(self.searchDisplayController.searchBar, @selector(setCombinesLandscapeBars:), NO );
        }
    }
    
    // add searchbar to tableview
    self.tableView.tableHeaderView = self.searchBar;
    
    // fetch data
    self.fetchedResultsController = [Song MR_fetchAllGroupedBy:@"titleSectionIndex"
                                                 withPredicate:nil
                                                      sortedBy:@"titleSectionIndex,titleNormalized"
                                                     ascending:YES
                                                      delegate:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Song Cell";
    TDBadgedCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    
    Song *song = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = song.title;
    cell.detailTextLabel.text = song.author;
    cell.badgeString = [self.dataSource songTableViewController:self badgeStringForSong:song];
    cell.badge.radius = 6;
    cell.badge.fontSize = 15;
    
    return cell;
}

#pragma mark - UISearchBarDelegate

-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    [self filterSongs:searchBar];
}

-(void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    searchBar.text = @"";
    [self filterSongs:searchBar];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    // reset table
    searchBar.text = @"";
    [self filterSongs:searchBar];

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

#pragma mark - Private Methods

-(void)filterSongs:(UISearchBar*)searchBar
{
    NSPredicate *predicate;
    
    if (searchBar.text.length == 0) {
        
        predicate =[NSPredicate predicateWithFormat:@"1=1"]; // no filter
        
    } else {
        
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
        
        predicate = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", filterBy, searchBar.text];
    }
    [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    
    [[self fetchedResultsController] performFetch:nil];
}

@end
