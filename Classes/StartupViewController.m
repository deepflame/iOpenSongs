//
//  CoreDataSetupViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/10/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "StartupViewController.h"
#import "MBProgressHUD.h"

#import "Song.h"

#import "AppDelegate.h"

@interface StartupViewController ()

@end

@implementation StartupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupCoreData];
    
    //[self showMainUI]; // will be called from 'setupCoreData'
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark Private Methods

- (void) showMainUI
{
    UIWindow *window = [[UIApplication sharedApplication] windows][0];
    UIStoryboard *storyboard = [[AppDelegate sharedAppDelegate] storyboard];
    window.rootViewController = [storyboard instantiateInitialViewController];
}

- (MBProgressHUD *) initializeHUD
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[self view] animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.labelText = @"Updating Database";
    hud.detailsLabelText = @"Please Wait";
    return hud;
}

- (void) initializeSongTitleSectionIndex
{
    NSArray *songsNeedUpdate = [Song MR_findByAttribute:@"titleSectionIndex" withValue:nil];
    
    // return if no update needed
    if (songsNeedUpdate.count == 0) {
        [self showMainUI];
        return;
    }
    
    MBProgressHUD *hud = [self initializeHUD];
    
    dispatch_queue_t migrationQ = dispatch_queue_create("CoreData Migration", NULL);
    dispatch_async(migrationQ, ^{
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        
        [context performBlock:^{ // perform in the NSMOC's safe thread (main thread)
            [songsNeedUpdate enumerateObjectsUsingBlock:^(Song *song, NSUInteger idx, BOOL *stop) {
                hud.progress = (float)idx / (float)songsNeedUpdate.count;
            
                // also sets other title properties
                song.title = song.title;

                // save every 100 songs
                if (idx % 100 == 0) {
                    [context MR_saveToPersistentStoreAndWait];
                }
            }];
            [context MR_saveToPersistentStoreAndWait];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:YES];
            [self showMainUI];
        });
        
    });
    // TODO: may have to remove it due to ARC
    dispatch_release(migrationQ);
}

- (void) setupCoreData
{
    NSString *coreDataStoreFileName = [MagicalRecord defaultStoreName];
    
    [self moveDatabaseToMRStoreName:coreDataStoreFileName];
    
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:coreDataStoreFileName];
    
    [self initializeSongTitleSectionIndex];
}

/** migrates/moves the database to the new MR location */
- (void) moveDatabaseToMRStoreName:(NSString *)storeName
{
    NSFileManager *fileMan = [NSFileManager defaultManager];
    
    NSURL *oldDirUrl = [[fileMan URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
    oldDirUrl = [oldDirUrl URLByAppendingPathComponent:@"Default Song Database"];
    NSURL *oldUrl = [oldDirUrl URLByAppendingPathComponent:@"StoreContent"];
    oldUrl = [oldUrl URLByAppendingPathComponent:@"persistentStore"];
    
    NSURL *newUrl = [NSPersistentStore MR_urlForStoreName:storeName];
    
    // return if old db file does not exist
    if (![fileMan isReadableFileAtPath:[oldUrl path]]) {
        return;
    }
    
    // TODO: move this part into a category of NSFileManager
    NSError *error;
    // create directory of target path
    [fileMan createDirectoryAtURL:[newUrl URLByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&error];
    // copy file
    [fileMan copyItemAtURL:oldUrl toURL:newUrl error:&error];
    // delete old db dir
    [fileMan removeItemAtURL:oldDirUrl error:&error];
}

@end
