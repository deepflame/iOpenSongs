//
//  DataManager.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 5/15/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "DataManager.h"
#import "UIManagedDocument+Use.h"

@interface DataManager ()

@property (nonatomic, strong) UIManagedDocument *database;  // Model is a Core Data database

@end


@implementation DataManager

@synthesize database = _database;

- (UIManagedDocument*) database
{
    if (_database) {
        return _database;
    }
    
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"Default Song Database"];
    
    // configure auto migration
    NSDictionary *storeOptions = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                      [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    // create managed document
    UIManagedDocument *doc = [[UIManagedDocument alloc] initWithFileURL:url];
    doc.persistentStoreOptions = storeOptions;
    _database = doc;
    
    return _database;
}

+ (DataManager*)sharedInstance
{
	static dispatch_once_t pred;
	static DataManager *sharedInstance = nil;
    
	dispatch_once(&pred, ^{ sharedInstance = [[self alloc] init]; });
	return sharedInstance;
}

- (void)useDatabaseWithCompletionHandler:(void (^)(BOOL success))completionHandler
{
    [self.database useWithCompletionHandler:completionHandler];
}

- (BOOL)save
{
	if (![self.managedObjectContext hasChanges]) {
		return YES;
    }
    
	NSError *error = nil;
    
    //[document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
    
	if ([self.managedObjectContext save:&error]) {
        return YES;
    } else {
		NSLog(@"Error while saving: %@\n%@", [error localizedDescription], [error userInfo]);
	}
    
    return NO;
}

- (NSManagedObjectContext*)managedObjectContext {
	return [self.database managedObjectContext];
}

@end
