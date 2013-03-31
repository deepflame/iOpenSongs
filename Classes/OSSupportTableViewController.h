//
//  ExtrasTableViewController.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 2/5/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OSSupportViewControllerDelegate <NSObject>
- (void)dismissSupportPopoverAnimated:(BOOL)animated;
@end

@interface OSSupportTableViewController : UITableViewController
@property (nonatomic, weak) NSObject<OSSupportViewControllerDelegate> *delegate;
@end
