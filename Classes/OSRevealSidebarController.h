//
//  RevealSidebarViewController.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/24/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FRLayeredNavigation.h>

#import "OSSongMasterViewController.h"
#import "OSSetItemsTableViewController.h"

@interface OSRevealSidebarController : FRLayeredNavigationController <OSSongTableViewControllerDelegate, OSSetTableViewControllerDelegate, OSSetItemsTableViewControllerDelegate>

@end
