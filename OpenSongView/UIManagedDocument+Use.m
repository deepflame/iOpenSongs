//
//  UIManagedDocument+Use.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 5/12/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "UIManagedDocument+Use.h"

@implementation UIManagedDocument (Use)

- (void)useWithCompletionHandler:(void (^)(BOOL success))completionHandler
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.fileURL path]]) {
        // does not exist on disk, so create it
        [self saveToURL:self.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:completionHandler];
    } else if (self.documentState == UIDocumentStateClosed) {
        // exists on disk, but we need to open it
        [self openWithCompletionHandler:completionHandler];
    } else if (self.documentState == UIDocumentStateNormal) {
        // already open and ready to use
        completionHandler(YES);
    }
}

@end
