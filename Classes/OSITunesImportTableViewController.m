//
//  OSITunesImportTableViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/23/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "OSITunesImportTableViewController.h"

#import "UIApplication+Directories.h"

@interface OSITunesImportTableViewController ()

@end

@implementation OSITunesImportTableViewController

- (id)init
{
    return [self initWithPath:[UIApplication documentsDirectoryPath]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    NSString *title = self.initialPath.lastPathComponent;
    if ([self.initialPath isEqualToString:[UIApplication documentsDirectoryPath]]) {
        title = @"iTunes";
    }
    self.title = title;
    
    
    NSString *documentsDirectoryPath = [UIApplication documentsDirectoryPath];
    NSArray *documentsDirectoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectoryPath error:NULL];
    
    NSMutableArray *fdContents = [NSMutableArray array];
    for (NSString *dirItem in documentsDirectoryContents) {
        NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:dirItem];
        OSFileDescriptor *fd = [[OSFileDescriptor alloc] initWithPath:filePath];
        [fdContents addObject:fd];
    }
    self.contents = fdContents;
    [self.hud hide:NO];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)importAllSelectedItems
{
    // show HUD
    self.hud.mode = MBProgressHUDModeAnnularDeterminate;
    self.hud.labelText = @"Importing";
    [self.hud show:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        
        [[self.selectedContents allObjects] enumerateObjectsUsingBlock:^(OSFileDescriptor *fd, NSUInteger idx, BOOL *stop) {
            NSURL *fileURL = [NSURL fileURLWithPath:fd.path];
            NSError *error = nil;
            
            [Song updateOrCreateSongWithOpenSongFileFromURL:fileURL inManagedObjectContext:context error:&error];
            
            if (error) {
                [self.importErrors addObject:error];
            }
            
            // save every 100 songs
            if (idx % 100 == 0) {
                [context MR_saveToPersistentStoreAndWait];
            }
            
            // update progress
            self.hud.progress = (float)(idx + 1) / (float)self.selectedContents.count;
        }];
        [context MR_saveToPersistentStoreAndWait];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            // dismiss HUD
            [self.hud hide:YES];
            
            [self handleImportErrors];
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
        
    });
}

@end
