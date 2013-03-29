//
//  ViewController.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 12/31/11.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Song.h"

// public interface
@interface SongViewController : UIViewController

@property (nonatomic, copy) Song *song;
@property (nonatomic) BOOL nightMode;

@property (nonatomic) BOOL headerVisible;
@property (nonatomic) BOOL chordsVisible;
@property (nonatomic) BOOL lyricsVisible;
@property (nonatomic) BOOL commentsVisible;

@property (nonatomic) int headerSize;
@property (nonatomic) int chordsSize;
@property (nonatomic) int lyricsSize;
@property (nonatomic) int commentsSize;

- (void)resetSongStyle;

@end
