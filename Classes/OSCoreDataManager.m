//
//  OSCoreDataManager.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 12/4/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "OSCoreDataManager.h"

@implementation OSCoreDataManager

+ (instancetype)sharedManager
{
    static id _sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (void)setupAndMigrateCoreData
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
}

- (BOOL)migrateDataStore:(NSURL *)storeURL error:(NSError **)error
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
- (void)moveDatabaseToMRStoreName:(NSString *)storeName
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

@end
