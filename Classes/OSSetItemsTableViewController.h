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

@interface OSSetItemsTableViewController : CoreDataTableViewController

@property (nonatomic, copy) Set *set;

@end
