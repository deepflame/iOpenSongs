//
//  Song+AccessorOverrides.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/9/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "Song+AccessorOverrides.h"
#import "Song+PrimitiveAccessors.h"

@implementation Song (AccessorOverrides)

- (void)setTitle:(NSString *)title
{    
    [self willChangeValueForKey:@"title"];
    [self setPrimitiveTitle:title];
    [self didChangeValueForKey:@"title"];
    
    NSString *titleNormalized = [title uppercaseString];
    
    [self willChangeValueForKey:@"titleNormalized"];
    [self setPrimitiveTitleNormalized:titleNormalized];
    [self didChangeValueForKey:@"titleNormalized"];
    
    // support UTF-16:
    //NSString *stringToReturn = [aString substringWithRange:[aString rangeOfComposedCharacterSequenceAtIndex:0]];
    
    // OR no UTF-16 support:
    //NSString *stringToReturn = [aString substringToIndex:1];

    NSString *titleSectionIndex = [titleNormalized substringWithRange:[titleNormalized rangeOfComposedCharacterSequenceAtIndex:0]];
    
    [self willChangeValueForKey:@"titleSectionIndex"];
    [self setPrimitiveTitleSectionIndex:titleSectionIndex];
    [self didChangeValueForKey:@"titleSectionIndex"];    
}

@end
