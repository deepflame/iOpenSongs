//
//  Song.m
//  OpenSongView
//
//  Created by Andreas Böhrnsen on 12/31/11.
//  Copyright (c) 2011 Open iT Norge AS. All rights reserved.
//

#import "Song.h"

@implementation Song

@synthesize title;
@synthesize author;
@synthesize lyrics;

- (NSString *)lyricsAsHtml
{    
    NSArray *lyricsLines = [lyrics componentsSeparatedByString:@"\n"];
    NSMutableArray *htmlLyricsLines = [NSMutableArray arrayWithCapacity:[lyricsLines count]];
    
    for (NSString *lyricsLine in lyricsLines) {
        NSString *htmlLine = lyricsLine;
        
        if ([lyricsLine hasPrefix:@"["]) {
            NSString *sectionType;
            
            // parse the section header
            NSScanner *scanner = [NSScanner scannerWithString:lyricsLine];
            if ([scanner scanString:@"[" intoString:NULL] &&
                [scanner scanUpToString:@"]" intoString:&sectionType]) {
                
                // parse 
                NSInteger sectionNumber = 0;
                if ([sectionType length] == 2) {
                    sectionNumber = [[sectionType substringFromIndex:1] integerValue];
                    // cut off the number if it is non zero
                    if (sectionNumber != 0) {
                        sectionType = [sectionType substringToIndex:1];
                    }
                }
                
                // replace section header
                if ([sectionType isEqualToString:@"C"]) {
                    htmlLine = @"Chorus";
                } else if ([sectionType isEqualToString:@"V"]) {
                    htmlLine = @"Verse";
                } else if ([sectionType isEqualToString:@"B"]) {
                    htmlLine = @"Bridge";
                } else if ([sectionType isEqualToString:@"T"]) {
                    htmlLine = @"Tag";
                } else if ([sectionType isEqualToString:@"P"]) {
                    htmlLine = @"Pre Chorus";
                } else if ([sectionType isEqualToString:@"I"]) {
                    htmlLine = @"Intro";
                } else if ([sectionType isEqualToString:@"O"]) {
                    htmlLine = @"Outro";
                }
                
                // adding section number
                if (sectionNumber > 0) {
                    htmlLine = [htmlLine stringByAppendingFormat:@" %u", sectionNumber];
                }
            }
            
            htmlLine = [NSString stringWithFormat:@"<div class='heading'>%@</div>", htmlLine];
        } else if ([lyricsLine hasPrefix:@"."]) {
            htmlLine = [NSString stringWithFormat:@"<div class='chords'>%@</div>", htmlLine];
        } else if ([lyricsLine hasPrefix:@";"]) {
            htmlLine = [NSString stringWithFormat:@"<div class='comment'>%@</div>", htmlLine];
        } else {
            htmlLine = [NSString stringWithFormat:@"<div class='lyrics'>%@</div>", htmlLine];
        }
        
        [htmlLyricsLines addObject:htmlLine];
    }
    
    NSString *htmlLyrics = [htmlLyricsLines componentsJoinedByString:@"\n"];
    NSURL *templateUrl = [[NSBundle mainBundle] URLForResource:@"SongTemplate" withExtension:@"html"];
    NSString *htmlDoc = [NSString stringWithContentsOfURL:templateUrl 
                                                 encoding:NSUTF8StringEncoding
                                                    error:NULL];
    return [NSString stringWithFormat:htmlDoc, htmlLyrics];
}

@end
