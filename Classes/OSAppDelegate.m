//
//  AppDelegate.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 12/31/11.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "OSAppDelegate.h"

#import "OSStartupViewController.h"
#import "OSMainViewController.h"

#import "UIApplication+Directories.h"

#import "OSStoreManager.h"
#import "OSCoreDataManager.h"

#import "OSDefines.h" // can be removed if not found

#import <TargetConditionals.h>

#import <iNotify/iNotify.h>
#import <Appirater/Appirater.h>
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>
#import <uservoice-iphone-sdk/UserVoice.h>
#import <DropboxSDK/DropboxSDK.h>

#if DEBUG
#import <PonyDebugger.h>
#endif

#if RUN_KIF_TESTS
#import "OSTestController.h"
#endif

@interface OSAppDelegate () <iNotifyDelegate, AppiraterDelegate>
@property (nonatomic) BOOL appiraterAlertShowing;
@property (nonatomic, strong) id<GAITracker> tracker;
@end


@implementation OSAppDelegate

+ (OSAppDelegate *)sharedAppDelegate
{
	return (OSAppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // place all initialization code here that needs to be called "before" state restoration occurs
    [self commonLaunchInitialization:launchOptions];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // place all code that should occur "after" state restoration occurs (like password entry login, etc.)
    [self commonLaunchInitialization:launchOptions];
    
    // do not let the device sleep
    [application setIdleTimerDisabled:YES];
    
    //[application setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    //[application setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    [Appirater appLaunched:YES];
    
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
    
    // dispatch all unsent tracking info
    [[GAI sharedInstance] dispatch];
    
    // save all changes to the data
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    [Appirater appEnteredForeground:YES];
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
    
    if (! [self isRunningInTest]) {
        [debugger connectToURL:[NSURL URLWithString:@"ws://localhost:9000/device"]];
    }
#endif

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */

    // dispatch all unsent tracking info
    [[GAI sharedInstance] dispatch];
    
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
    // ignore if device ideom does not match
    UIDevice *currentDevice = [UIDevice currentDevice];
    UIUserInterfaceIdiom restorationInterfaceIdiom = [[coder decodeObjectForKey:UIApplicationStateRestorationUserInterfaceIdiomKey] integerValue];
    UIUserInterfaceIdiom currentInterfaceIdiom = currentDevice.userInterfaceIdiom;
    if (restorationInterfaceIdiom != currentInterfaceIdiom) {
        NSLog(@"Ignoring restoration data for interface idiom: %d", restorationInterfaceIdiom);
        return NO;
    }
    
    return YES;
}

- (void) application:(UIApplication *)application willEncodeRestorableStateWithCoder:(NSCoder *)coder
{

}

- (void)application:(UIApplication *)application didDecodeRestorableStateWithCoder:(NSCoder *)coder
{

}

- (UIViewController *)application:(UIApplication *)application viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    return nil;
}

#pragma mark - AppiraterDelegate

- (void)appiraterDidDisplayAlert:(Appirater *)appirater
{
    self.appiraterAlertShowing = YES;
}

- (void)appiraterDidOptToRate:(Appirater *)appirater
{
    // Google Analytics
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Appirater"
                                                               action:@"rate"
                                                                label:nil
                                                                value:nil] build]];
}

- (void)appiraterDidOptToRemindLater:(Appirater *)appirater
{
    // Google Analytics
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Appirater"
                                                               action:@"remind me"
                                                                label:nil
                                                                value:nil] build]];
}

- (void)appiraterDidDeclineToRate:(Appirater *)appirater
{
    // Google Analytics
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Appirater"
                                                               action:@"decline"
                                                                label:nil
                                                                value:nil] build]];
}

#pragma mark - iNofifyDelegate

- (BOOL)iNotifyShouldDisplayNotificationWithKey:(NSString *)key details:(NSDictionary *)details
{
    if (self.appiraterAlertShowing) {
        return NO;
    }
    return YES;
}

- (void)iNotifyUserDidIgnoreNotificationWithKey:(NSString *)key details:(NSDictionary *)details
{
    // Google Analytics
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"iNotify"
                                                               action:@"ignore"
                                                                label:key
                                                                value:nil] build]];
}

- (void)iNotifyUserDidRequestReminderForNotificationWithKey:(NSString *)key details:(NSDictionary *)details
{
    // Google Analytics
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"iNotify"
                                                               action:@"remind me"
                                                                label:key
                                                                value:nil] build]];
}

- (void)iNotifyUserDidViewActionURLForNotificationWithKey:(NSString *)key details:(NSDictionary *)details
{
    // Google Analytics
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"iNotify"
                                                               action:@"view action-url"
                                                                label:key
                                                                value:nil] build]];
}

- (void)iNotifyNotificationsCheckDidFailWithError:(NSError *)error
{
    // Google Analytics
    [self.tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:[error description]
                                                                   withFatal:@0] build]];
}

#pragma mark - Private Methods

- (void) commonLaunchInitialization:(NSDictionary *)launchOptions
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (! [self isRunningInTest]) {
            [self startCustomerServices];
        }

        [self copySampleSongsToDocumentsDirectory];
        
        // init CoreData and StoreKit
        [[OSCoreDataManager sharedManager] setupAndMigrateCoreData];
        [[OSStoreManager sharedManager] initInAppStore];
        
        [self applyStyleSheet];
        
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

        // additional CoreData migration
        self.window.rootViewController = [[OSStartupViewController alloc] init];
        //self.window.rootViewController = [[OSMainViewController alloc] init];
        
        [self.window makeKeyAndVisible];
    });
}

- (void) startCustomerServices
{

// Google Analytics
#ifdef IOPENSONGS_GOOGLEANALYTICS_KEY
    self.tracker = [[GAI sharedInstance] trackerWithTrackingId:IOPENSONGS_GOOGLEANALYTICS_KEY];
    [GAI sharedInstance].dispatchInterval = 30;
#if DEBUG
    //[[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
    [GAI sharedInstance].dispatchInterval = 5;
    [GAI sharedInstance].dryRun = YES;
#endif
#endif
    
// Dropbox
#ifndef IOPENSONGS_DROPBOX_APP_KEY
#define IOPENSONGS_DROPBOX_APP_KEY @""
#define IOPENSONGS_DROPBOX_APP_SECRET @""
#endif

    DBSession* dbSession = [[DBSession alloc] initWithAppKey:IOPENSONGS_DROPBOX_APP_KEY
                                                   appSecret:IOPENSONGS_DROPBOX_APP_SECRET
                                                        root:kDBRootDropbox]; // either kDBRootAppFolder or kDBRootDropbox
    [DBSession setSharedSession:dbSession];
    
// iNotify
#if PRODUCTION
#define IOPENSONGS_INOTIFY_URL NSLocalizedString(@"https://raw.github.com/deepflame/iOpenSongs/master/Resources/Strings/en.lproj/Notifications.plist", @"iNotify plist URL")
#else
#define IOPENSONGS_INOTIFY_URL NSLocalizedString(@"https://raw.github.com/deepflame/iOpenSongs/master/Resources/Strings/en.lproj/Notifications-Beta.plist", @"iNotify plist URL")
#endif
    [iNotify sharedInstance].notificationsPlistURL = IOPENSONGS_INOTIFY_URL;
    [iNotify sharedInstance].showOnFirstLaunch = NO;
    [iNotify sharedInstance].delegate = self;
    [iNotify sharedInstance].okButtonLabel = NSLocalizedString(@"OK", nil);
    [iNotify sharedInstance].ignoreButtonLabel = NSLocalizedString(@"Ignore", nil);
    [iNotify sharedInstance].remindButtonLabel = NSLocalizedString(@"Remind Me Later", nil);
    [iNotify sharedInstance].defaultActionButtonLabel = NSLocalizedString(@"More Info", nil);
#if DEBUG
    [iNotify sharedInstance].debug = NO;
#endif

// Appirater
    [Appirater setAppId:@"501589566"];
    [Appirater setDaysUntilPrompt:7];
    [Appirater setUsesUntilPrompt:10];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    [Appirater setDelegate:self];
    self.appiraterAlertShowing = NO;
#if DEBUG
    [Appirater setDebug:NO];
#endif

// UserVoice
#ifdef IOPENSONGS_USERVOICE_CONFIG
    [UserVoice initialize:IOPENSONGS_USERVOICE_CONFIG];
#endif

#ifndef DEBUG // just enable when in the wild

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
    
    [[UIToolbar appearance] setTintColor:osColor];

    // search bar
    [[UISearchBar appearance] setTintColor:[UIColor whiteColor]];
    [[UISearchBar appearance] setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
}

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

- (id)isRunningInTest
{
    return [[[NSProcessInfo processInfo] environment] objectForKey:@"Test"];
}

@end
