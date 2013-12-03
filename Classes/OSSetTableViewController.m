//
//  SetTableViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 5/12/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "OSSetTableViewController.h"

#import "Set.h"
#import "OSSetItemsTableViewController.h"

#import "OSMainViewController.h"

@interface OSSetTableViewController () <UIAlertViewDelegate>
@property (nonatomic, strong) UIAlertView *setNameAlertView;
@property (nonatomic, strong) UITextField *setNameAlertViewTextField;
@property (nonatomic, strong) Set *currentSetForEditing;
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

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

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
        // rename set
        self.currentSetForEditing = set;
        self.setNameAlertViewTextField.text = set.name;        
        self.setNameAlertView.title = NSLocalizedString(@"Rename Set", nil);
        [self.setNameAlertView show];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1: // OK button
            
            if (self.setNameAlertViewTextField.text.length == 0) {
                return; // <-- !!
            }
            
            if (! self.currentSetForEditing) {
                self.currentSetForEditing = [Set MR_createEntity];
            }
            self.currentSetForEditing.name = self.setNameAlertViewTextField.text;
            
            break;
            
        default:
            break;
    }
}

#pragma mark - Public Accessors

- (UIAlertView *)setNameAlertView
{
    if (! _setNameAlertView) {
        _setNameAlertView = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        _setNameAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
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

@end
