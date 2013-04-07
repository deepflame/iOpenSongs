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

+ (Song *) updateOrCreateSongWithOpenSongFileFromURL:(NSURL *)fileURL
                              inManagedObjectContext:(NSManagedObjectContext *)context
                                               error:(NSError **)error;

@end
