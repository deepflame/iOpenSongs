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
@property (nonatomic, strong) UIActionSheet *importActionSheet;
@end

@implementation OSSongSelectTableViewController

#pragma mark - UIViewController

- (id)init
{
    self = [super init];
    if (self) {
    }
    if ([self respondsToSelector:@selector(restorationIdentifier)]) {
        self.restorationIdentifier = NSStringFromClass([self class]);
    }
    return self;
}

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
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    self.navigationItem.leftBarButtonItems = @[addBarButtonItem];
    self.navigationItem.rightBarButtonItems = @[self.editButtonItem];
    
    // state restoration (iOS6)
    if ([self respondsToSelector:@selector(restorationIdentifier)]) {
        self.view.restorationIdentifier = @"View";
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // select previous item (e.g. if selected from state restoration)
    Song *song = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
    if (song) {
        [self.delegate songTableViewController:self didSelectSong:song];
    }
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
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
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
        } else {
            [[OSStoreManager sharedManager] whenPurchasedOrRestored:OS_IAP_DROPBOX execute:^ {
                self.importActionSheet = nil; // reload action sheet
            }];
        }

        // Cancel Button
        [_importActionSheet bk_setCancelButtonWithTitle:nil handler:nil];
    }
    return _importActionSheet;
}

@end
