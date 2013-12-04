//
//  AppDelegate.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 12/31/11.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "OSAppDelegate.h"
#import "OSStartupViewController.h"

#import "UIApplication+Directories.h"

#import "OSDefines.h" // can be removed if not found
#import "GAI.h"

#import <TargetConditionals.h>
#import <DropboxSDK/DropboxSDK.h>

#import "OSStoreManager.h"
#import "OSCoreDataManager.h"

#if DEBUG
#import <PonyDebugger.h>
#endif

#if RUN_KIF_TESTS
#import "OSTestController.h"
#endif

@implementation OSAppDelegate

@synthesize window = _window;

+ (OSAppDelegate *)sharedAppDelegate
{
	return (OSAppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self commonInitialization];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self commonInitialization];
    
    // Override point for customization after application launch.
    
    // do not let the device sleep
    [application setIdleTimerDisabled:YES];
    
    //[application setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    //[application setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    self.window.rootViewController = [[OSStartupViewController alloc] init];
    // additional CoreData migration
    
    [self.window makeKeyAndVisible];
    
#if RUN_KIF_TESTS
    [[OSTestController sharedInstance] startTestingWithCompletionBlock:^{
        // Exit after the tests complete. When running on CI, this lets you check the return value for pass/fail.
        exit([[OSTestController sharedInstance] failureCount]);
    }];
#endif
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
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

#if TARGET_IPHONE_SIMULATOR
    // PonyDebugger
    PDDebugger *debugger = [PDDebugger defaultInstance];
    [debugger enableCoreDataDebugging];
    [debugger addManagedObjectContext:[NSManagedObjectContext MR_contextForCurrentThread] withName:@"MOC"];

    [debugger enableNetworkTrafficDebugging];
    [debugger forwardAllNetworkTraffic];

    [debugger enableViewHierarchyDebugging];
    
    [debugger connectToURL:[NSURL URLWithString:@"ws://localhost:9000/device"]];
#endif

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

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return YES;
}

# pragma mark Private Methods

- (void)commonInitialization
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        
        [self startCustomerServices];
        
        [self applyStyleSheet];
        
        [self copySampleSongsToDocumentsDirectory];
        
        // init CoreData and StoreKit
        [[OSCoreDataManager sharedManager] setupAndMigrateCoreData];
        [[OSStoreManager sharedManager] initInAppStore];
    });
}

- (void) startCustomerServices
{

// Dropbox
#ifndef IOPENSONGS_DROPBOX_APP_KEY
#define IOPENSONGS_DROPBOX_APP_KEY @""
#define IOPENSONGS_DROPBOX_APP_SECRET @""
#endif

    DBSession* dbSession = [[DBSession alloc] initWithAppKey:IOPENSONGS_DROPBOX_APP_KEY
                                                   appSecret:IOPENSONGS_DROPBOX_APP_SECRET
                                                        root:kDBRootDropbox]; // either kDBRootAppFolder or kDBRootDropbox
    [DBSession setSharedSession:dbSession];

#ifndef DEBUG // just enable when in the wild

// Google Analytics
#ifdef IOPENSONGS_GOOGLEANALYTICS_KEY
    [[GAI sharedInstance] trackerWithTrackingId:IOPENSONGS_GOOGLEANALYTICS_KEY];
#endif

// Test Flight
#ifdef IOPENSONGS_TESTFLIGHT_KEY
    [TestFlight takeOff:IOPENSONGS_TESTFLIGHT_KEY];
#endif

// Crashlytics
#ifdef IOPENSONGS_CRASHLYTICS_KEY
	[Crashlytics startWithAPIKey:IOPENSONGS_CRASHLYTICS_KEY];
#if TARGET_IPHONE_SIMULATOR
    [Crashlytics sharedInstance].debugMode = YES;
#endif
#endif

#endif
}

- (void)applyStyleSheet
{
    UIColor *osColor = [UIColor colorWithRed:0.33333334329999997f
                                       green:0.039215687659999998f
                                        blue:0.32549020649999999f
                                       alpha:1.0f];
    
    // navigation bar
    [[UINavigationBar appearance] setTintColor:osColor];

    // search bar
    [[UISearchBar appearance] setTintColor:[UIColor whiteColor]];
    [[UISearchBar appearance] setAutoresizingMask:UIViewAutoresizingFlexibleWidth];

- (void)copySampleSongsToDocumentsDirectory
{
    NSString *sampleSong = @"Amazing Grace"; // TODO make more generic or use constant
    
    NSString *documentsDirectoryPath = [UIApplication documentsDirectoryPath];
    NSMutableArray *documentsDirectoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectoryPath error:NULL].mutableCopy;
    
    [documentsDirectoryContents removeObject:@".DS_Store"]; // fix for simulator
    
    if (documentsDirectoryContents.count == 0) {
        NSString *songSrcPath = [[NSBundle mainBundle] pathForResource:sampleSong ofType:@"" inDirectory:nil];
        NSString *songDstPath = [documentsDirectoryPath stringByAppendingPathComponent:sampleSong];
        
        NSFileManager *fileMan = [NSFileManager defaultManager];
        [fileMan copyItemAtPath:songSrcPath toPath:songDstPath error:nil];
    }
}

@end
