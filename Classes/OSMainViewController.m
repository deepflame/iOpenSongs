//
//  RevealSidebarViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/24/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "OSMainViewController.h"

// Songs
#import "OSSongViewController.h"
#import "OSSongSelectTableViewController.h"

// Sets
#import "SetItemSong.h"
#import "OSSetViewController.h"
#import "OSSetTableViewController.h"
#import "OSSetItemsTableViewController.h"

// Settings
#import "OSSettingsViewController.h"

// Shop
#import "OSShopViewController.h"
#import "OSStoreManager.h"

#import <FRLayeredNavigationController/FRLayerController.h>
#import "FRLayeredNavigationController+ExposePrivate.h"

@interface OSMainViewController ()
@property (nonatomic, strong) UIViewController *currentDetailViewController;
@property (nonatomic, strong) OSSongViewController *songViewController;
@property (nonatomic, strong) OSSetViewController *setViewController;
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
        // build viewControllers for the tabBar
        OSSongSelectTableViewController *songsViewController = [[OSSongSelectTableViewController alloc] init];
        songsViewController.delegate = self;
        OSSetTableViewController *setsViewController = [[OSSetTableViewController alloc] init];
        UIViewController *settingsViewController = [[OSSettingsViewController alloc] init];
        UIViewController *shopViewController = [[OSShopViewController alloc] init];
        
        // setting tabBarItems
        UITabBarItem *songsTBI = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Songs", nil) image:[UIImage imageNamed:@"glyphicons_017_music"] tag:0];
        UITabBarItem *setsTBI = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Sets", nil) image:[UIImage imageNamed:@"glyphicons_158_playlist"] tag:1];
        UITabBarItem *settingsTBI = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Settings", nil) image:[UIImage imageNamed:@"glyphicons_023_cogwheels"] tag:2];
        UITabBarItem *shopTBI = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Shop", nil) image:[UIImage imageNamed:@"glyphicons_202_shopping_cart"] tag:3];
        
        songsViewController.tabBarItem = songsTBI;
        setsViewController.tabBarItem = setsTBI;
        settingsViewController.tabBarItem = settingsTBI;
        shopViewController.tabBarItem = shopTBI;
        
        // adding navigationControllers
        UINavigationController *songsNavigationController = [[UINavigationController alloc] initWithRootViewController:songsViewController];
        UINavigationController *setsNavigationController = [[UINavigationController alloc] initWithRootViewController:setsViewController];
        UINavigationController *settingsNavigationController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
        UINavigationController *shopNavigationController = [[UINavigationController alloc] initWithRootViewController:shopViewController];

        // adding them to the tabBar
        NSMutableArray *tabBarViewControllers = [NSMutableArray array];
        [tabBarViewControllers addObject:songsNavigationController];
        [tabBarViewControllers addObject:setsNavigationController];
        [tabBarViewControllers addObject:settingsNavigationController];
        
        // enable shop?
        if ([OSStoreManager isEnabled]) {
            [tabBarViewControllers addObject:shopNavigationController];
        }
        
        tabBarController.viewControllers = tabBarViewControllers;
        
        // state restoration (iOS6)
        if ([self respondsToSelector:@selector(restorationIdentifier)]) {
            self.restorationIdentifier = NSStringFromClass([self class]);
            
            tabBarController.restorationIdentifier = @"tabBarController";
            
            songsNavigationController.restorationIdentifier = @"songsViewController navigationController";
            setsNavigationController.restorationIdentifier = @"setsViewController navigationController";
            settingsNavigationController.restorationIdentifier = @"settingsViewController navigationController";
            shopNavigationController.restorationIdentifier = @"shopViewController navigationController";
        }
        
        // top view controller
        self.rootViewController = tabBarController;
        self.currentDetailViewController = self.songViewController;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.songViewController.introPartialName = @"welcome";
    
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
{
    return [self.topViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

#pragma mark - OSSongTableViewControllerDelegate

- (void)songTableViewController:(id)sender didSelectSong:(Song *)song
{
    self.songViewController.song = song;
    self.currentDetailViewController = self.songViewController;
}

#pragma mark - OSSetItemsTableViewControllerDelegate

- (void)setItemsTableViewController:(OSSetItemsTableViewController *)sender didSelectSetItem:(SetItem *)setItem fromSet:(Set *)set
{
    // sanity check for SetViewController
    if (! setItem || set.items.count == 0) {
        return; // <- !!
    }
    
    self.setViewController.delegate = sender;
    self.setViewController.set = set; // TODO why do I set the set every time?
    
    // FIXME: setitem positions not consistent...
    NSArray *setItems = [SetItem MR_findAllSortedBy:@"position" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"set == %@", set]];
    NSUInteger index = [setItems indexOfObject:setItem];
    [self.setViewController selectPageAtIndex:index animated:NO];
    
    self.currentDetailViewController = self.setViewController;
}

- (void)setItemsTableViewController:(OSSetItemsTableViewController *)sender didChangeSet:(Set *)set
{
    self.setViewController.delegate = sender;
    self.setViewController.set = set;
    self.currentDetailViewController = self.setViewController;
}

- (void)setItemsTableViewController:(OSSetItemsTableViewController *)sender willAddSetItemsOfClass:(Class)itemClass toSet:(Set *)set
{
    if (itemClass == [SetItemSong class]) {
        self.currentDetailViewController = self.songViewController;
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

#pragma mark - Accessor Implementations

- (UIViewController *)currentDetailViewController
{
    if (self.layeredViewControllers.count < 2)
    {
        return nil; // <-- !!t
    }
    
    FRLayerController *detailLayerController = self.layeredViewControllers[1]; // the detailVC is always at 1
    UIViewController *detailVC = detailLayerController.contentViewController;
    
    return [(UINavigationController *)detailVC topViewController];
}

- (void)setCurrentDetailViewController:(UIViewController *)viewController
{
    if ([self.currentDetailViewController isEqual:viewController]) {
        return; // <-- !!
    }
    
    BOOL wasExpanded = [self detailViewControllerIsExpanded];
    
    UIViewController *uiVC = [[UINavigationController alloc] initWithRootViewController:viewController];
    // state restoration (iOS6)
    if ([uiVC respondsToSelector:@selector(restorationIdentifier)]) {
        uiVC.restorationIdentifier = @"currentDetailViewController navigationController";
    }
    
    [self popToRootViewControllerAnimated:NO];
    [self pushViewController:uiVC inFrontOf:self.topViewController maximumWidth:YES animated:NO configuration:^(FRLayeredNavigationItem *item) {
        item.hasChrome = NO;
        item.hasBorder = NO;
    }];
    
    // make sure the new controller is open if the previous was
    if (wasExpanded) {
        [self.layeredNavigationController expandViewControllersAnimated:NO];
    }
}

- (OSSongViewController *)songViewController
{
    if (! _songViewController) {
        _songViewController = [[OSSongViewController alloc] init];
    }
    return _songViewController;
}

- (OSSetViewController *)setViewController
{
    if (! _setViewController) {
        _setViewController = [[OSSetViewController alloc] init];
    }
    return _setViewController;
}

#pragma mark - Private Methods

- (BOOL)detailViewControllerIsExpanded
{
    CGPoint prevTopViewPosition = self.topViewController.layeredNavigationItem.currentViewPosition;
    return prevTopViewPosition.x > 0;
}

#pragma mark - UIViewControllerRestoration

#define kRootViewController @"rootViewController"
#define kDetailViewController @"detailViewController"
#define kViewControllerExpanded @"viewControllerExpanded"

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    // save the two VCs (also to propagate saving)
    [coder encodeObject:self.rootViewController forKey:kRootViewController];
    [coder encodeObject:self.currentDetailViewController forKey:kDetailViewController];
 
    // detail view is open?
    BOOL isExpanded = [self detailViewControllerIsExpanded];
    [coder encodeObject:[NSNumber numberWithBool:isExpanded] forKey:kViewControllerExpanded];
    
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    // restore VC
    UIViewController *vc = [coder decodeObjectForKey:kDetailViewController];
    if (vc) {
        self.currentDetailViewController = vc;
    }
    
    // detail view was open?
    NSNumber *isExpanded = [coder decodeObjectForKey:kViewControllerExpanded];
    if ([isExpanded boolValue]) {
        [self.layeredNavigationController expandViewControllersAnimated:NO];
    }
    
    [super decodeRestorableStateWithCoder:coder];
}

@end
