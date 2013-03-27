//
//  OSFileDescriptor.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/25/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSFileDescriptor : NSObject

- (OSFileDescriptor *)initWithPath:(NSString *)path;

//@property (nonatomic, readonly) long long totalBytes;
//@property (nonatomic, readonly) NSDate* lastModifiedDate;
//@property (nonatomic, readonly) NSDate* clientMtime;
@property (nonatomic, strong) NSString* path;
@property (nonatomic        ) BOOL isDirectory;
@property (nonatomic, strong) NSArray* contents;
@property (nonatomic, strong) NSString* humanReadableSize;
//@property (nonatomic, readonly) NSString* root;
//@property (nonatomic, readonly) NSString* icon;
@property (nonatomic, strong) NSString* filename;

@end
