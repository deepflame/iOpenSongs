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

@interface OSSetTableViewController () <UITextFieldDelegate>
@property (nonatomic, strong) UIAlertView *setNameAlertView;
@property (nonatomic, strong) UITextField *setNameAlertViewTextField;
@end

@implementation OSSetTableViewController

#pragma mark - UIViewController

- (NSString *)title
{
    return @"Sets";
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    UIBarButtonItem *addBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd handler:^(id sender){
        self.setNameAlertView.title = @"New Set";
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
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d Songs", set.items.count];
    
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
    
    OSSetItemsTableViewController *setItemsTVC = [[OSSetItemsTableViewController alloc] init];
    setItemsTVC.set = set;
    setItemsTVC.delegate = (OSMainViewController *)self.layeredNavigationController;
    
    [self.delegate setTableViewController:self didSelectSet:set];
    [self.navigationController pushViewController:setItemsTVC animated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length == 0) {
        return NO;
    }
    
    Set *newSet = [Set MR_createEntity];
    newSet.name = textField.text;
    
    // clear the text field
    textField.text = @"";
    [textField resignFirstResponder];

    [self.setNameAlertView dismissWithClickedButtonIndex:0 animated:YES];
    
    return YES;

#pragma mark - Public Accessors

- (UIAlertView *)setNameAlertView
{
    if (! _setNameAlertView) {
        _setNameAlertView = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
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
