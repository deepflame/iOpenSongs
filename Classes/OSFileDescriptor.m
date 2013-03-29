//
//  OSFileDescriptor.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/25/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "OSFileDescriptor.h"
#import <FormatterKit/TTTUnitOfInformationFormatter.h>

@implementation OSFileDescriptor

@synthesize filename = _filename;
@synthesize contents = _contents;
@synthesize isDirectory = _isDirectory;
@synthesize humanReadableSize = _humanReadableSize;
@synthesize path = _path;

- (OSFileDescriptor *)initWithPath:(NSString *)path
{
    OSFileDescriptor *me = [self init];
    
    // filename and path
    me.filename = [path lastPathComponent];
    me.path = path;
    
    // isDirectory
    BOOL isDirectory;
    NSFileManager *fman = [NSFileManager defaultManager];
    [fman fileExistsAtPath:path isDirectory:&isDirectory];
    me.isDirectory = isDirectory;
    
    // humanReadableSize
    NSDictionary *fileAttributes = [fman attributesOfItemAtPath:path error:nil];
    NSNumber *fileSize = [NSNumber numberWithUnsignedLongLong:fileAttributes.fileSize];
    TTTUnitOfInformationFormatter *formatter = [[TTTUnitOfInformationFormatter alloc] init];
    me.humanReadableSize = [formatter stringFromNumber:fileSize ofUnit:TTTByte];
    
    return me;
}

@end
