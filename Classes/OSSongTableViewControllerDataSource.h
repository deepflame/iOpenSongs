//
//  OSSongTableViewControllerDataSource.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 4/1/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Song;
@class OSSongTableViewController;

@protocol OSSongTableViewControllerDataSource <NSObject>
- (NSString *)songTableViewController:(OSSongTableViewController *)sender badgeStringForSong:(Song *)song;
@end
