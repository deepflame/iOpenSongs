//
//  SetItemSong+Cloning.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 12/17/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "SetItemSong+Cloning.h"
#import "NSManagedObject+Cloning.h"

@implementation SetItemSong (Cloning)

- (instancetype)cloneInContext:(NSManagedObjectContext *)context
{
    SetItemSong *clonedSetItem = [super cloneInContext:context];
    clonedSetItem.song = self.song;

    return clonedSetItem;
}

@end
