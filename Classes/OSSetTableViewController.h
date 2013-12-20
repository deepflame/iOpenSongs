//
//  SetTableViewController.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 5/12/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

#import "OSSetTableViewControllerDelegate.h"

@interface OSSetTableViewController : CoreDataTableViewController
@property (nonatomic, weak) id<OSSetTableViewControllerDelegate> delegate;
@end
