//
//  OSSetTableViewControllerDelegate.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 4/8/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OSSetTableViewController;
@class Set;

@protocol OSSetTableViewControllerDelegate <NSObject>
- (void)setTableViewController:(OSSetTableViewController *)sender didSelectSet:(Set *)set;
@end
