//
//  MasterViewController.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 1/1/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SongViewController.h"
#import "EasyTracker.h"

@class SongMasterViewController;

@protocol SongMasterViewControllerDelegate <NSObject>
@optional
- (void) songMasterViewControllerDelegate:(SongMasterViewController *)sender 
                                choseSong:(NSURL *)song;
@end


@interface SongMasterViewController : TrackedUITableViewController <UISplitViewControllerDelegate, NSXMLParserDelegate>
@property (nonatomic, weak) id <SongMasterViewControllerDelegate> delegate;
- (IBAction)refreshList:(id)sender;
@end
