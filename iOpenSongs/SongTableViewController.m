//
//  SongTableViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 6/10/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "SongTableViewController.h"

#import "DataManager.h"

#import "Song.h"
#import "Song+OpenSong.h"
#import "Song+FirstLetter.h"

@interface SongTableViewController () <UISearchBarDelegate>
@property (nonatomic, strong) UIColor *searchBarColorInactive;
@end

@implementation SongTableViewController
@synthesize searchBarColorInactive = _searchBarColorInactive;

- (NSString *)applicationDocumentsDirectory
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSArray *)openSongInfos
{
    NSMutableArray *infos =[NSMutableArray arrayWithCapacity:0];
    NSMutableArray *errors = [NSMutableArray arrayWithCapacity:0];
    
    NSString *documentsDirectoryPath = [self applicationDocumentsDirectory];
    NSArray *documentsDirectoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectoryPath error:NULL];
    
    for (NSString* curFileName in [documentsDirectoryContents objectEnumerator]) {
        NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:curFileName];
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        
        BOOL isDirectory;
        [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
        
        // proceed to add the document URL to our list (ignore the "Inbox" folder)
        if (!(isDirectory || [curFileName isEqualToString:@"Inbox"] || [curFileName isEqualToString:@".DS_Store"])) {
            NSDictionary *info = [Song openSongInfoWithOpenSongFileUrl:fileURL];
            if (info) {
                [infos addObject:info];
            } else {
                [errors addObject:curFileName];
            }
        }
    }
    
    // process errors
    if (errors.count) {
        NSString *fileList = [errors componentsJoinedByString:@"\n"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleError:[NSString stringWithFormat:@"%@\n\nMake sure the files are in the OpenSong format.", fileList] 
                    withTitle:[NSString stringWithFormat:@"Issue importing %d file(s):", errors.count]];
        });
    }
    
    // add a demo file if nothing is present
    if ([infos count] == 0) {
        NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"DemoFile" withExtension:@""];
        NSDictionary *info = [Song openSongInfoWithOpenSongFileUrl:fileURL];
        if (info) {
            [infos addObject:info];
        }
    }
    return infos;
}

- (void)importDataIntoContext:(NSManagedObjectContext *)managedObjectContext
{
    dispatch_queue_t importQ = dispatch_queue_create("Song import", NULL);
    dispatch_async(importQ, ^{
        NSArray *songInfos = [self openSongInfos];
        [managedObjectContext performBlock:^{ // perform in the NSMOC's safe thread (main thread)
            for (NSDictionary *info in songInfos) {
                // check if song already exists based on title
                Song *songFound = nil;
                for (Song *song in self.fetchedResultsController.fetchedObjects) {
                    if ([song.title isEqualToString:[info valueForKey:@"title"]]) {
                        songFound = song;
                    }
                }
                
                if (songFound) {
                    [songFound updateWithOpenSongInfo:info];
                } else {
                    [Song songWithOpenSongInfo:info inManagedObjectContext:managedObjectContext];
                }
            }
        }];
    });
    // may have to remove it due to ARC
    dispatch_release(importQ);
}

// @override
- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Song"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    // no predicate because we want ALL the Songs
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:[DataManager sharedInstance].managedObjectContext
                                                                          sectionNameKeyPath:@"titleFirstLetter"
                                                                                   cacheName:nil];
}

#pragma mark - View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    
    // fix scope bar on iPad (with unofficial API... bug in SDK)
    // could be fixed on iPhone as well but the results would only have one row
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if ([self.searchDisplayController.searchBar respondsToSelector:@selector(setCombinesLandscapeBars:)]) {
            objc_msgSend(self.searchDisplayController.searchBar, @selector(setCombinesLandscapeBars:), NO );
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[DataManager sharedInstance] useDatabaseWithCompletionHandler:^(BOOL success) {
        [self setupFetchedResultsController];
        
        // import if no data found
        if (self.fetchedResultsController.fetchedObjects.count == 0) {
            [self importDataIntoContext:[DataManager sharedInstance].managedObjectContext];
        }
    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark -
#pragma mark UITableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Song Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    
    Song *song = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = song.title;
    cell.detailTextLabel.text = song.author;
    
    return cell;
}

#pragma mark UISearchBarDelegate

-(void)filterSongs:(UISearchBar*)searchBar
{    
    // We use an NSPredicate combined with the fetchedResultsController to perform the search
    if (searchBar.text.length == 0) {
        NSPredicate *predicate =[NSPredicate predicateWithFormat:@"1=1"];
        [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    } else {
        NSPredicate *predicate = nil;
        // 0 is title, 1 author, 2 lyrics
        if (searchBar.selectedScopeButtonIndex == 0) {
            predicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@", searchBar.text];
        } else if (searchBar.selectedScopeButtonIndex == 1) {
            predicate = [NSPredicate predicateWithFormat:@"author contains[cd] %@", searchBar.text];
        } else {
            predicate = [NSPredicate predicateWithFormat:@"lyrics contains[cd] %@", searchBar.text];
        }
        [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    }
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }
}

-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    [self filterSongs:searchBar];
}

-(void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    searchBar.text = @"";
    [self filterSongs:searchBar];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    // reset table
    searchBar.text = @"";
    [self filterSongs:searchBar];

    // reset searchbar
    searchBar.tintColor = self.searchBarColorInactive;
    [searchBar resignFirstResponder];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    // save the inactive color first time only
    if (!self.searchBarColorInactive) {
        self.searchBarColorInactive = searchBar.tintColor;        
    }
    // make the searchbar tint color the same as the navifation controller
    if (self.navigationController) {
        searchBar.tintColor = self.navigationController.navigationBar.tintColor;
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    // reset the tint color if user is not searching anymore
    if (![self searchDisplayController].active) {
        searchBar.tintColor = self.searchBarColorInactive;
    }
}

#pragma mark -

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

@end