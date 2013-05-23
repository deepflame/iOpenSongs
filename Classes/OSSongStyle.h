//
//  OSSongStyle.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 5/23/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSSongStyle : NSObject

+ (OSSongStyle *)defaultStyle;

- (void)resetStyle;

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
