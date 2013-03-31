//
//  OSSongView.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/31/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Song.h"

@protocol OSSongViewDelegate <NSObject>
- (void)songViewDidChangeSong:(Song *)song;
@end

@interface OSSongView : UIView

- (void)resetSongStyle;

@property (nonatomic, weak) NSObject<OSSongViewDelegate> *delegate;

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

@end
