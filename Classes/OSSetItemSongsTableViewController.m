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
@synthesize delegate = _delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // FIXME: remove searchbar for now
    self.tableView.tableHeaderView = nil;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Song *song = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [[self delegate] setItemSongsTableViewController:self choseSong:song];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark IBAction

- (IBAction)doneEditing:(UIBarButtonItem *)sender 
{
    [[self delegate] setItemSongsTableViewController:self 
                                     finishedEditing:YES];
}


@end
