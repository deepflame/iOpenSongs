//
//  ExtrasTableViewController.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 2/5/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSSupportTableViewController;

@protocol OSSupportTableViewControllerDelegate <NSObject>

@optional
- (void)supportTableViewControllerDelegate:(OSSupportTableViewController *)sender
                 dismissMyPopoverAnimated:(BOOL)animated;
@end


@interface OSSupportTableViewController : UITableViewController
@property (nonatomic, weak) id <OSSupportTableViewControllerDelegate> delegate;
@end
