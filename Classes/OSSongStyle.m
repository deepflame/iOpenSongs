//
//  OSSongStyle.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 5/23/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "OSSongStyle.h"

@implementation OSSongStyle

+ (OSSongStyle *)defaultStyle
{
    static OSSongStyle *sharedInstance = nil;
    static dispatch_once_t onceTokenSongStyle;
    dispatch_once(&onceTokenSongStyle, ^{
        sharedInstance = [[OSSongStyle alloc] init];
        
        [sharedInstance resetStyle];
    });
    return sharedInstance;
}

- (void)resetStyle
{
    self.nightMode = NO;
    
    self.headerVisible = YES;
    self.chordsVisible = YES;
    self.lyricsVisible = YES;
    self.commentsVisible = YES;
    
    self.headerSize = 24;
    self.chordsSize = 16;
    self.lyricsSize = 16;
    self.commentsSize = 10;
}

@end
