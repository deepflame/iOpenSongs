//
//  OSFileTableViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/20/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "OSDropboxImportTableViewController.h"

#import "Song+Import.h"
#import "OSFileDescriptor+Dropbox.h"

#import <DropboxSDK/DropboxSDK.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface OSDropboxImportTableViewController () <DBRestClientDelegate>
@property (nonatomic, strong, readonly) DBRestClient *restClient;
@property (nonatomic, strong) NSMutableArray *filesToImport;
@end

@implementation OSDropboxImportTableViewController

@synthesize restClient = _restClient;
@synthesize filesToImport = _filesToImport;

#pragma mark -

- (DBRestClient *)restClient {
    if (!_restClient) {
        _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _restClient.delegate = self;
    }
    return _restClient;
}

#pragma mark - 

- (id)init
{
    return [super initWithPath:@"/"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString *title = self.initialPath.lastPathComponent;
    if ([title isEqualToString:@"/"]) {
        title = @"Dropbox";
    }
    self.title = title;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // access Dropbox
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.restClient loadMetadata:self.initialPath];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - DBRestClientDelegate

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    [self.hud hide:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    // sort directories first
    NSArray *dbContents = [metadata.contents sortedArrayUsingComparator:^(id obj1, id obj2) {
        DBMetadata *md1 = obj1;
        DBMetadata *md2 = obj2;
        
        if (md1.isDirectory != md2.isDirectory) {
            if (md1.isDirectory) {
                return (NSComparisonResult)NSOrderedAscending;
            } else {
                return (NSComparisonResult)NSOrderedDescending;
            }
        }
        
        return [md1.filename localizedCompare:md2.filename];
    }];
    
    // map to internal format
    self.contents = [dbContents map:^id(DBMetadata *md) {
        return [[OSFileDescriptor alloc] initWithDropboxMetadata:md];
    }];
    
    [self.tableView reloadData];
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
    [self.hud hide:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    NSLog(@"Error loading metadata: %@", error);
    
    [UIAlertView showAlertViewWithTitle:@"Error contacting Dropbox"
                                message:@"Make sure that you are connected to the Internet."
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil
                                handler:nil];

    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)localPath {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    NSError *error = nil;
    
    // save song, delete temp file
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    [Song updateOrCreateSongWithOpenSongFileFromURL:[NSURL fileURLWithPath:localPath] inManagedObjectContext:context error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:localPath error:nil];
    
    if (error) {
        [self.importErrors addObject:error];
    }
    
    // update progress
    self.hud.progress = (float)(self.selectedContents.count - self.filesToImport.count) / (float)self.selectedContents.count;
    
    [self loadNextFileToImportOrReturn];
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error {
    NSLog(@"There was an error loading the file - %@", error);
    
    [self.importErrors addObject:error];
    
    [self loadNextFileToImportOrReturn];
}

#pragma mark -

- (void)loadNextFileToImportOrReturn
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    
    // save every 50 files
    if (self.filesToImport.count % 50 == 0) {
        [context MR_saveToPersistentStoreAndWait];
    }
    
    // save, hide hud and return if no files to import
    if (self.filesToImport.count == 0) {
        [context MR_saveToPersistentStoreAndWait];
        [self.hud hide:YES];
        
        [self handleImportErrors];
        [self.navigationController popToRootViewControllerAnimated:YES];
        return; // <- !!
    }
    
    // import next file
    OSFileDescriptor *fd = self.filesToImport.lastObject;
    [self.filesToImport removeLastObject];
    
    NSString *dbPath = [self.initialPath stringByAppendingPathComponent:fd.filename];
    NSString *localPath = [NSTemporaryDirectory() stringByAppendingPathComponent:fd.filename];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.restClient loadFile:dbPath intoPath:localPath];
}

- (void)importAllSelectedItems
{    
    // show HUD
    self.hud.mode = MBProgressHUDModeAnnularDeterminate;
    self.hud.labelText = @"Importing";
    [self.hud show:YES];
    
    self.filesToImport = [[self.selectedContents allObjects] mutableCopy];
    [self loadNextFileToImportOrReturn];    
}

@end
