//
//  OSFileDescriptor.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/25/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "OSFileDescriptor.h"

@implementation OSFileDescriptor

@synthesize filename = _filename;
@synthesize contents = _contents;
@synthesize isDirectory = _isDirectory;
@synthesize humanReadableSize = _humanReadableSize;
@synthesize path = _path;

- (OSFileDescriptor *)initWithPath:(NSString *)path
{
    OSFileDescriptor *me = [self init];
    me.filename = [path lastPathComponent];
    me.path = path;
    
    NSFileManager *fman = [NSFileManager defaultManager];
    
    BOOL isDirectory;
    [fman fileExistsAtPath:path isDirectory:&isDirectory];
    
    return me;
}

@end
