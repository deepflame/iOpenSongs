//
//  ExtrasTableViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 2/5/12.
//  Copyright (c) 2012 Open iT Norge AS. All rights reserved.
//

#import "ExtrasTableViewController.h"
#import "HtmlViewController.h"
#import <MessageUI/MessageUI.h>

@interface ExtrasTableViewController () <MFMailComposeViewControllerDelegate>
{
    IBOutlet UISwitch *nightModeSwitch;
}

@end


@implementation ExtrasTableViewController

@synthesize nightModeEnabled = _nightModeEnabled;
@synthesize delegate = _delegate;

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    nightModeSwitch = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    nightModeSwitch.on = self.nightModeEnabled;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // TODO: select based on title
    if (indexPath.section == 2 && indexPath.row == 0 && [MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:@"[iOpenSongs] Feedback"];
        [mailViewController setToRecipients:[NSArray arrayWithObject:@"iOpenSongs@boehrnsen.de"]];
        [self presentModalViewController:mailViewController animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - MFMailComposeViewControllerDelegate
                                                 
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
    [self dismissModalViewControllerAnimated:YES];
    [self.delegate extrasTableViewControllerDelegate:self dismissMyPopoverAnimated:FALSE];
}
                                                 
#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{    
    if ([segue.identifier isEqualToString:@"Show Help"]) {
        HtmlViewController *htmlVC = (HtmlViewController *) segue.destinationViewController;

        htmlVC.title = @"Help";
        htmlVC.resourceURL = [[NSBundle mainBundle] URLForResource:@"help" withExtension:@"html"];
    } else if ([segue.identifier isEqualToString:@"Show About"]) {
        HtmlViewController *htmlVC = (HtmlViewController *) segue.destinationViewController;
        
        htmlVC.title = @"About";
        htmlVC.resourceURL = [[NSBundle mainBundle] URLForResource:@"about" withExtension:@"html"];
    }
}

#pragma mark - IBActions

- (IBAction)nightMode:(UISwitch *)sender {
    self.nightModeEnabled = sender.on;
    [self.delegate extrasTableViewControllerDelegate:self changedNightMode:self.nightModeEnabled];
}


@end
