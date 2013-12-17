//
//  SetItemSong+Cloning.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 12/17/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "SetItemSong.h"

@interface SetItemSong (Cloning)

- (instancetype)cloneInContext:(NSManagedObjectContext *)context;

@end
