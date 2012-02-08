//
//  ExtrasTableViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 2/5/12.
//  Copyright (c) 2012 Open iT Norge AS. All rights reserved.
//

#import "ExtrasTableViewController.h"
#import "HtmlViewController.h"

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
