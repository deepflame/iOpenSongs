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
#import "OSSongEditorValuesViewController.h"
#import "OSSetItemSongsTableViewController.h"
#import "OSMainViewController.h"
#import "OSStoreManager.h"

#import <objc/message.h>

@interface OSSetItemsTableViewController () <OSSongTableViewControllerDelegate, OSSongTableViewControllerDataSource, OSSetItemSongsTableViewControllerDelegate, OSSongEditorViewControllerDelegate>

@end

@implementation OSSetItemsTableViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // preserve selection between presentations
    self.clearsSelectionOnViewWillAppear = NO;
    
    self.tableView.allowsSelectionDuringEditing = YES;
 
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSongs:)];
    self.navigationItem.leftBarButtonItems = @[addButtonItem];
    self.navigationItem.leftItemsSupplementBackButton = YES;
    self.navigationItem.rightBarButtonItems = @[self.editButtonItem];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // select previous item
    [self selectSetItemAtIndexPath:[self.tableView indexPathForSelectedRow]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self trackScreen:@"Set Items"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if (editing == NO) {
        // propagate edit
        [self.delegate setItemsTableViewController:self didModifySet:self.set];
        
        // save all changes when leaving editing mode
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
    }
}

#pragma mark - UITableViewDataSource

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
        SetItem *setItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.set.managedObjectContext deleteObject:setItem];
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (! [tableView isEditing]) {
      [self selectSetItemAtIndexPath:indexPath];
    
      // close sliding view controller if on Phone in portrait mode
      if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone &&
          UIInterfaceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
          [self.layeredNavigationController compressViewControllers:YES];
      }
        
    } else if ([[OSStoreManager sharedManager] isPurchased:OS_IAP_EDITOR]) {
        // edit song
        [self trackEventWithAction:@"edit"];
        
        SetItemSong* setItem = (SetItemSong *)[self.fetchedResultsController objectAtIndexPath:indexPath];
        OSSongEditorValuesViewController *songEditorViewController = [[OSSongEditorValuesViewController alloc] initWithSong:setItem.song];
        [songEditorViewController presentFromViewController:self animated:YES completion:nil];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
}

#pragma mark - OSSetViewControllerDelegate

- (void)setViewController:(OSSetViewController *)sender didChangeToSetItem:(SetItem *)setItem atIndex:(NSUInteger)index
{
    NSIndexPath *indexPath =[NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

#pragma mark - OSSongTableViewControllerDelegate

- (void)songTableViewController:(OSSongTableViewController *)sender didSelectSong:(Song *)song
{
    if ([self.delegate respondsToSelector:@selector(songTableViewController:didSelectSong:)]) {
        objc_msgSend(self.delegate, @selector(songTableViewController:didSelectSong:), self, song);
    }
}

#pragma mark - OSSongTableViewControllerDataSource

- (NSString *)songTableViewController:(OSSongTableViewController *)sender badgeStringForSong:(Song *)song
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"set == %@ AND song == %@", self.set, song];
    NSUInteger songCount = [SetItemSong MR_countOfEntitiesWithPredicate:predicate];
    
    if (songCount) {
        return [NSString stringWithFormat:@"%d", songCount];
    }
    return nil;
}

#pragma mark - OSSetItemSongsTableViewControllerDelegate

-(void)setItemSongsTableViewController:(OSSetItemSongsTableViewController *)sender didInsertSong:(Song *)song
{
    SetItemSong *newSongItem = [SetItemSong MR_createEntity];
    
    newSongItem.song = song;
    newSongItem.position = @(((SetItem *)self.fetchedResultsController.fetchedObjects.lastObject).position.intValue + 1);
    
    [self.set addItemsObject:newSongItem];
}

-(void)setItemSongsTableViewController:(OSSetItemSongsTableViewController *)sender didDeleteSong:(Song *)song
{
    // delete last Song if multiple
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"set == %@ AND song == %@", self.set, song];
    [[SetItemSong MR_findFirstWithPredicate:predicate sortedBy:@"position" ascending:NO] MR_deleteEntity];
}

-(void)setItemSongsTableViewController:(OSSetItemSongsTableViewController *)sender finishedEditing:(BOOL)animated
{
    [self.navigationController popViewControllerAnimated:animated];
    
    // propagate changes
    [self.delegate setItemsTableViewController:self didModifySet:self.set];
    
    // save changes
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
}

#pragma mark - OSSongEditorViewControllerDelegate

- (void)songEditorViewController:(id)sender finishedEditingSong:(Song *)song
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Actions

-(void)addSongs:(id)sender
{
    [self trackEventWithAction:@"add songs"];
    
    OSSetItemSongsTableViewController *setItemSongsTVC = [[OSSetItemSongsTableViewController alloc] init];
    setItemSongsTVC.delegate = self;
    setItemSongsTVC.dataSource = self;
    setItemSongsTVC.itemsDelegate = self;
    
    if ([self.delegate respondsToSelector:@selector(setItemsTableViewController:willAddSetItemsOfClass:toSet:)]) {
        [self.delegate setItemsTableViewController:self willAddSetItemsOfClass:[SetItemSong class] toSet:self.set];
    }
    
    [self.navigationController pushViewController:setItemSongsTVC animated:YES];
}

#pragma mark - Private Methods

- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    self.fetchedResultsController = [SetItem MR_fetchAllSortedBy:@"position"
                                                       ascending:YES
                                                   withPredicate:[NSPredicate predicateWithFormat:@"set == %@", self.set]
                                                         groupBy:nil
                                                        delegate:self];
}

- (void)selectSetItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self trackEventWithAction:@"select"];

    SetItem *setItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.delegate setItemsTableViewController:self didSelectSetItem:setItem fromSet:self.set];
}

#pragma mark - Public Accossor Overrides

- (void)setSet:(Set *)set
{
    if (_set == set) {
        return;
    }
    _set = set;
    self.title = set.name;
    
    [self setupFetchedResultsController];
}

@end
