//
//  NSString+SectionIndex.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/12/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "NSString+SectionIndex.h"

@implementation NSString (SectionIndex)

- (NSString *) firstLetter
{
    return [self substringWithRange:[self rangeOfComposedCharacterSequenceAtIndex:0]];
}

- (NSString *) sectionIndex
{
    NSString *firstLetter = [self firstLetter];
    
    if ([firstLetter integerValue]) {
        return @"#";
    }
    
    return [firstLetter utfNormalizedFormD];
}

- (NSString *) utfNormalizedFormD
{
    NSMutableString *decomposedString = [[self decomposedStringWithCanonicalMapping] mutableCopy];
    NSCharacterSet *nonBaseSet = [NSCharacterSet nonBaseCharacterSet];
    NSRange range = NSMakeRange([decomposedString length], 0);
    
    while (range.location > 0) {
        range = [decomposedString rangeOfCharacterFromSet:nonBaseSet
                                                  options:NSBackwardsSearch range:NSMakeRange(0, range.location)];
        if (range.length == 0) {
            break;
        }
        [decomposedString deleteCharactersInRange:range];
    }
    
    return decomposedString;
}

@end
