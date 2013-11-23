//
//  OSSetItemsTableViewControllerDelegate.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 4/1/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OSSetItemsTableViewController;
@class SetItem;
@class Set;

@protocol OSSetItemsTableViewControllerDelegate <NSObject>
@optional
- (void)setItemsTableViewController:(OSSetItemsTableViewController *)sender didSelectSetItem:(SetItem *)setItem fromSet:(Set *)set;
- (void)setItemsTableViewController:(OSSetItemsTableViewController *)sender didChangeSet:(Set *)set;
- (void)setItemsTableViewController:(OSSetItemsTableViewController *)sender willAddSetItemsOfClass:(Class)itemClass toSet:(Set *)set;
@end
