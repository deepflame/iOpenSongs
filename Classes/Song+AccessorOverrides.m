//
//  Song+AccessorOverrides.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/9/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "Song+AccessorOverrides.h"
#import "Song+PrimitiveAccessors.h"

#import "NSString+SectionIndex.h"

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
    
    NSString *titleSectionIndex = [titleNormalized sectionIndex];
    
    [self willChangeValueForKey:@"titleSectionIndex"];
    [self setPrimitiveTitleSectionIndex:titleSectionIndex];
    [self didChangeValueForKey:@"titleSectionIndex"];    
}

@end
