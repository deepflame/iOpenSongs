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
    return NSLocalizedString(@"Add Songs", nil);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // FIXME: remove searchbar for now
    self.tableView.tableHeaderView = nil;
    
    self.tableView.editing = YES;
    self.tableView.allowsSelectionDuringEditing = YES;
    
    // UIBarButtonItems
    UIBarButtonItem *doneBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone handler:^(id sender) {
        [self.itemsDelegate setItemSongsTableViewController:self finishedEditing:YES];
    }];
    self.navigationItem.rightBarButtonItems = @[doneBarButtonItem];
}

#pragma mark - UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleInsert;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    Song *song = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    switch (editingStyle) {
        case UITableViewCellEditingStyleInsert:
            if ([self.itemsDelegate respondsToSelector:@selector(setItemSongsTableViewController:didInsertSong:)]) {
                [self.itemsDelegate setItemSongsTableViewController:self didInsertSong:song];
            }
            break;
            
        case UITableViewCellEditingStyleDelete:
            if ([self.itemsDelegate respondsToSelector:@selector(setItemSongsTableViewController:didDeleteSong:)]) {
                [self.itemsDelegate setItemSongsTableViewController:self didDeleteSong:song];
            }            
            break;
            
        default:
            break;
    }
    
}

#pragma mark - UITableViewDataSource

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    // delete only possible if song in set
    if (cell.editingStyle == UITableViewCellEditingStyleDelete) {
        Song *song = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSString *badge = [self.dataSource songTableViewController:self badgeStringForSong:song];
        return badge != nil;
    }
    
    return YES;
}

@end
