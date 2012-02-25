//
//  NSString+JavaScript.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 2/25/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "NSString+JavaScript.h"

@implementation NSString (JavaScript)

- (NSString*)escapeJavaScript
{
    NSString* jsEscaped = self;
    jsEscaped = [jsEscaped stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    jsEscaped = [jsEscaped stringByReplacingOccurrencesOfString:@"</" withString:@"<\\/"];
    jsEscaped = [jsEscaped stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\\n"];
    jsEscaped = [jsEscaped stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    jsEscaped = [jsEscaped stringByReplacingOccurrencesOfString:@"\r" withString:@"\\n"];
    jsEscaped = [jsEscaped stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    jsEscaped = [jsEscaped stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    return jsEscaped;
}

@end
