//
//  MasterViewController.h
//  OpenSongMasterDetail
//
//  Created by Andreas Böhrnsen on 1/1/12.
//  Copyright (c) 2012 Open iT Norge AS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SongViewController.h"

@class SongViewController;

@interface SongMasterViewController : UITableViewController 

@property (strong, nonatomic) SongViewController *detailViewController;

- (IBAction)refreshList:(id)sender;

@end
