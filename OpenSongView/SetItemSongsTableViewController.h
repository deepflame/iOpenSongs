//
//  SetItemSongsTableViewController.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 6/10/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SongTableViewController.h"

#import "Song.h"

@class SetItemSongsTableViewController;

@protocol SetItemSongsTableViewControllerDelegate <NSObject>
@optional
- (void) setItemSongsTableViewController:(SetItemSongsTableViewController *)sender 
                               choseSong:(Song *)song;
- (void) setItemSongsTableViewController:(SetItemSongsTableViewController *)sender 
                         finishedEditing:(BOOL)animated;
@end

@interface SetItemSongsTableViewController : SongTableViewController
@property (nonatomic, weak) id<SetItemSongsTableViewControllerDelegate> delegate;
@end
