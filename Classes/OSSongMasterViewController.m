//
//  MasterViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 1/1/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "OSSongMasterViewController.h"
#import "OSSongViewController.h"

#import "Song+Import.h"

#import "MBProgressHUD.h"
#import "OSRevealSidebarController.h"

#import "OSITunesImportTableViewController.h"
#import "OSDropboxImportTableViewController.h"

// TODO: remove dependency
#import <DropboxSDK/DropboxSDK.h>

@interface OSSongMasterViewController () <UIActionSheetDelegate>
@property (nonatomic, strong) NSIndexPath *currentSelection;
@property (nonatomic, strong) UIActionSheet *importActionSheet;
@end


@implementation OSSongMasterViewController
@synthesize currentSelection = _currentSelection;
@synthesize importActionSheet = _importActionSheet;

#pragma mark - UIViewController

- (void)viewDidLoad 
{
    [super viewDidLoad];

    // UI
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSongs:)];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    self.importActionSheet = [[UIActionSheet alloc ] initWithTitle:@"Import from"
                                                          delegate:self
                                                 cancelButtonTitle:@"Cancel"
                                            destructiveButtonTitle:nil
                                                 otherButtonTitles:@"iTunes", @"Dropbox", nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    // select previous song
    [self.tableView selectRowAtIndexPath:self.currentSelection animated:false scrollPosition:UITableViewScrollPositionNone];
    [self selectSongAtIndexPath:self.currentSelection];
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // import songs from application sharing if no songs found
    if (self.fetchedResultsController.fetchedObjects.count == 0) {
        // FIXME
        //[self importSongs];
    }
}

#pragma mark - UITableViewDataSource

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // delete object from database
        Song* song = (Song *)[self.fetchedResultsController objectAtIndexPath:indexPath];
        [song MR_deleteEntity];
        // delete curent selection if it was deleted
        if ([self.currentSelection isEqual:indexPath]) {
            self.currentSelection = nil;
        }
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectSongAtIndexPath:indexPath];
    
    // save current selection
    self.currentSelection = indexPath;
    
    // close sliding view controller if on Phone in portrait mode
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && 
        UIInterfaceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
        [self.slidingViewController resetTopView];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    OSImportTableViewController *importTableViewController;
    
    if ([buttonTitle isEqualToString:@"iTunes"]) {
        importTableViewController = [[OSITunesImportTableViewController alloc] init];
    } else if ([buttonTitle isEqualToString:@"Dropbox"]) {
        if (! [[DBSession sharedSession] isLinked]) {
            [[DBSession sharedSession] linkFromController:self];
            return; // <- !!
        }
        importTableViewController = [[OSDropboxImportTableViewController alloc] init];
    }
    
    [self.navigationController pushViewController:importTableViewController animated:YES];
}

#pragma mark - Actions

- (void)addSongs:(id)sender {
    if ([self.importActionSheet isVisible]) {
        [self.importActionSheet dismissWithClickedButtonIndex:-1 animated:YES];
    } else {
        [self.importActionSheet showFromBarButtonItem:self.navigationItem.leftBarButtonItem animated:YES];        
    }
}

#pragma mark - Private Methods

- (void)selectSongAtIndexPath:(NSIndexPath *)indexPath
{
    Song *song = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self songDetailViewController].songView.song = song;
}

- (OSSongViewController *)songDetailViewController
{
    id svc = [self.slidingViewController topViewController];
    
    if ([svc isKindOfClass:[UINavigationController class]]) {
        svc = ((UINavigationController *) svc).topViewController;
    }
    
    if (![svc isKindOfClass:[OSSongViewController class]]) {
        svc = nil;
    }
    return svc;
}

@end
