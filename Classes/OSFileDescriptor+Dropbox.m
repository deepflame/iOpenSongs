//
//  OSFileDescriptor+Dropbox.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/25/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "OSFileDescriptor+Dropbox.h"

@implementation OSFileDescriptor (Dropbox)

- (OSFileDescriptor *)initWithDropboxMetadata:(DBMetadata *)metadata
{
    OSFileDescriptor *me = [self init];
    me.filename = metadata.filename;
    me.isDirectory = metadata.isDirectory;
    me.path = metadata.path;
    me.humanReadableSize = metadata.humanReadableSize;
    return me;
}

@end
