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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

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
    newSongItem.position = [NSNumber numberWithInt:self.fetchedResultsController.fetchedObjects.count];
    
    [self.set addItemsObject:newSongItem ];
}

@end
