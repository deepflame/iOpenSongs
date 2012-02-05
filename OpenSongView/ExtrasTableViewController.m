//
//  ExtrasTableViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 2/5/12.
//  Copyright (c) 2012 Open iT Norge AS. All rights reserved.
//

#import "ExtrasTableViewController.h"
#import "WebViewController.h"
#import "SongViewController.h"

@interface ExtrasTableViewController ()
{
    IBOutlet UISwitch *nightModeSwitch;
}

@end


@implementation ExtrasTableViewController

@synthesize nightModeEnabled = _nightModeEnabled;
@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;    
}

- (void)viewDidUnload
{
    nightModeSwitch = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    nightModeSwitch.on = self.nightModeEnabled;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //UIViewController *newController = segue.destinationViewController;
    
    if ([segue.identifier isEqualToString:@"help"]) {
        //newController.title = @"Help";
    } else if ([segue.identifier isEqualToString:@"about"]) {
        //newController.title = @"About";
    }
}

#pragma mark

- (IBAction)nightMode:(UISwitch *)sender {
    [self.delegate extrasTableViewControllerDelegate:self changedNightMode:sender.on];
}


@end
