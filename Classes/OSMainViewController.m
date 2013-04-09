//
//  RevealSidebarViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/24/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "OSMainViewController.h"

#import "OSSongViewController.h"
#import "OSSongMasterViewController.h"

#import "OSAppDelegate.h"
#import "SetItemSong.h"
#import "OSSetViewController.h"
#import "OSSetTableViewController.h"
#import "OSSetItemsTableViewController.h"

@interface OSMainViewController ()
@property (nonatomic, strong) UIViewController *currentDetailViewController;
@end

@implementation OSMainViewController

- (id)init
{
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    CGFloat sideBarWidth;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        sideBarWidth = 305.0;
    } else {
        sideBarWidth = 320.0;
    }

    self = [super initWithRootViewController:tabBarController configuration:^(FRLayeredNavigationItem *item) {
        item.width = sideBarWidth;
        item.nextItemDistance = 0;
    }];
    if (self) {
        // build tabbar
        OSSongMasterViewController *songsViewController = [[OSSongMasterViewController alloc] init];
        songsViewController.delegate = self;
        OSSetTableViewController *setsViewController = [[OSSetTableViewController alloc] init];
        setsViewController.delegate = self;
        UIViewController *settingsViewController = [[[OSAppDelegate sharedAppDelegate] storyboard] instantiateViewControllerWithIdentifier:@"settings"];
        
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
        
        tabBarController.viewControllers = viewControllers;
        
        // top view controller
        self.currentDetailViewController = [[OSSongViewController alloc] init];
    }
    return self;
}

#pragma mark - UIViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
{
    return [self.topViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

#pragma mark - OSSongTableViewControllerDelegate

- (void)songTableViewController:(id)sender didSelectSong:(Song *)song
{
    OSSongViewController *songVC = (OSSongViewController *)[self currentDetailViewController];
    songVC.songView.song = song;
}

#pragma mark - OSSetTableViewControllerDelegate

- (void)setTableViewController:(OSSetTableViewController *)sender didSelectSet:(Set *)set
{
}

#pragma mark - OSSetItemsTableViewControllerDelegate

- (void)setItemsTableViewController:(id)sender didSelectSetItem:(SetItem *)setItem fromSet:(Set *)set
{    
    OSSongViewController *songVC = (OSSongViewController *)[self currentDetailViewController];
    songVC.songView.song = [(SetItemSong *)setItem song];
}

#pragma mark - Private Methods

- (UIViewController *)currentDetailViewController
{
    return [(UINavigationController *)self.topViewController topViewController];
}

- (void)setCurrentDetailViewController:(UIViewController *)viewController
{
    UIViewController *uiVC = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self popToRootViewControllerAnimated:NO];
    [self pushViewController:uiVC inFrontOf:self.topViewController maximumWidth:YES animated:NO configuration:^(FRLayeredNavigationItem *item) {
        item.hasChrome = NO;
        item.hasBorder = NO;
    }];
}

@end
