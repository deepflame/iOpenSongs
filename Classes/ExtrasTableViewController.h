//
//  ExtrasTableViewController.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 2/5/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ExtrasTableViewController;

@protocol ExtrasTableViewControllerDelegate <NSObject>

@optional
- (void)extrasTableViewControllerDelegate:(ExtrasTableViewController *)sender
                         changedNightMode:(BOOL)state;
- (void)extrasTableViewControllerDelegate:(ExtrasTableViewController *)sender
                 dismissMyPopoverAnimated:(BOOL)animated;
@end


@interface ExtrasTableViewController : UITableViewController
@property (nonatomic, weak) id <ExtrasTableViewControllerDelegate> delegate;
@end
