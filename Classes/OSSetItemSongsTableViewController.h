//
//  SetItemSongsTableViewController.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 6/10/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSongTableViewController.h"

#import "Song.h"

@class OSSetItemSongsTableViewController;

@protocol SetItemSongsTableViewControllerDelegate <NSObject>
@optional
- (void) setItemSongsTableViewController:(OSSetItemSongsTableViewController *)sender 
                               choseSong:(Song *)song;
- (void) setItemSongsTableViewController:(OSSetItemSongsTableViewController *)sender 
                         finishedEditing:(BOOL)animated;
@end

@interface OSSetItemSongsTableViewController : OSSongTableViewController
@property (nonatomic, weak) id<SetItemSongsTableViewControllerDelegate> delegate;
@end
