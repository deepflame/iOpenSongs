//
//  OSImportTableViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/23/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "OSImportTableViewController.h"

@interface OSImportTableViewController () <UIActionSheetDelegate>
// UI
@property (nonatomic, strong) UIBarButtonItem *actionBarButtonItem;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@end

@implementation OSImportTableViewController

@synthesize contents = _contents;
@synthesize selectedContents = _selectedContents;
@synthesize initialPath = _initialPath;

#pragma mark -

- (id)initWithPath:(NSString *)path
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
    
    // initialization
    self.selectedContents = [NSMutableArray array];

    // UI
    self.importBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                             target:self
                                                                             action:@selector(importAllSelectedItems:)];
    self.importBarButtonItem.enabled = NO;
    self.actionBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                             target:self
                                                                             action:@selector(showActionSheet:)];
    
    self.navigationItem.rightBarButtonItems = @[self.importBarButtonItem, self.actionBarButtonItem];
    
    
    self.actionSheet = [[UIActionSheet alloc ] initWithTitle:nil
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:@"Select All", @"Deselect All", nil];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OSFileDescriptor *itemMetaData = self.contents[indexPath.row];
    NSString *newPath = [self.initialPath stringByAppendingPathComponent:itemMetaData.filename];
    
    if (itemMetaData.isDirectory) {
        OSImportTableViewController *fileTableViewController = [[self.class alloc] initWithPath:newPath];
        [self.navigationController pushViewController:fileTableViewController animated:YES];
    } else {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        BOOL cellSelected = cell.accessoryType == UITableViewCellAccessoryNone;
        if (cellSelected) {
            cell.accessoryType =  UITableViewCellAccessoryCheckmark;
            id obj = self.contents[indexPath.row];
            [self.selectedContents addObject:obj];
        } else {
            cell.accessoryType =  UITableViewCellAccessoryNone;
            [self.selectedContents removeObject:self.contents[indexPath.row]];
        }
        
        self.importBarButtonItem.enabled = (self.selectedContents.count > 0) ? YES : NO;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    OSFileDescriptor *fd = self.contents[indexPath.row];
    cell.textLabel.text = fd.filename;
    if (fd.isDirectory) {
        cell.detailTextLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.detailTextLabel.text = fd.humanReadableSize;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.contents.count;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([actionSheet.title isEqualToString:@"Select All"]) {
        
    } else if ([actionSheet.title isEqualToString:@"Deselect All"]) {
        
    }
}

#pragma mark - Actions

- (IBAction)showActionSheet:(id)sender
{
    if (! [self.actionSheet isVisible]) {
        [self.actionSheet showFromBarButtonItem:sender animated:YES];
    } else {
        [self.actionSheet dismissWithClickedButtonIndex:-1 animated:YES];
    }
}

- (IBAction)importAllSelectedItems:(id)sender
{
    for (OSFileDescriptor *fd in self.selectedContents) {
        NSLog(@"%@", fd.filename);
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
