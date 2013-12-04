//
//  MasterViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 1/1/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "OSSongSelectTableViewController.h"
#import "OSSongViewController.h"

#import "Song+Import.h"

#import <MBProgressHUD.h>
#import <FRLayeredNavigation.h>

#import "OSImportTableViewControllerDelegate.h"
#import "OSITunesImportTableViewController.h"
#import "OSDropboxImportTableViewController.h"

// TODO: remove dependency
#import <DropboxSDK/DropboxSDK.h>

#import "OSStoreManager.h"

@interface OSSongSelectTableViewController () <UIActionSheetDelegate, OSImportTableViewControllerDelegate>
@property (nonatomic, strong) NSIndexPath *currentSelection;
@property (nonatomic, strong) UIActionSheet *importActionSheet;
@end

@implementation OSSongSelectTableViewController

#pragma mark - UIViewController

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    UIBarButtonItem *addBarButtonItem = [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemAdd handler:^(id sender){
        if ([self.importActionSheet isVisible]) {
            [self.importActionSheet dismissWithClickedButtonIndex:-1 animated:YES];
        } else {
            [self.importActionSheet showFromBarButtonItem:self.navigationItem.leftBarButtonItem animated:YES];
        }
    }];
    
    self.navigationItem.leftBarButtonItems = @[addBarButtonItem];
    self.navigationItem.rightBarButtonItems = @[self.editButtonItem];
}

- (void)viewWillAppear:(BOOL)animated
{
    // select previous song
    [self.tableView selectRowAtIndexPath:self.currentSelection animated:false scrollPosition:UITableViewScrollPositionNone];
    Song *song = [self.fetchedResultsController objectAtIndexPath:self.currentSelection];
    [self.delegate songTableViewController:self didSelectSong:song];
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // import songs from application sharing if no songs found
    if (self.fetchedResultsController.fetchedObjects.count == 0) {
        OSITunesImportTableViewController *importTableViewController = [[OSITunesImportTableViewController alloc] init];
        [importTableViewController selectAllItems];
        [importTableViewController importAllSelectedItems];
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
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    // save current selection
    self.currentSelection = indexPath;
    
    // close sliding view controller if on Phone in portrait mode
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && 
        UIInterfaceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
        [self.layeredNavigationController compressViewControllers:YES];
    }
}

#pragma mark - OSImportTableViewControllerDelegate

- (void)importTableViewController:(OSImportTableViewController *)sender finishedImportWithErrors:(NSArray *)errors
{
    [sender handleImportErrors]; // TODO: do error handling somewhere else
    [self.navigationController popToRootViewControllerAnimated:YES];
}

# pragma mark - Getter implementations

- (UIActionSheet *)importActionSheet
{
    if (_importActionSheet == nil) {
        _importActionSheet = [UIActionSheet bk_actionSheetWithTitle:NSLocalizedString(@"Import from", nil)];
        OSSongSelectTableViewController *_self = self;
        
        // iTunes File Sharing
        [_importActionSheet bk_addButtonWithTitle:NSLocalizedString(@"iTunes File Sharing", nil) handler:^{
            OSImportTableViewController *importTableViewController = [[OSITunesImportTableViewController alloc] init];
            importTableViewController.delegate = _self;
            [_self.navigationController pushViewController:importTableViewController animated:YES];
        }];
        
        // Dropbox
        if ([[OSStoreManager sharedManager] canUseFeature:OS_IAP_DROPBOX]) {
            [_importActionSheet bk_addButtonWithTitle:NSLocalizedString(@"Dropbox", nil) handler:^{
                if (! [[DBSession sharedSession] isLinked]) {
                    [[DBSession sharedSession] linkFromController:_self];
                    return; // <- !!
                }
                OSImportTableViewController *importTableViewController = [[OSDropboxImportTableViewController alloc] init];
                importTableViewController.delegate = _self;
                [_self.navigationController pushViewController:importTableViewController animated:YES];
            }];
        }

        // Cancel Button
        [_importActionSheet bk_setCancelButtonWithTitle:nil handler:^ {
            [_importActionSheet dismissWithClickedButtonIndex:-1 animated:YES];
        }];
    }
    return _importActionSheet;
}

@end
