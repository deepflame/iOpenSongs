//
//  UIManagedDocumentTableViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 5/12/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "UIManagedDocumentTableViewController.h"
#import "UIManagedDocument+Use.h"

@interface UIManagedDocumentTableViewController ()

@end

@implementation UIManagedDocumentTableViewController

@synthesize database = _database;

// 1. Add code to viewWillAppear: to create a default document (for demo purposes)

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.database) {  
        // for demo purposes, we'll create a default database if none is set
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"Default Song Database"];
        // configure auto migration
        NSDictionary *storeOptions = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                      [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        // create managed document
        UIManagedDocument *doc = [[UIManagedDocument alloc] initWithFileURL:url];
        doc.persistentStoreOptions = storeOptions;
        self.database = doc; // setter will create this for us on disk
    }
}

// 2. Make the database's setter start using it

- (void)setDatabase:(UIManagedDocument *)database
{
    if (_database != database) {
        _database = database;
        [self useDocument];
    }
}

// 3. Open or create the document here and call setupFetchedResultsController

- (void)useDocument
{
    [self.database useWithCompletionHandler:^(BOOL success) {
        [self setupFetchedResultsController];
    }];
}

// 4. Create an NSFetchRequest and hook it up to our table via an NSFetchedResultsController
// (inherited the code to integrate with NSFRC from CoreDataTableViewController)

- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    NSLog(@"[%@ %@] function needs to be implemented in the super class", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    exit(-1);
}

@end
