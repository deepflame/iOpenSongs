//
//  OSSongTableViewControllerDelegate.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 4/1/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OSSongTableViewController, Song;

@protocol OSSongTableViewControllerDelegate <NSObject>
- (void)songTableViewController:(OSSongTableViewController *)sender didSelectSong:(Song *)song;
@end
