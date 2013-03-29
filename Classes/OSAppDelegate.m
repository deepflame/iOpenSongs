//
//  AppDelegate.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 12/31/11.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "OSAppDelegate.h"
#import "OSStartupViewController.h"

#import "OSDefines.h" // can be removed if not found
#import "GAI.h"

#import <DropboxSDK/DropboxSDK.h>

@implementation OSAppDelegate

@synthesize window = _window;

+ (OSAppDelegate *)sharedAppDelegate {
	return (OSAppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.storyboard = [UIStoryboard storyboardWithName:@"iPad" bundle:nil];
    } else {
        self.storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];        
    }
    
    // Override point for customization after application launch.
    
    // do not let the device sleep
    [application setIdleTimerDisabled:YES];
    
    [self startCustomerServices];
    
    // setup CoreData and display ui
    self.window.rootViewController = [[OSStartupViewController alloc] init];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"App linked successfully!");
            // At this point you can start making API calls
        }
        return YES;
    }
    // Add whatever other url handling code your app requires here
    return NO;
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

# pragma mark Private Methods

- (void) startCustomerServices
{

#ifndef IOPENSONGS_DROPBOX_APP_KEY
#define IOPENSONGS_DROPBOX_APP_KEY @""
#define IOPENSONGS_DROPBOX_APP_SECRET @""
#endif

    DBSession* dbSession = [[DBSession alloc] initWithAppKey:IOPENSONGS_DROPBOX_APP_KEY
                                                   appSecret:IOPENSONGS_DROPBOX_APP_SECRET
                                                        root:kDBRootDropbox]; // either kDBRootAppFolder or kDBRootDropbox
    [DBSession setSharedSession:dbSession];
    
#ifdef IOPENSONGS_GOOGLEANALYTICS_KEY
    [[GAI sharedInstance] trackerWithTrackingId:IOPENSONGS_GOOGLEANALYTICS_KEY];
#endif
    
#ifdef IOPENSONGS_TESTFLIGHT_KEY
    [TestFlight takeOff:IOPENSONGS_TESTFLIGHT_KEY];
#endif
    
#ifdef IOPENSONGS_CRASHLYTICS_KEY
	[Crashlytics startWithAPIKey:IOPENSONGS_CRASHLYTICS_KEY];
#endif
}

@end
