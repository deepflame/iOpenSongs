//
//  Song+OpenSong.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 2/25/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "Song+OpenSong.h"
#import "RKXMLParserLibXML.h"

@implementation Song (OpenSong)

+ (NSDictionary *) openSongInfoWithOpenSongFileUrl:(NSURL *)fileUrl
{
    NSString *xmlString = [NSString stringWithContentsOfURL:fileUrl encoding:NSUTF8StringEncoding error:nil];

    RKXMLParserLibXML *parser = [[RKXMLParserLibXML alloc] init];
    id result = [parser objectFromString:xmlString error:nil];
    
    NSDictionary *info = nil;
    
    if (!result) {
        // ERROR
    } else {
        info = [((NSDictionary *)result) objectForKey:@"song"];
        
        // set file name as title if title empty
        if (![[info objectForKey:@"title"] isKindOfClass:NSString.class]) {
            NSString *fileName = [fileUrl lastPathComponent];
            [info setValue:fileName forKey:@"title"];
        }
        
    }
    return info;
}

+ (Song *) songWithOpenSongInfo:(NSDictionary *)info
         inManagedObjectContext:(NSManagedObjectContext *)context
{
    Song *song = [NSEntityDescription insertNewObjectForEntityForName:@"Song" inManagedObjectContext:context];
    [song updateWithOpenSongInfo:info];

    return song;
}

- (void) updateWithOpenSongInfo:(NSDictionary *)info
{
    for (NSString* key in info) {
        id value = [info objectForKey:key];
        
        // get setter selector for attribute
        NSString* attrSetter = [key stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[key substringToIndex:1] uppercaseString]];
        attrSetter = [NSString stringWithFormat:@"set%@:", attrSetter];
        SEL attr = NSSelectorFromString(attrSetter);
        
        // prepare the value
        NSString *stringVal = @"";
        if ([value isKindOfClass:NSString.class]) {
            stringVal = (NSString *)value;
        }
        
        if ([self respondsToSelector:attr]) {
            [self performSelector:attr withObject:stringVal];
        } else {
            NSLog(@"Song attr not found: %@", key);
        }
    }
    
    //song.capo = (NSString *)[info objectForKey:@"capo"];
    //@property (nonatomic, retain) NSNumber * capo_print;
    //@property (nonatomic, retain) NSData * style_background;
}


@end
