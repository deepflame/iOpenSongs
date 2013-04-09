//
//  CoreDataSetupViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/10/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "OSStartupViewController.h"
#import "MBProgressHUD.h"

#import "Song.h"

#import "OSAppDelegate.h"
#import "OSMainViewController.h"
#import "UIApplication+Directories.h"

@interface OSStartupViewController ()

@property (nonatomic, assign) BOOL isMigratingInBackground;

@end

@implementation OSStartupViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    [self copySampleSongsToDocumentsDirectory];
    
    [self setupCoreData];
    
    if (!self.isMigratingInBackground) {
        [self showMainUI];
    }
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
    window.rootViewController = [[OSMainViewController alloc] init];
}

- (void) copySampleSongsToDocumentsDirectory
{
    NSString *sampleSong = @"Amazing Grace"; // TODO make more generic or use constant
    
    NSString *documentsDirectoryPath = [UIApplication documentsDirectoryPath];
    NSMutableArray *documentsDirectoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectoryPath error:NULL].mutableCopy;

    [documentsDirectoryContents removeObject:@".DS_Store"]; // fix for simulator
    
    if (documentsDirectoryContents.count == 0) {
        NSString *songSrcPath = [[NSBundle mainBundle] pathForResource:sampleSong ofType:@"" inDirectory:nil];
        NSString *songDstPath = [documentsDirectoryPath stringByAppendingPathComponent:sampleSong];
        
        NSFileManager *fileMan = [NSFileManager defaultManager];
        [fileMan copyItemAtPath:songSrcPath toPath:songDstPath error:nil];
    }
}

- (void) setupCoreData
{
    NSString *coreDataStoreFileName = [MagicalRecord defaultStoreName];
    NSURL *storeURL = [NSPersistentStore MR_urlForStoreName:coreDataStoreFileName];
    
    // if database not found we may have to move it
    if (![[NSFileManager defaultManager] isReadableFileAtPath:[storeURL path]]) {
        [self moveDatabaseToMRStoreName:coreDataStoreFileName];
        
        // if still not found initialize CoreData and return (new database)
        if (![[NSFileManager defaultManager] isReadableFileAtPath:[storeURL path]]) {
            [MagicalRecord setupCoreDataStackWithStoreNamed:coreDataStoreFileName];
            return;
        }
    }
    
    // we have a datastore and will check if we have to migrate it
    
    NSError *error = nil;
    [self migrateDataStore:storeURL error:&error];
    
    [MagicalRecord setupCoreDataStackWithStoreNamed:coreDataStoreFileName];
        
    [self initializeSongTitleSectionIndex];
}

- (BOOL) migrateDataStore:(NSURL *)storeURL error:(NSError **)error
{
    NSDictionary *storeMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
                                                                                             URL:storeURL
                                                                                           error:error];
    // TODO: Do error checking...
    
    BOOL success = NO;
    
    
    if ([self storeMetaData:storeMetadata isVersion:3]) {
        success = YES; // nothing to do
    }
    
    else if ([self storeMetaData:storeMetadata isVersion:2]) {
        success = [self migrateStore:storeURL
                      fromModelNamed:@"iOpenSongs 2.mom"
                        toModelNamed:@"iOpenSongs 3.mom" error:error];
    }
    
    else if ([self storeMetaData:storeMetadata isVersion:1]) {
        success = [self migrateStore:storeURL
                      fromModelNamed:@"iOpenSongs 1.mom"
                        toModelNamed:@"iOpenSongs 3.mom" error:error];
    }
    
    return success;
}

- (BOOL)storeMetaData:(NSDictionary *)metaData isVersion:(NSUInteger)version
{
    NSString *modelName = [NSString stringWithFormat:@"iOpenSongs %u.mom", version];
    NSManagedObjectModel *model = [NSManagedObjectModel MR_newModelNamed:modelName inBundleNamed:@"iOpenSongs.momd"];
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    NSManagedObjectModel *destinationModel = [psc managedObjectModel];
    BOOL pscCompatible = [destinationModel isConfiguration:nil compatibleWithStoreMetadata:metaData];
    
    return pscCompatible;
}


- (BOOL)migrateStore:(NSURL *)storeURL fromModelNamed:(NSString *)srcModelName toModelNamed:(NSString *)dstModelName error:(NSError **)error {

    NSManagedObjectModel *srcModel = [NSManagedObjectModel MR_newModelNamed:srcModelName inBundleNamed:@"iOpenSongs.momd"];
    NSManagedObjectModel *dstModel = [NSManagedObjectModel MR_newModelNamed:dstModelName inBundleNamed:@"iOpenSongs.momd"];

    NSMappingModel *mappingModel = [NSMappingModel inferredMappingModelForSourceModel:srcModel
                                                                     destinationModel:dstModel
                                                                                error:error];
    // return if we cannot map the models
    if (!mappingModel) {
        return NO;
    }

    NSURL *dstStoreURL = [storeURL URLByAppendingPathExtension:@"tmp"];
    
    NSFileManager *fileMan = [NSFileManager defaultManager];
    if ([fileMan fileExistsAtPath:[dstStoreURL path]]) {
        [fileMan removeItemAtURL:dstStoreURL error:error];
    }
    
    NSMigrationManager *manager = [[NSMigrationManager alloc] initWithSourceModel:srcModel destinationModel:dstModel];
    
    // migrate
    BOOL success = [manager migrateStoreFromURL:storeURL
                                           type:NSSQLiteStoreType
                                        options:nil
                               withMappingModel:mappingModel
                               toDestinationURL:dstStoreURL
                                destinationType:NSSQLiteStoreType
                             destinationOptions:nil
                                          error:error];
    
    // move migrated database
    if (success) {        
        NSURL *oldStoreURL = [storeURL URLByAppendingPathExtension:@"old"];
        
        if ([fileMan fileExistsAtPath:[oldStoreURL path]]) {
            [fileMan removeItemAtURL:oldStoreURL error:error];
        }
        
        // backup last version
        success = [fileMan moveItemAtURL:storeURL toURL:oldStoreURL error:error];
        // set new version
        success = [fileMan moveItemAtURL:dstStoreURL toURL:storeURL error:error];
    }
    
    return success;
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
    if (![fileMan fileExistsAtPath:[oldUrl path]]) {
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

- (void) initializeSongTitleSectionIndex
{
    NSArray *songsNeedUpdate = [Song MR_findByAttribute:@"titleSectionIndex" withValue:nil];
    
    // return if no update needed
    if (songsNeedUpdate.count == 0) {
        return;
    }
    
    self.isMigratingInBackground = YES;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.labelText = @"Updating Database";
    hud.detailsLabelText = @"please wait...";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        
        [songsNeedUpdate enumerateObjectsUsingBlock:^(Song *song, NSUInteger idx, BOOL *stop) {
            hud.progress = (float)idx / (float)songsNeedUpdate.count;
            
            Song *songInContext = [song MR_inContext:context];
            
            // also sets other title properties
            songInContext.title = songInContext.title;
            
            // save every 100 songs
            if (idx % 100 == 0) {
                [context MR_saveToPersistentStoreAndWait];
            }
        }];
        [context MR_saveToPersistentStoreAndWait];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:YES];
            [self showMainUI];
        });
        
    });
    
}

@end
