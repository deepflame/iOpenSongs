//
//  RevealSidebarViewController.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/24/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FRLayeredNavigation.h>

#import "OSSongSelectTableViewController.h"
#import "OSSetTableViewController.h"
#import "OSSetItemsTableViewController.h"

@interface OSMainViewController : FRLayeredNavigationController <OSSongTableViewControllerDelegate, OSSetTableViewControllerDelegate, OSSetItemsTableViewControllerDelegate>

@end
