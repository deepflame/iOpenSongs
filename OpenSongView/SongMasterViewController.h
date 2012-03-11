//
//  MasterViewController.h
//  OpenSongMasterDetail
//
//  Created by Andreas Böhrnsen on 1/1/12.
//  Copyright (c) 2012 Open iT Norge AS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SongViewController.h"
#import "CoreDataTableViewController.h"

@class SongMasterViewController;

@protocol SongMasterViewControllerDelegate <NSObject>
@optional
- (void) songMasterViewControllerDelegate:(SongMasterViewController *)sender 
                                choseSong:(Song *)song;
@end


@interface SongMasterViewController : CoreDataTableViewController <UISplitViewControllerDelegate>

@property (nonatomic, strong) UIManagedDocument *songDatabase;  // Model is a Core Data database of songs
@property (nonatomic, weak) id <SongMasterViewControllerDelegate> delegate;

- (IBAction)refreshList:(id)sender;
@end
