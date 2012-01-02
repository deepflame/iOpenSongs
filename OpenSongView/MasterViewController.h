//
//  MasterViewController.h
//  OpenSongMasterDetail
//
//  Created by Andreas Böhrnsen on 1/1/12.
//  Copyright (c) 2012 Open iT Norge AS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SongViewController;

@interface MasterViewController : UITableViewController <UITableViewDelegate>

@property (strong, nonatomic) SongViewController *detailViewController;

@end
