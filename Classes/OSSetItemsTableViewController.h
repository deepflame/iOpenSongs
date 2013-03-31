//
//  SetSongsTableViewController.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 5/12/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

#import "Set.h"
#import "SetItem.h"


@protocol OSSetItemsTableViewControllerDelegate <NSObject>
- (void)setItemsTableViewController:(id)sender didSelectSetItem:(SetItem *)setItem;
@end

@interface OSSetItemsTableViewController : CoreDataTableViewController
@property (nonatomic, copy) Set *set;
@property (nonatomic, weak) id<OSSetItemsTableViewControllerDelegate> delegate;
@end
