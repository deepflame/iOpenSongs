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
@end

@implementation OSDropboxImportTableViewController

@synthesize restClient = _restClient;

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
    
    // access Dropbox
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
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
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    NSArray * dbContents = [metadata.contents sortedArrayUsingComparator:^(id obj1, id obj2) {
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
    
    NSMutableArray *fdContents = [NSMutableArray array];
    for (DBMetadata *metadata in dbContents) {
        OSFileDescriptor *fd = [[OSFileDescriptor alloc] initWithDropboxMetadata:metadata];
        [fdContents addObject:fd];
    }
    self.contents = fdContents;
    
    [self.tableView reloadData];
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    NSLog(@"Error loading metadata: %@", error);
}

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)localPath {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        [Song updateOrCreateSongWithOpenSongFileFromURL:[NSURL fileURLWithPath:localPath] inManagedObjectContext:localContext];
    } completion:^(BOOL success, NSError *error){
        [[NSFileManager defaultManager] removeItemAtPath:localPath error:nil];
    }];
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error {
    NSLog(@"There was an error loading the file - %@", error);
}

#pragma mark - Actions

- (IBAction)importAllSelectedItems:(id)sender
{
    for (DBMetadata *metadata in self.selectedContents) {
        NSLog(@"%@", metadata.filename);
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
