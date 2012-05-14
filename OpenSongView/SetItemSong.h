//
//  SetItemSong.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 5/14/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SetItem.h"

@class Song;

@interface SetItemSong : SetItem

@property (nonatomic, retain) Song *song;

@end
