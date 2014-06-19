//
//  OSSongStyle.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 5/23/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "OSSongStyle.h"

#import "NSObject+RuntimeAdditions.h"

#define USER_DEFAULTS_KEY_NIGHT_MODE @"SongViewController.nightMode"
#define USER_DEFAULTS_KEY_SONG_STYLE @"SongViewController.songStyle"

@implementation OSSongStyle

+ (OSSongStyle *)defaultStyle
{
    static OSSongStyle *sharedInstance = nil;
    static dispatch_once_t onceTokenSongStyle;
    dispatch_once(&onceTokenSongStyle, ^{
        sharedInstance = [[OSSongStyle alloc] init];
        
        [sharedInstance loadFromUserDefaults];
    });
    return sharedInstance;
}

- (void)resetStyle
{
    self.nightMode = NO;
    self.twoColumns = YES;
    
    self.headerVisible = YES;
    self.chordsVisible = YES;
    self.lyricsVisible = YES;
    self.commentsVisible = YES;
    
    self.headerSize = 24;
    self.chordsSize = 16;
    self.lyricsSize = 16;
    self.commentsSize = 10;
}

- (void)loadFromUserDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *styleDict = [defaults objectForKey:USER_DEFAULTS_KEY_SONG_STYLE];
    
    if (styleDict) {
        [self setValuesForKeysWithDictionary:styleDict];
        self.nightMode = [defaults boolForKey:USER_DEFAULTS_KEY_NIGHT_MODE];
    } else {
        [self resetStyle];
    }
}

- (void)saveAsUserDefaults
{
    NSMutableDictionary *styleDict = [[self dictionaryWithValuesForKeys:[self propertyNames]] mutableCopy];
    [styleDict removeObjectForKey:@"nightMode"]; // night mode was not part of the song style before
    
    // save user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:styleDict forKey:USER_DEFAULTS_KEY_SONG_STYLE];
    [defaults setBool:self.nightMode forKey:USER_DEFAULTS_KEY_NIGHT_MODE];
    [defaults synchronize];
}

- (id)copyWithZone:(NSZone *)zone
{
    OSSongStyle *another = [[OSSongStyle allocWithZone:zone] init];
    
    // copy property values over
    NSDictionary *propertyValues = [self dictionaryWithValuesForKeys:[self propertyNames]];
    [another setValuesForKeysWithDictionary:propertyValues];
    
    return another;
}

@end
