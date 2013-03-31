//
//  SongTableViewController.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 6/10/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

#import "Song.h"


@protocol OSSongTableViewControllerDelegate <NSObject>
- (void)songTableViewController:(id)sender didSelectSong:(Song *)song;
@end

@interface OSSongTableViewController : CoreDataTableViewController
@property (nonatomic, weak) id<OSSongTableViewControllerDelegate> delegate;
@end
