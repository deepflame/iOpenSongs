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
#import "OSMacros.h"

@interface OSDetailViewController () <OSSupportViewControllerDelegate>
@property (nonatomic, strong) OSSupportTableViewController *supportViewController;
@end

@implementation OSDetailViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    UIBarButtonItem *sidebarBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_menu_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleSideMenu:)];
    UIBarButtonItem *supportBarButtonItem;
 
    // show icon in iOS 7
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        supportBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_194_circle_question_mark"] style:UIBarButtonItemStylePlain target:nil action:nil];
    } else {
        supportBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Support", nil) style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    supportBarButtonItem.target = self;
    supportBarButtonItem.action = @selector(showSupportInfo:);

    sidebarBarButtonItem.accessibilityLabel = @"Sidebar";
    supportBarButtonItem.accessibilityLabel = @"Support";
    
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
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.supportViewController];
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
        navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:navController animated:YES];
    } else {
        [self.navigationController pushViewController:self.supportViewController animated:YES];
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

- (OSSupportTableViewController *)supportViewController
{
    if (!_supportViewController) {
        _supportViewController = [[OSSupportTableViewController alloc] init];
        _supportViewController.delegate = self;
    }
    return _supportViewController;
}

@end
