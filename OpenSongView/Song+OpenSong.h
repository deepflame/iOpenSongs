//
//  Song+OpenSong.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 2/25/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "Song.h"

@interface Song (OpenSong)

+ (NSDictionary *) openSongInfoWithOpenSongFileUrl:(NSURL *)fileUrl;

+ (Song *) songWithOpenSongInfo:(NSDictionary *)info
            inManagedObjectContext:(NSManagedObjectContext *)context;

@end
