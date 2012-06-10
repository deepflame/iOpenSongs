//
//  MasterViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 1/1/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "SongMasterViewController.h"
#import "SongViewController.h"

#import "DataManager.h"

#import "RevealSidebarController.h"

@interface SongMasterViewController ()
@end


@implementation SongMasterViewController

- (SongViewController *)songDetailViewController
{
    id svc = [self.slidingViewController topViewController];
    
    if ([svc isKindOfClass:[UINavigationController class]]) {
        svc = ((UINavigationController *) svc).topViewController;
    }
    
    if (![svc isKindOfClass:[SongViewController class]]) {
        svc = nil;
    }
    return svc;
}

#pragma mark - View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - UITableViewDataSource

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // delete object from database
        [[DataManager sharedInstance].managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    }
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Song *song = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [self songDetailViewController].song = song;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    // close sliding view controller if on Phone in portrait mode
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && 
        UIInterfaceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
        [self.slidingViewController resetTopView];
    }
}

- (IBAction)refreshList:(id)sender 
// Called when the user taps the Refresh button.
{
#pragma unused(sender)
    [self importDataIntoContext:[DataManager sharedInstance].managedObjectContext];
}

@end
