//
//  ViewController.h
//  OpenSongView
//
//  Created by Andreas Böhrnsen on 12/31/11.
//  Copyright (c) 2011 Open iT Norge AS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EasyTracker.h"

#import "Song.h"
#import "SplitViewBarButtonItemPresenter.h"

// public interface
@interface SongViewController : TrackedUIViewController <NSXMLParserDelegate, SplitViewBarButtonItemPresenter>

@property (strong, nonatomic) Song *song;

- (void)parseSongData:(NSData *)songData;
- (void)parseSongFromUrl:(NSURL *)songFileUrl;

@end
