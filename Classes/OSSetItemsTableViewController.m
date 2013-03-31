//
//  SetSongsTableViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 5/12/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "OSSetItemsTableViewController.h"

#import "SetItemSong.h"
#import "Song.h"

#import "OSSongViewController.h"
#import "OSSetItemSongsTableViewController.h"
#import "OSRevealSidebarController.h"

@interface OSSetItemsTableViewController () <SetItemSongsTableViewControllerDelegate>
@property (nonatomic, strong) NSIndexPath *currentSelection;
@end

@implementation OSSetItemsTableViewController

@synthesize set = _set;
@synthesize currentSelection = _currentSelection;

- (void)setSet:(Set *)set
{
    if (_set == set) {
        return;
    }
    _set = set;
    self.title = set.name;
    
    [self setupFetchedResultsController];
}

- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    self.fetchedResultsController = [SetItem MR_fetchAllSortedBy:@"position"
                                                   ascending:YES
                                               withPredicate:[NSPredicate predicateWithFormat:@"set == %@", self.set]
                                                     groupBy:nil
                                                    delegate:self];
}

- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: support other types as well
    SetItemSong *setItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self songDetailViewController].songView.song = setItem.song;
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

#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSongs:)];
    self.navigationItem.rightBarButtonItems = @[self.editButtonItem, addButtonItem];
}

- (void)viewWillAppear:(BOOL)animated
{
    // select previous item
    [self.tableView selectRowAtIndexPath:self.currentSelection animated:false scrollPosition:UITableViewScrollPositionNone];
    [self selectItemAtIndexPath:self.currentSelection];
  
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // save all changes to the data
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SetSong Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    
    // TODO implement multiple SetItem types
    SetItemSong *setItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = setItem.song.title;
    cell.detailTextLabel.text = setItem.song.author;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // delete object from database
        [self.set.managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        // delete curent selection if it was deleted
        if ([self.currentSelection isEqual:indexPath]) {
            self.currentSelection = nil;
        }
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    // do not update tableview automatically since we did it manually in the UI (otherwise 'ghosting' effect)
    self.suspendAutomaticTrackingOfChangesInManagedObjectContext = YES;
    
    NSMutableArray *setItems = [[self.fetchedResultsController fetchedObjects] mutableCopy];
        
    NSManagedObject *movedSetItem = [[self fetchedResultsController] objectAtIndexPath:fromIndexPath];
    [setItems removeObject:movedSetItem];
    [setItems insertObject:movedSetItem atIndex:[toIndexPath row]];
    
    // update positions
    int i = 0;
    for (SetItem *si in setItems) {
        si.position = [NSNumber numberWithInt:i++];
    }

    self.suspendAutomaticTrackingOfChangesInManagedObjectContext = NO;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectItemAtIndexPath:indexPath];

    // save current selection
    self.currentSelection = indexPath;
    
    // close sliding view controller if on Phone in portrait mode
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && 
        UIInterfaceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
        [self.slidingViewController resetTopView];
    }
}

#pragma mark SetItemSongsTableViewControllerDelegate

-(void)setItemSongsTableViewController:(OSSetItemSongsTableViewController *)sender choseSong:(Song *)song
{
    SetItemSong *newSongItem = [NSEntityDescription insertNewObjectForEntityForName:@"SetItemSong"
                                                             inManagedObjectContext:self.set.managedObjectContext];
    newSongItem.song = song;
    newSongItem.position = [NSNumber numberWithInt:((SetItem *)self.fetchedResultsController.fetchedObjects.lastObject).position.intValue + 1];
    
    [self.set addItemsObject:newSongItem ];
}

-(void)setItemSongsTableViewController:(OSSetItemSongsTableViewController *)sender finishedEditing:(BOOL)animated
{
    [self.navigationController popViewControllerAnimated:animated];
}

#pragma mark - Actions

-(IBAction)addSongs:(id)sender
{
    OSSetItemSongsTableViewController *setItemSongsTVC = [[OSSetItemSongsTableViewController alloc] init];
    setItemSongsTVC.delegate = self;
    
    [self.navigationController pushViewController:setItemSongsTVC animated:YES];
}

@end
