//
//  OSCoreDataManager.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 12/4/13.
//  Copyright (c) 2013 Andreas Boehrnsen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSCoreDataManager : NSObject

+ (instancetype)sharedManager;

- (void)setupAndMigrateCoreData;

@end
