//
//  OSFileTableViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/20/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "OSFileTableViewController.h"

#import <DropboxSDK/DropboxSDK.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface OSFileTableViewController () <DBRestClientDelegate>
@property (nonatomic, strong, readonly) DBRestClient *restClient;
@property (nonatomic, strong, readonly) NSString *initialPath;
@property (nonatomic, strong) DBMetadata *metaData;
@end

@implementation OSFileTableViewController

@synthesize restClient = _restClient;
@synthesize initialPath = _initialPath;
@synthesize metaData = _metaData;

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
    return self.metaData.contents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    DBMetadata *itemMetaData = self.metaData.contents[indexPath.row];
    cell.textLabel.text = itemMetaData.filename;
    if (itemMetaData.isDirectory) {
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
    DBMetadata *itemMetaData = self.metaData.contents[indexPath.row];
    
    if (itemMetaData.isDirectory) {
        NSString *newPath = [self.initialPath stringByAppendingPathComponent:itemMetaData.filename];
        OSFileTableViewController *fileTableViewController = [[OSFileTableViewController alloc] initWithPathString:newPath];
        [self.navigationController pushViewController:fileTableViewController animated:YES];
    }
}

#pragma mark - DBRestClientDelegate

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    self.metaData = metadata;
    [self.tableView reloadData];
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    NSLog(@"Error loading metadata: %@", error);
}

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)localPath {
    NSLog(@"File loaded into path: %@", localPath);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error {
    NSLog(@"There was an error loading the file - %@", error);
}

@end
