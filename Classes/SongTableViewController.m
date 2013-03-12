//
//  SongTableViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 6/10/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "SongTableViewController.h"

#import "Song.h"

#import <objc/message.h>

@interface SongTableViewController () <UISearchBarDelegate>
@property (nonatomic, strong) UIColor *searchBarColorInactive;
@end

@implementation SongTableViewController
@synthesize searchBarColorInactive = _searchBarColorInactive;

#pragma mark - UIViewController

- (void)viewDidLoad 
{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    
    // fix scope bar on iPad (with unofficial API... bug in SDK)
    // could be fixed on iPhone as well but the results would only have one row
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if ([self.searchDisplayController.searchBar respondsToSelector:@selector(setCombinesLandscapeBars:)]) {
            objc_msgSend(self.searchDisplayController.searchBar, @selector(setCombinesLandscapeBars:), NO );
        }
    }
    
    // fetch data
    self.fetchedResultsController = [Song MR_fetchAllSortedBy:@"titleNormalized"
                                                    ascending:YES
                                                withPredicate:nil
                                                      groupBy:@"titleSectionIndex"
                                                     delegate:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark -
#pragma mark UITableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Song Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    
    Song *song = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = song.title;
    cell.detailTextLabel.text = song.author;
    
    return cell;
}

#pragma mark UISearchBarDelegate

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

    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // TODO Handle error
        CLS_LOG(@"Unresolved error %@, %@", error, [error userInfo]);
        //exit(-1);  // Fail
    }
}

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

@end
