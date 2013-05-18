//
//  SetItemSongsTableViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 6/10/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "OSSetItemSongsTableViewController.h"

@interface OSSetItemSongsTableViewController ()
@end

@implementation OSSetItemSongsTableViewController

#pragma mark - UIViewController

- (NSString *)title
{
    return @"Add Songs";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // FIXME: remove searchbar for now
    self.tableView.tableHeaderView = nil;
    
    UIBarButtonItem *doneBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditing:)];
    self.navigationItem.rightBarButtonItems = @[doneBarButtonItem];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Song *song = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [self.delegate songTableViewController:self didSelectSong:song];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Song *song = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.delegate songTableViewController:self didDeleteSong:song];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(songTableViewController:accessoryButtonTappedForSong:)]) {
        Song *song = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.delegate songTableViewController:self accessoryButtonTappedForSong:song];
    }
}

#pragma mark - UITableViewDataSource

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    Song *song = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *badge = [self.dataSource songTableViewController:self badgeStringForSong:song];
    return badge != nil;
}

#pragma mark - Actions

- (void)doneEditing:(UIBarButtonItem *)sender
{
    [self.delegate setItemSongsTableViewController:self finishedEditing:YES];
}


@end
