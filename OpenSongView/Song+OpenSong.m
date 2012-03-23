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
    NSString *xmlString = [NSString stringWithContentsOfURL:fileUrl encoding:NSASCIIStringEncoding error:nil];

    RKXMLParserLibXML *parser = [[RKXMLParserLibXML alloc] init];
    id result = [parser objectFromString:xmlString error:nil];
    
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


    for (NSString* key in info) {
        id value = [info objectForKey:key];
        
        // get setter for attribute
        NSString* attrSetter = [key stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[key substringToIndex:1] uppercaseString]];
        attrSetter = [NSString stringWithFormat:@"set%@:", attrSetter];
        SEL attr = NSSelectorFromString(attrSetter);
        
        // prepare the value
        NSString *stringVal = @"";
        if ([value isKindOfClass:NSString.class]) {
            stringVal = (NSString *)value;
        }
        
        if ([song respondsToSelector:attr]) {
            [song performSelector:attr withObject:stringVal];
        } else {
            NSLog(@"Song attr not found: %@", key);
        }
    }

//song.capo = (NSString *)[info objectForKey:@"capo"];
//@property (nonatomic, retain) NSNumber * capo_print;
//@property (nonatomic, retain) NSData * style_background;
    return song;
}

@end
