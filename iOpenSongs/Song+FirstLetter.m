//
//  Song+FirstLetter.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 5/17/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "Song+FirstLetter.h"

@implementation Song (FirstLetter)

- (NSString *)titleFirstLetter {
    [self willAccessValueForKey:@"titleFirstLetter"];
    NSString *aString = [[self valueForKey:@"title"] uppercaseString];
    
    // support UTF-16:
    NSString *stringToReturn = [aString substringWithRange:[aString rangeOfComposedCharacterSequenceAtIndex:0]];
    
    // OR no UTF-16 support:
    //NSString *stringToReturn = [aString substringToIndex:1];
    
    [self didAccessValueForKey:@"titleFirstLetter"];
    return stringToReturn;
}

@end
