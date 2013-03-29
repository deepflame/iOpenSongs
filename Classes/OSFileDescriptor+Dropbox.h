//
//  OSFileDescriptor+Dropbox.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/25/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "OSFileDescriptor.h"
#import <DropboxSDK/DBMetadata.h>

@interface OSFileDescriptor (Dropbox)

- (OSFileDescriptor *)initWithDropboxMetadata:(DBMetadata *)metadata;

@end
