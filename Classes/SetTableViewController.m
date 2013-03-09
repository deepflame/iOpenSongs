//
//  SetTableViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 5/12/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "SetTableViewController.h"

#import "Set.h"

@interface SetTableViewController () <UITextFieldDelegate>
{
}

@end

@implementation SetTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(cancel:)];
    
    self.navigationItem.rightBarButtonItems = @[self.editButtonItem, addButtonItem];

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

#pragma mark - 

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

#pragma mark - UITableViewDataSource

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
    [self performSegueWithIdentifier:@"Select Set" sender:[self.fetchedResultsController objectAtIndexPath:indexPath]];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length == 0) {
        return NO;
    }
    
    [textField resignFirstResponder];
    return YES;
}

# pragma mark - 

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Select Set"]) {
        // check if destination accepts a songSet
        if ([segue.destinationViewController respondsToSelector:@selector(setSet:)]) {
            [segue.destinationViewController performSelector:@selector(setSet:) withObject:sender];
        }
    }
}

- (IBAction)addSetTextFieldDidEndEditing:(UITextField *)sender 
{
    if (sender.text.length > 0) {
        Set *newSet = [Set MR_createEntity];
        newSet.name = sender.text;
    }
    
    // clear the text field
    sender.text = @"";
}

@end
