//
//  UIApplication+Directories.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 3/14/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import "UIApplication+Directories.h"

@implementation UIApplication (Directories)

+ (NSString *)documentsDirectoryPath
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end
