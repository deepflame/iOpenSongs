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
#import "RevealSidebarController.h"


@interface SetItemsTableViewController ()

@end

@implementation SetItemsTableViewController

@synthesize set = _set;

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

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

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
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSMutableArray *setItems = [[self.fetchedResultsController fetchedObjects] mutableCopy];
        
    NSManagedObject *movedSetItem = [[self fetchedResultsController] objectAtIndexPath:fromIndexPath];
    [setItems removeObject:movedSetItem];
    [setItems insertObject:movedSetItem atIndex:[toIndexPath row]];
    
    // update positions
    int i = 0;
    for (SetItem *si in setItems) {
        si.position = [NSNumber numberWithInt:i++];
    }
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: support other types as well
    SetItemSong *setItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [self songDetailViewController].song = setItem.song;

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // close sliding view controller if on Phone in portrait mode
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && 
        UIInterfaceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
        [self.slidingViewController resetTopView];
    }
}

#pragma mark --

- (IBAction)addDemoSong:(UIBarButtonItem *)sender 
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Song"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" 
                                                                                     ascending:YES 
                                                                                      selector:@selector(localizedCaseInsensitiveCompare:)]];
    NSArray *songs = [self.set.managedObjectContext executeFetchRequest:request error:nil];
    
    int randomIndex = rand() % songs.count;
    Song* newSong = [songs objectAtIndex:randomIndex];
    
    SetItemSong *newSongItem = [NSEntityDescription insertNewObjectForEntityForName:@"SetItemSong"
                                                 inManagedObjectContext:self.set.managedObjectContext];
    newSongItem.song = newSong;
    newSongItem.position = [NSNumber numberWithInt:((SetItem *)self.fetchedResultsController.fetchedObjects.lastObject).position.intValue + 1];
    
    [self.set addItemsObject:newSongItem ];
}

@end
