//
//  RevealSidebarViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/24/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "OSMainViewController.h"

#import "OSSongViewController.h"
#import "OSSongSelectTableViewController.h"

#import "OSAppDelegate.h"
#import "SetItemSong.h"
#import "OSSetViewController.h"
#import "OSSetTableViewController.h"
#import "OSSetItemsTableViewController.h"

#import <FRLayeredNavigationController/FRLayerController.h>
#import "FRLayeredNavigationController+ExposePrivate.h"

@interface OSMainViewController ()
@property (nonatomic, strong) UIViewController *currentDetailViewController;
@property (nonatomic, strong) UIViewController *rootViewController;
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
        OSSongSelectTableViewController *songsViewController = [[OSSongSelectTableViewController alloc] init];
        songsViewController.delegate = self;
        OSSetTableViewController *setsViewController = [[OSSetTableViewController alloc] init];
        UIViewController *settingsViewController = [[[OSAppDelegate sharedAppDelegate] storyboard] instantiateViewControllerWithIdentifier:@"settings"];
       
        UITabBarItem *songsTBI = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Songs", nil) image:[UIImage imageNamed:@"glyphicons_017_music"] tag:0];
        UITabBarItem *setsTBI = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Sets", nil) image:[UIImage imageNamed:@"glyphicons_158_playlist"] tag:1];
        UITabBarItem *settingsTBI = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Settings", nil) image:[UIImage imageNamed:@"glyphicons_023_cogwheels"] tag:2];
        
        songsViewController.tabBarItem = songsTBI;
        setsViewController.tabBarItem = setsTBI;
        settingsViewController.tabBarItem = settingsTBI;
        
        NSMutableArray *viewControllers = [NSMutableArray array];
        [viewControllers addObject:[[UINavigationController alloc] initWithRootViewController:songsViewController]];
        [viewControllers addObject:[[UINavigationController alloc] initWithRootViewController:setsViewController]];
        [viewControllers addObject:[[UINavigationController alloc] initWithRootViewController:settingsViewController]];
        
        tabBarController.viewControllers = viewControllers;
        
        // song view controller
        OSSongViewController *songVC = [[OSSongViewController alloc] init];
        songVC.songView.introPartialName = @"welcome";
        
        // top view controller
        self.currentDetailViewController = songVC;
        self.rootViewController = tabBarController;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
{
    return [self.topViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

#pragma mark - OSSongTableViewControllerDelegate

- (void)songTableViewController:(id)sender didSelectSong:(Song *)song
{
    if (! [self.currentDetailViewController isMemberOfClass:[OSSongViewController class]]) {
        self.currentDetailViewController = [[OSSongViewController alloc] init];
    }
    OSSongViewController *songVC = (OSSongViewController *)[self currentDetailViewController];
    songVC.songView.song = song;
}

#pragma mark - OSSetItemsTableViewControllerDelegate

- (void)setItemsTableViewController:(OSSetItemsTableViewController *)sender didSelectSetItem:(SetItem *)setItem fromSet:(Set *)set
{
    // sanity check for SetViewController
    if (! setItem || set.items.count == 0) {
        return; // <- !!
    }
    
    if (! [self.currentDetailViewController isMemberOfClass:[OSSetViewController class]]) {
        self.currentDetailViewController = [[OSSetViewController alloc] init];
    }
    OSSetViewController *setVC = (OSSetViewController *)[self currentDetailViewController];
    setVC.delegate = sender;
    setVC.set = set;
    
    // FIXME: setitem positions not consistent...
    NSArray *setItems = [SetItem MR_findAllSortedBy:@"position" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"set == %@", set]];
    NSUInteger index = [setItems indexOfObject:setItem];
        
    [setVC selectPageAtIndex:index animated:NO];
}

- (void)setItemsTableViewController:(OSSetItemsTableViewController *)sender didDeleteSetItem:(SetItem *)setItem fromSet:(Set *)set
{
   self.currentDetailViewController = [[OSSetViewController alloc] init];
   OSSetViewController *setVC = (OSSetViewController *)[self currentDetailViewController];
   setVC.delegate = sender;
   setVC.set = set;
}

- (void)setItemsTableViewController:(OSSetItemsTableViewController *)sender willAddSetItemsOfClass:(Class)itemClass toSet:(Set *)set
{
    if (itemClass == [SetItemSong class]) {
        if (! [self.currentDetailViewController isMemberOfClass:[OSSongViewController class]]) {
            OSSongViewController *songVC = [[OSSongViewController alloc] init];
            songVC.songView.introPartialName = @"set-add-songs";
            self.currentDetailViewController = songVC;
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate

// Refining super implementation
- (void)handleGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state) {
        
        case UIGestureRecognizerStateChanged: {
            
            CGFloat viewLocationX = self.currentDetailViewController.layeredNavigationItem.currentViewPosition.x;
            CGFloat translationX = [gestureRecognizer translationInView:self.currentDetailViewController.view].x;
            
            // do not move the detailview out to the left of the screen
            if (viewLocationX <= 0 && translationX < 0) {
                return;
            }
            
            break;
        }
    
        default: {
            
        }
    
    }

    [super handleGesture:gestureRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGFloat touchX = [touch locationInView:self.currentDetailViewController.view].x;
    
    // only when inside DetailView
    return  touchX > 0;
}

#pragma mark - Private Methods

- (UIViewController *)currentDetailViewController
{
    FRLayerController *detailLayerController = self.layeredViewControllers[1]; // the detailVC is always at 1
    UIViewController *detailVC = detailLayerController.contentViewController;
    
    return [(UINavigationController *)detailVC topViewController];
}

- (void)setCurrentDetailViewController:(UIViewController *)viewController
{
    // order matters (needs to be on top)
    CGPoint prevTopViewPosition = self.topViewController.layeredNavigationItem.currentViewPosition;
    
    UIViewController *uiVC = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self popToRootViewControllerAnimated:NO];
    [self pushViewController:uiVC inFrontOf:self.topViewController maximumWidth:YES animated:NO configuration:^(FRLayeredNavigationItem *item) {
        item.hasChrome = NO;
        item.hasBorder = NO;
    }];
    
    // make sure the new controller is open if the previous was
    if (prevTopViewPosition.x > 0) {
        [self.layeredNavigationController expandViewControllersAnimated:NO];
    }
}

@end
