//
//  OSSongTableViewControllerDelegate.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 4/1/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Song.h"

@class OSSongTableViewController;

@protocol OSSongTableViewControllerDelegate <NSObject>
- (void)songTableViewController:(OSSongTableViewController *)sender didSelectSong:(Song *)song;
@optional
- (void)songTableViewController:(OSSongTableViewController *)sender didDeleteSong:(Song *)song;
- (void)songTableViewController:(OSSongTableViewController *)sender accessoryButtonTappedForSong:(Song *)song;
@end
