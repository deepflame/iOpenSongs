//
//  AppDelegate.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 12/31/11.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "AppDelegate.h"

#import "Defines.h" // can be removed if not found
#import <Crashlytics/Crashlytics.h>

@implementation AppDelegate

@synthesize window = _window;

// db file name
NSString * const kCoreDataStoreFileName = @"CoreDataStore.sqlite";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [self moveDatabaseToMRStoreName:kCoreDataStoreFileName];
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:kCoreDataStoreFileName];

#ifdef IOPENSONGS_TESTFLIGHT_KEY
    [TestFlight takeOff:IOPENSONGS_TESTFLIGHT_KEY];
#endif
    
#ifdef IOPENSONGS_CRASHLYTICS_KEY
	[Crashlytics startWithAPIKey:IOPENSONGS_CRASHLYTICS_KEY];
#endif
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
    // save all changes to the data
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */

    // save all changes to the data
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
    
    [MagicalRecord cleanUp];
}

/** migrates/moves the database to the new MR location */
- (void) moveDatabaseToMRStoreName:(NSString *)storeName
{
    NSFileManager *fileMan = [NSFileManager defaultManager];
    
    NSURL *oldDirUrl = [[fileMan URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
    oldDirUrl = [oldDirUrl URLByAppendingPathComponent:@"Default Song Database"];
    NSURL *oldUrl = [oldDirUrl URLByAppendingPathComponent:@"StoreContent"];
    oldUrl = [oldUrl URLByAppendingPathComponent:@"persistentStore"];
    
    NSURL *newUrl = [NSPersistentStore MR_urlForStoreName:storeName];
    
    // return if old db file does not exist
    if (![fileMan isReadableFileAtPath:[oldUrl path]]) {
        return;
    }
    
    // TODO: move this part into a category of NSFileManager
    NSError *error;
    // create directory of target path
    [fileMan createDirectoryAtURL:[newUrl URLByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&error];
    // copy file
    [fileMan copyItemAtURL:oldUrl toURL:newUrl error:&error];
    // delete old db dir
    [fileMan removeItemAtURL:oldDirUrl error:&error];
}

@end
