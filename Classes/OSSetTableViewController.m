//
//  SetTableViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 5/12/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "OSSetTableViewController.h"

#import "NSManagedObject+Cloning.h"

#import "Set.h"
#import "SetItem.h"
#import "OSSetItemsTableViewController.h"

#import "OSMainViewController.h"

typedef NS_ENUM(NSInteger, SetActionType) {
    SetActionNew,
    SetActionEdit,
    SetActionClone
};

@interface OSSetTableViewController () <UIAlertViewDelegate>
@property (nonatomic, strong) UIAlertView *setNameAlertView;
@property (nonatomic, strong) UITextField *setNameAlertViewTextField;
@property (nonatomic, strong) UIActionSheet *editSetActionSheet;
@property (nonatomic, strong) Set *currentSetForEditing;
@property (nonatomic)         NSInteger setActionType;
@end

@implementation OSSetTableViewController

#pragma mark - UIViewController

- (NSString *)title
{
    return NSLocalizedString(@"Sets", nil);
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    self.tableView.allowsSelectionDuringEditing = YES;
    
    UIBarButtonItem *addBarButtonItem = [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemAdd handler:^(id sender){
        self.currentSetForEditing = nil;
        self.setNameAlertViewTextField.text = @"";
        self.setNameAlertView.title = NSLocalizedString(@"New Set", nil);
        self.setActionType = SetActionNew;
        [self.setNameAlertView show];
    }];

    // barButtonItems
    self.navigationItem.leftBarButtonItems = @[addBarButtonItem];
    self.navigationItem.rightBarButtonItems = @[self.editButtonItem];

    // load data
    self.fetchedResultsController = [Set MR_fetchAllSortedBy:@"name"
                                                   ascending:YES
                                               withPredicate:nil
                                                     groupBy:nil
                                                    delegate:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Set Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    
    Set *set = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = set.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d Songs", nil), set.items.count];
    
    return cell;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // delete object from database
        Set *set = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [set MR_deleteEntity];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Set *set = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (! tableView.editing) {
        // display set items
        OSSetItemsTableViewController *setItemsTVC = [[OSSetItemsTableViewController alloc] init];
        setItemsTVC.set = set;
        setItemsTVC.delegate = (OSMainViewController *)self.layeredNavigationController;
        
        [self.delegate setTableViewController:self didSelectSet:set];
        [self.navigationController pushViewController:setItemsTVC animated:YES];
        
    } else {
        self.currentSetForEditing = set;
        
        CGRect rect = [tableView rectForRowAtIndexPath:indexPath];
        [self.editSetActionSheet showFromRect:rect inView:tableView animated:YES];
    }
}

#pragma mark - Public Accessors

- (UIAlertView *)setNameAlertView
{
    if (! _setNameAlertView) {
        _setNameAlertView = [UIAlertView bk_alertViewWithTitle:nil];
        _setNameAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;

        [_setNameAlertView bk_addButtonWithTitle:NSLocalizedString(@"OK", nil) handler:^ {
            if (self.setNameAlertViewTextField.text.length == 0) {
                return; // <-- !!
            }
            
            switch (self.setActionType) {
                case SetActionNew:
                    self.currentSetForEditing = [Set MR_createEntity];
                    break;
                    
                case SetActionClone:
                    self.currentSetForEditing = [self.currentSetForEditing clone];
                    break;
                
                default:
                    break;
            }
            
            self.currentSetForEditing.name = self.setNameAlertViewTextField.text;
        }];
        
        // Cancel Button
        [_setNameAlertView bk_setCancelButtonWithTitle:nil handler:nil];
    }
    return _setNameAlertView;
}

- (UITextField *)setNameAlertViewTextField
{
    if (! _setNameAlertViewTextField) {
        _setNameAlertViewTextField = [self.setNameAlertView textFieldAtIndex:0];
    }
    return _setNameAlertViewTextField;
}

- (UIActionSheet *)editSetActionSheet
{
    if (! _editSetActionSheet) {
        _editSetActionSheet = [UIActionSheet bk_actionSheetWithTitle:nil];
        
        // Rename Set
        [_editSetActionSheet bk_addButtonWithTitle:NSLocalizedString(@"Rename Set", nil) handler:^{
            self.setNameAlertViewTextField.text = self.currentSetForEditing.name;
            self.setNameAlertView.title = NSLocalizedString(@"Rename Set", nil);
            self.setActionType = SetActionEdit;
            [self.setNameAlertView show];
        }];
        
        // Duplicate Set
        [_editSetActionSheet bk_addButtonWithTitle:NSLocalizedString(@"Duplicate Set", nil) handler:^{
            self.setNameAlertViewTextField.text = self.currentSetForEditing.name;
            self.setNameAlertView.title = NSLocalizedString(@"New Set", nil);
            self.setActionType = SetActionClone;
            [self.setNameAlertView show];
        }];
        
        // Cancel Button
        [_editSetActionSheet bk_setCancelButtonWithTitle:nil handler:nil];
    }
    return _editSetActionSheet;
}

@end
