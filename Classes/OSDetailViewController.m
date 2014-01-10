//
//  OSDetailViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 4/9/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "OSDetailViewController.h"

#import <FRLayeredNavigation.h>
#import "OSSupportTableViewController.h"

@interface OSDetailViewController () <OSSupportViewControllerDelegate>
@property (nonatomic, strong) OSSupportTableViewController *extrasTableViewController;
@end

@implementation OSDetailViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    UIBarButtonItem *sidebarBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_menu_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleSideMenu:)];
    UIBarButtonItem *supportBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Support", nil) style:UIBarButtonItemStylePlain target:self action:@selector(showSupportInfo:)];
    self.navigationItem.leftBarButtonItems = @[sidebarBarButtonItem];
    self.navigationItem.rightBarButtonItems = @[supportBarButtonItem];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - OSSupportViewControllerDelegate

- (void)supportViewController:(OSSupportTableViewController *)sender shouldFinishDisplaying:(BOOL)animated
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self dismissModalViewControllerAnimated:animated];
    } else {
        [self.navigationController popViewControllerAnimated:animated];
    }
}

#pragma mark - Actions

- (void)showSupportInfo:(id)sender
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.extrasTableViewController];
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
        navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:navController animated:YES];
    } else {
        [self.navigationController pushViewController:self.extrasTableViewController animated:YES];
    }
}

- (void)toggleSideMenu:(id)sender
{
    if (self.layeredNavigationItem.currentViewPosition.x == 0) {
        [self.layeredNavigationController expandViewControllersAnimated:YES];
    } else {
        [self.layeredNavigationController compressViewControllers:YES];
    }
}

#pragma mark - Private Accessors

- (OSSupportTableViewController *)extrasTableViewController
{
    if (!_extrasTableViewController) {
        _extrasTableViewController = [[OSSupportTableViewController alloc] init];
        _extrasTableViewController.delegate = self;
    }
    return _extrasTableViewController;
}

@end
