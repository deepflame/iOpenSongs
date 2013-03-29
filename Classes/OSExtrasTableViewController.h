//
//  ExtrasTableViewController.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 2/5/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSExtrasTableViewController;

@protocol OSExtrasTableViewControllerDelegate <NSObject>

@optional
- (void)extrasTableViewControllerDelegate:(OSExtrasTableViewController *)sender
                         changedNightMode:(BOOL)state;
- (void)extrasTableViewControllerDelegate:(OSExtrasTableViewController *)sender
                 dismissMyPopoverAnimated:(BOOL)animated;
@end


@interface OSExtrasTableViewController : UITableViewController
@property (nonatomic, weak) id <OSExtrasTableViewControllerDelegate> delegate;
@end
