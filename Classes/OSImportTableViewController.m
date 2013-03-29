//
//  OSImportTableViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/23/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "OSImportTableViewController.h"

@interface OSImportTableViewController () <UIActionSheetDelegate>
@property (nonatomic, strong) NSMutableSet *selectedIndexPaths;
// UI
@property (nonatomic, strong) UIBarButtonItem *actionBarButtonItem;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@end

@implementation OSImportTableViewController

@synthesize contents = _contents;
@synthesize initialPath = _initialPath;
@synthesize hud = _hud;

- (NSSet *)selectedContents
{
    NSMutableSet *set = [NSMutableSet set];
    for (NSIndexPath *indexPath in self.selectedIndexPaths) {
        OSFileDescriptor *fd = self.contents[indexPath.row];
        [set addObject:fd];
    }
    return set;
}

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
    self.selectedIndexPaths = [NSMutableSet set];

    // UI    
    UIView *viewForHud = self.navigationController ? self.navigationController.view : self.view;
    self.hud = [MBProgressHUD showHUDAddedTo:viewForHud animated:YES];
    self.actionBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                             target:self
                                                                             action:@selector(showActionSheet:)];
    
    self.navigationItem.rightBarButtonItems = @[self.actionBarButtonItem];
    
    
    self.actionSheet = [[UIActionSheet alloc ] initWithTitle:nil
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:@"Import"
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
            [self.selectedIndexPaths addObject:indexPath];
        } else {
            cell.accessoryType =  UITableViewCellAccessoryNone;
            [self.selectedIndexPaths removeObject:indexPath];
        }
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
        
        if ([self.selectedIndexPaths containsObject:indexPath]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }        
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
    // import
    if (buttonIndex == 0) {
        [self importAllSelectedItems];
        return;
    }

    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    // select or deselect all
    SEL selector;
    if ([buttonTitle isEqualToString:@"Select All"]) {
        selector = @selector(addObject:);
    } else if ([buttonTitle isEqualToString:@"Deselect All"]) {
        selector = @selector(removeObject:);
    }
    
    for (NSInteger s = 0; s < [self.tableView numberOfSections]; s++) {
        for (NSInteger r = 0; r < [self.tableView numberOfRowsInSection:s]; r++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:r inSection:s];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                        
            // select if it is not a directory
            if (![cell.detailTextLabel.text isEqualToString:@""]) {
                [self.selectedIndexPaths performSelector:selector withObject:indexPath];
            }
        }
    }
    
    [self.tableView reloadData];
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

#pragma mark -

- (void)importAllSelectedItems
{
    for (OSFileDescriptor *fd in self.selectedContents) {
        NSLog(@"%@", fd.filename);
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
