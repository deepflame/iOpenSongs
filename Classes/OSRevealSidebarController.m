//
//  RevealSidebarViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/24/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "OSRevealSidebarController.h"

#import "OSSongMasterViewController.h"
#import "OSSetTableViewController.h"

@interface OSRevealSidebarController ()

@end

@implementation OSRevealSidebarController

-(void)viewDidLoad
{
    [super viewDidLoad];

    // build tabbar
    UIViewController *songsViewController = [[OSSongMasterViewController alloc] init];
    UIViewController *setsViewController = [[OSSetTableViewController alloc] init];
    UIViewController *settingsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"settings"];
    
    UITabBarItem *songsTBI = [[UITabBarItem alloc] initWithTitle:@"Songs" image:[UIImage imageNamed:@"glyphicons_017_music"] tag:0];
    UITabBarItem *setsTBI = [[UITabBarItem alloc] initWithTitle:@"Sets" image:[UIImage imageNamed:@"glyphicons_158_playlist"] tag:1];
    UITabBarItem *settingsTBI = [[UITabBarItem alloc] initWithTitle:@"Settings" image:[UIImage imageNamed:@"glyphicons_023_cogwheels"] tag:2];
    
    songsViewController.tabBarItem = songsTBI;
    setsViewController.tabBarItem = setsTBI;
    settingsViewController.tabBarItem = settingsTBI;
    
    NSMutableArray *viewControllers = [NSMutableArray array];
    [viewControllers addObject:[[UINavigationController alloc] initWithRootViewController:songsViewController]];
    [viewControllers addObject:[[UINavigationController alloc] initWithRootViewController:setsViewController]];
    [viewControllers addObject:[[UINavigationController alloc] initWithRootViewController:settingsViewController]];

    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = viewControllers;

    // setup sidebar controller
    self.topViewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"TopView"];
    self.underLeftViewController = tabBarController;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.anchorRightRevealAmount = 305.0;
        self.underLeftWidthLayout = ECFixedRevealWidth;
    } else {
        self.anchorRightRevealAmount = 320.0;
        self.underLeftWidthLayout = ECFixedRevealWidth;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // draw shadow
    UIView *topView = self.topViewController.view;
    topView.layer.shadowOffset = CGSizeZero;
    topView.layer.shadowOpacity = 0.8f;
    topView.layer.shadowRadius = 4.0f;
    topView.layer.shadowColor = [UIColor blackColor].CGColor;
    topView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.layer.bounds].CGPath;
    topView.clipsToBounds = NO;
    
    [self.topViewController.view addGestureRecognizer:self.panGesture];
}
    
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
{
    return [self.topViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

@end
