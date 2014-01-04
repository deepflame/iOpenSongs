//
//  NSString+Additions.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 1/4/14.
//  Copyright (c) 2014 Andreas Boehrnsen. All rights reserved.
//

#import "NSString+Additions.h"

@implementation NSString (Additions)

// based on: http://stackoverflow.com/a/9382503/1188913
+ (BOOL)isBlank:(NSString *)string
{
    if (((NSNull *) string == [NSNull null]) || (string == nil) ) {
        return YES;
    }
    
    string = [string stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([string isEqualToString:@""]) {
        return YES;
    }
    
    return NO;
}

@end
