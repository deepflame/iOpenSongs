//
//  SongViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 12/31/11.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "OSSongViewController.h"

#import "OSSongMasterViewController.h"
#import "OSRevealSidebarController.h"
#import "OSSupportTableViewController.h"

#pragma mark SongViewController () 

@interface OSSongViewController () <UIWebViewDelegate, OSSongViewDelegate ,OSSupportViewControllerDelegate>
@property (nonatomic, strong) Song *song;
// UI
@property (nonatomic, strong) UIPopoverController *extrasPopoverController;
@property (nonatomic, strong) OSSupportTableViewController *extrasTableViewController;
@end

@implementation OSSongViewController

@synthesize song = _song;
@synthesize extrasPopoverController = _extrasPopoverController;
@synthesize extrasTableViewController = _extrasTableViewController;


- (id)initWithSong:(Song *)song
{
    self = [super init];
    if (self) {
        _song = song;
    }
    return self;
}

#pragma mark - UIView

- (void)loadView
{
    OSSongView *songView = [[OSSongView alloc] init];
    songView.delegate = self;
    songView.song = self.song;
    self.view = songView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *revealBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_menu_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(revealSideMenu:)];
    UIBarButtonItem *supportBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Support" style:UIBarButtonItemStylePlain target:self action:@selector(showSupportInfo:)];
    self.navigationItem.leftBarButtonItems = @[revealBarButtonItem];
    self.navigationItem.rightBarButtonItems = @[supportBarButtonItem];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - OSSongViewDelegate

- (void)songViewDidChangeSong:(Song *)song
{
    self.title = song.title;
}

#pragma mark - OSSupportViewControllerDelegate

- (void)dismissSupportPopoverAnimated:(BOOL)animated
{
    [self.extrasPopoverController dismissPopoverAnimated:animated];
}

#pragma mark - Actions

- (IBAction)showSupportInfo:(id)sender
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (self.extrasPopoverController.popoverVisible) {
            [self.extrasPopoverController dismissPopoverAnimated:YES];
        } else {
            [self.extrasPopoverController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItems[0]
                                                 permittedArrowDirections:UIPopoverArrowDirectionAny
                                                                 animated:YES];
        }
    } else {
        [self.navigationController pushViewController:self.extrasTableViewController animated:YES];
    }
}

- (IBAction)revealSideMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

#pragma mark - Private Accessor Overrides

- (OSSupportTableViewController *)extrasTableViewController
{
    if (!_extrasTableViewController) {
        _extrasTableViewController = [[OSSupportTableViewController alloc] init];
        _extrasTableViewController.delegate = self;
    }
    return _extrasTableViewController;
}

- (UIPopoverController *)extrasPopoverController
{
    if (!_extrasPopoverController) {
        UINavigationController *extrasNC = [[UINavigationController alloc] initWithRootViewController:self.extrasTableViewController];
        _extrasPopoverController = [[UIPopoverController alloc] initWithContentViewController:extrasNC];
    }
    return _extrasPopoverController;
}

#pragma mark - Public Accessor Overrides

- (OSSongView *)songView
{
    return (OSSongView *)self.view;
}

@end
