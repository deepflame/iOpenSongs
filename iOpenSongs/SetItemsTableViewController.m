//
//  SetSongsTableViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 5/12/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "SetItemsTableViewController.h"

#import "SetItemSong.h"
#import "Song.h"

#import "SongViewController.h"
#import "SetItemSongsTableViewController.h"
#import "RevealSidebarController.h"

@interface SetItemsTableViewController () <SetItemSongsTableViewControllerDelegate>
@property (nonatomic, strong) NSIndexPath *currentSelection;
@end

@implementation SetItemsTableViewController

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
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"SetItem"];
    request.predicate = [NSPredicate predicateWithFormat:@"set == %@", self.set];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.set.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: support other types as well
    SetItemSong *setItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self songDetailViewController].song = setItem.song;
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

#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    // select previous item
    [self.tableView selectRowAtIndexPath:self.currentSelection animated:false scrollPosition:UITableViewScrollPositionNone];
    [self selectItemAtIndexPath:self.currentSelection];
    
    [super viewWillAppear:animated];
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

-(void)setItemSongsTableViewController:(SetItemSongsTableViewController *)sender choseSong:(Song *)song
{
    SetItemSong *newSongItem = [NSEntityDescription insertNewObjectForEntityForName:@"SetItemSong"
                                                             inManagedObjectContext:self.set.managedObjectContext];
    newSongItem.song = song;
    newSongItem.position = [NSNumber numberWithInt:((SetItem *)self.fetchedResultsController.fetchedObjects.lastObject).position.intValue + 1];
    
    [self.set addItemsObject:newSongItem ];
}

-(void)setItemSongsTableViewController:(SetItemSongsTableViewController *)sender finishedEditing:(BOOL)animated
{
    [self.navigationController popViewControllerAnimated:animated];
}

#pragma mark --

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Add Song Items"]) {
        [segue.destinationViewController  setDelegate:self];
    }
}

@end
