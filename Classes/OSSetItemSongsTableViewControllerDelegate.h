//
//  OSSetItemSongsTableViewControllerDelegate.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 4/1/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OSSetItemSongsTableViewController;

@protocol OSSetItemSongsTableViewControllerDelegate <NSObject>
@optional
- (void)setItemSongsTableViewController:(OSSetItemSongsTableViewController *)sender didInsertSong:(Song *)song;
- (void)setItemSongsTableViewController:(OSSetItemSongsTableViewController *)sender didDeleteSong:(Song *)song;
- (void)setItemSongsTableViewController:(OSSetItemSongsTableViewController *)sender finishedEditing:(BOOL)animated;
@end
