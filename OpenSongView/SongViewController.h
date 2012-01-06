//
//  ViewController.h
//  OpenSongView
//
//  Created by Andreas Böhrnsen on 12/31/11.
//  Copyright (c) 2011 Open iT Norge AS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"

@interface SongViewController : UIViewController <NSXMLParserDelegate> {
    Song *song;
    IBOutlet UILabel *songTitle;
    IBOutlet UILabel *songAuthor;
    IBOutlet UITextView *songLyrics;
    
@private
    NSOperationQueue *operationQueue;
    
}

@property (strong, nonatomic) Song *song;

- (void)parseSongData:(NSData *)songData;
- (void)parseSongFromUrl:(NSURL *)songFileUrl;

@end
