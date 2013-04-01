//
//  OSSongViewDelegate.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 4/1/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OSSongView;
@class Song;

@protocol OSSongViewDelegate <NSObject>
- (void)songView:(OSSongView *)sender didChangeSong:(Song *)song;
@end
