//
//  RevealSidebarViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/24/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "OSRevealSidebarController.h"

#import "OSSongViewController.h"
#import "OSSongMasterViewController.h"

#import "SetItemSong.h"
#import "OSSetTableViewController.h"

@interface OSRevealSidebarController ()
@property (nonatomic, strong) OSSongViewController *songViewController;
@end

@implementation OSRevealSidebarController

#pragma mark - UIViewController

-(void)viewDidLoad
{
    [super viewDidLoad];

    // build tabbar
    OSSongMasterViewController *songsViewController = [[OSSongMasterViewController alloc] init];
    songsViewController.delegate = self;
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
    
    // top view controller
    self.songViewController = [[OSSongViewController alloc] init];
    UIViewController *songViewController = self.songViewController;
    
    // setup sidebar controller
    self.topViewController = [[UINavigationController alloc] initWithRootViewController:songViewController];
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

#pragma mark - OSSongTableViewControllerDelegate

- (void)songTableViewController:(id)sender didSelectSong:(Song *)song
{
    self.songViewController.songView.song = song;    
}

#pragma mark - OSSetItemsTableViewControllerDelegate

- (void)setItemsTableViewController:(id)sender didSelectSetItem:(SetItem *)setItem
{
    if ([setItem isMemberOfClass:[SetItemSong class]]) {
        SetItemSong *setItemSong = (SetItemSong *)setItem;
        self.songViewController.songView.song = setItemSong.song;
    } else {
        // TODO support for other types
    }
}

@end
