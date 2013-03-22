//
//  OSFileTableViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/20/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "OSFileTableViewController.h"

#import "Song+Import.h"

#import <DropboxSDK/DropboxSDK.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface OSFileTableViewController () <DBRestClientDelegate>
@property (nonatomic, strong, readonly) DBRestClient *restClient;
@property (nonatomic, strong, readonly) NSString *initialPath;
@property (nonatomic, strong) DBMetadata *metaData;
@property (nonatomic, strong) NSArray *sortedContents;
@property (nonatomic, strong) NSMutableArray *selectedContents;

@property (nonatomic, strong) UIBarButtonItem *importBarButtonItem;
@end

@implementation OSFileTableViewController

@synthesize restClient = _restClient;
@synthesize initialPath = _initialPath;
@synthesize metaData = _metaData;
@synthesize sortedContents = _sortedContents;
@synthesize selectedContents = _selectedContents;

- (DBRestClient *)restClient {
    if (!_restClient) {
        _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _restClient.delegate = self;
    }
    return _restClient;
}

- (id)initWithPathString:(NSString *)path
{
    self = [super init];
    if (self) {
        // Custom initialization
        _initialPath = path;
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString *title = self.initialPath.lastPathComponent;
    if ([title isEqualToString:@"/"]) {
        title = @"Dropbox";
    }
    self.title = title;
    
    self.selectedContents = [NSMutableArray array];
    self.importBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                         target:self
                                                                             action:@selector(importAllSelectedItems:)];
    self.importBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItems = @[self.importBarButtonItem];
    
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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sortedContents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    DBMetadata *itemMetaData = self.sortedContents[indexPath.row];
    cell.textLabel.text = itemMetaData.filename;
    if (itemMetaData.isDirectory) {
        cell.detailTextLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.detailTextLabel.text = itemMetaData.humanReadableSize;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
        
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBMetadata *itemMetaData = self.sortedContents[indexPath.row];
    NSString *newPath = [self.initialPath stringByAppendingPathComponent:itemMetaData.filename];
    
    if (itemMetaData.isDirectory) {
        OSFileTableViewController *fileTableViewController = [[OSFileTableViewController alloc] initWithPathString:newPath];
        [self.navigationController pushViewController:fileTableViewController animated:YES];
    } else {
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        BOOL cellSelected = cell.accessoryType == UITableViewCellAccessoryNone;
        if (cellSelected) {
            cell.accessoryType =  UITableViewCellAccessoryCheckmark;
            id obj = self.sortedContents[indexPath.row];
            [self.selectedContents addObject:obj];
        } else {
            cell.accessoryType =  UITableViewCellAccessoryNone;
            [self.selectedContents removeObject:self.sortedContents[indexPath.row]];
        }
        
        self.importBarButtonItem.enabled = (self.selectedContents.count > 0) ? YES : NO;
    }
}

#pragma mark - DBRestClientDelegate

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    self.metaData = metadata;
    self.sortedContents = [metadata.contents sortedArrayUsingComparator:^(id obj1, id obj2) {
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
