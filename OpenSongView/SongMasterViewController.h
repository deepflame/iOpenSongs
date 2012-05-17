//
//  MasterViewController.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 1/1/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SongViewController.h"
#import "CoreDataTableViewController.h"


@interface SongMasterViewController : CoreDataTableViewController

- (IBAction)refreshList:(id)sender;

@end
