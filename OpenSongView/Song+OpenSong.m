//
//  Song+OpenSong.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 2/25/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "Song+OpenSong.h"
//#import "RKXMLParserLibXML.h"

@implementation Song (OpenSong)

+ (NSDictionary *) openSongInfoWithOpenSongFileUrl:(NSURL *)fileUrl
{
    //RKXMLParserLibXML *parser = [[RKXMLParserLibXML alloc] init];
    NSString *xmlString = [NSString stringWithContentsOfURL:fileUrl encoding:NSASCIIStringEncoding error:nil];
    id result = nil;//[parser objectFromString:xmlString error:nil];
    
    NSDictionary *info = nil;
    
    if (!result) {
        // ERROR
    } else {
        info = [((NSDictionary *)result) objectForKey:@"song"];
    }
    return info;
}

+ (Song *) songWithOpenSongInfo:(NSDictionary *)info
         inManagedObjectContext:(NSManagedObjectContext *)context
{
    Song *song = [NSEntityDescription insertNewObjectForEntityForName:@"Song" inManagedObjectContext:context];
    song.title = (NSString *)[info objectForKey:@"title"];
    return song;
}

@end
