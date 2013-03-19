//
//  MasterViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 1/1/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "SongMasterViewController.h"
#import "SongViewController.h"

#import "Song+Import.h"

#import "MBProgressHUD.h"
#import "RevealSidebarController.h"

@interface SongMasterViewController () <UIActionSheetDelegate>
@property (nonatomic, strong) NSIndexPath *currentSelection;
@property (nonatomic, strong) UIActionSheet *importActionSheet;
@end


@implementation SongMasterViewController
@synthesize currentSelection = _currentSelection;
@synthesize importActionSheet = _importActionSheet;

#pragma mark -
#pragma mark Private Methods

- (void)importSongs
{
    // show HUD
    UIView *viewForHud = self.navigationController ? self.navigationController.view : self.view;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:viewForHud animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.labelText = @"Importing";
    
    // listen to import progress event
    [[NSNotificationCenter defaultCenter] addObserverForName:SongImportWillImport object:nil queue:nil usingBlock:^(NSNotification *notification) {
        hud.progress = [(NSNumber *) [notification.userInfo valueForKey:SongImportAttributeProgress] floatValue];
    }];
        
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        NSError *error = nil;
        
        // import songs from application sharing
        [Song importApplicationDocumentsIntoContext:context error:&error];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            // dismiss HUD
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            // TODO: show image on success or error in HUD
            
            if (error) {
                [self handleError:[NSString stringWithFormat:@"%@\n\n%@", error.localizedDescription, error.localizedRecoverySuggestion]
                        withTitle:error.localizedFailureReason];
            }
        });
        
    });
}

- (void)handleError:(NSString *)errorMessage withTitle:(NSString *)errorTitle {
    if (!errorTitle) {
        errorTitle = NSLocalizedString(@"Error Title",
                                       @"Title for alert displayed when download or parse error occurs.");
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:errorTitle
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)selectSongAtIndexPath:(NSIndexPath *)indexPath
{
    Song *song = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self songDetailViewController].song = song;
}

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

#pragma mark - UIViewController

- (void)viewDidLoad 
{
    [super viewDidLoad];

    // UI
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSongs:)];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    self.importActionSheet = [[UIActionSheet alloc ]initWithTitle:@"Import from" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"iTunes", nil];
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
        [self importSongs];
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

#pragma mark UITableViewDelegate

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

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"iTunes"]) {
        [self importSongs];
    }
}

#pragma mark Actions

- (IBAction)addSongs:(id)sender {
    if ([self.importActionSheet isVisible]) {
        [self.importActionSheet dismissWithClickedButtonIndex:-1 animated:YES];
    } else {
        [self.importActionSheet showFromBarButtonItem:self.navigationItem.leftBarButtonItem animated:YES];        
    }
}

@end
