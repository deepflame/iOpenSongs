//
//  Song+OpenSong.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 2/25/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "Song+OpenSong.h"

@implementation Song (OpenSong)

#pragma mark - Public Methods

+ (Song *) updateOrCreateSongWithOpenSongFileFromURL:(NSURL *)fileURL
                              inManagedObjectContext:(NSManagedObjectContext *)context
                                               error:(NSError **)error
{
    NSError *internalError = nil;
    NSDictionary *info = [self openSongInfoWithOpenSongFileUrl:fileURL error:&internalError];
    
    if (info == nil && *error != nil) {
        *error = [NSError errorWithDomain:nil code:NSFileReadCorruptFileError userInfo:nil];
    }
    
    return [self updateOrCreateSongWithOpenSongInfo:info inManagedObjectContext:context];
}

#pragma mark - Private Methods

+ (Song *) updateOrCreateSongWithOpenSongInfo:(NSDictionary *)info
                       inManagedObjectContext:(NSManagedObjectContext *)context
{    
    // check if song already exists based on title
    Song *song = [Song MR_findFirstByAttribute:@"title"
                                     withValue:[info valueForKey:@"title"]
                                     inContext:context];
    if (song) {
        [song updateWithOpenSongInfo:info];
    } else {
        song = [Song songWithOpenSongInfo:info inManagedObjectContext:context];
    }
    return song;
}

+ (NSDictionary *) openSongInfoWithOpenSongFileUrl:(NSURL *)fileUrl error:(NSError **)error
{
    NSString *textContent = [NSString stringWithContentsOfURL:fileUrl encoding:NSUTF8StringEncoding error:error];
    if (!textContent) {
        // ERROR, not a text file
        return nil;
    }
    
    RKXMLParserLibXML *parser = [[RKXMLParserLibXML alloc] init];
    id result = [parser objectFromString:textContent error:error];
    if (!result) {
        // ERROR, not an xml file
        return nil;
    }
    
    NSDictionary *info = [((NSDictionary *)result) objectForKey:@"song"];
        
    // set file name as title if title empty
    if (![[info objectForKey:@"title"] isKindOfClass:NSString.class]) {
        NSString *fileName = [fileUrl lastPathComponent];
        [info setValue:fileName forKey:@"title"];
    }

    return info;
}

+ (Song *) songWithOpenSongInfo:(NSDictionary *)info
         inManagedObjectContext:(NSManagedObjectContext *)context
{
    if (!info) {
        return nil;
    }
    
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
            SuppressPerformSelectorLeakWarning([self performSelector:attr withObject:stringVal]);
        }
    }
}


@end
