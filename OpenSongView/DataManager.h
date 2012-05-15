//
//  DataManager.h
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 5/15/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DataManager : NSObject

+ (DataManager*)sharedInstance;
- (NSManagedObjectContext*)managedObjectContext;

- (void)useDatabaseWithCompletionHandler:(void (^)(BOOL success))completionHandler;
- (BOOL)save;

@end
