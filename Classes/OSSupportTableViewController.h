//
//  ExtrasTableViewController.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 2/5/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OSSupportViewControllerDelegate.h"

@interface OSSupportTableViewController : UITableViewController
@property (nonatomic, weak) id<OSSupportViewControllerDelegate> delegate;
@end
