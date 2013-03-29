//
//  Song+OpenSong.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 2/25/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "Song.h"
#import "RKXMLParserLibXML.h"

@interface Song (OpenSong)

+ (NSDictionary *) openSongInfoWithOpenSongFileUrl:(NSURL *)fileUrl;

+ (Song *) updateOrCreateSongWithOpenSongFileFromURL:(NSURL *)fileURL
                              inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Song *) songWithOpenSongInfo:(NSDictionary *)info
            inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Song *) updateOrCreateSongWithOpenSongInfo:(NSDictionary *)info
                       inManagedObjectContext:(NSManagedObjectContext *)context;

- (void) updateWithOpenSongInfo:(NSDictionary *)info;

@end
