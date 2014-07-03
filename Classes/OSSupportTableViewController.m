//
//  ExtrasTableViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 2/5/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "OSSupportTableViewController.h"
#import "OSAboutViewController.h"

#import <uservoice-iphone-sdk/UserVoice.h>
#import <uservoice-iphone-sdk/UVRootViewController.h>
#import <uservoice-iphone-sdk/UVNavigationController.h>
#import <uservoice-iphone-sdk/UVBabayaga.h>
#import <uservoice-iphone-sdk/UVSession.h>
#import <uservoice-iphone-sdk/UVUtils.h>
#import "OSDefines.h"
#import "OSUserVoiceStyleSheet.h"

@interface OSSupportTableViewController ()
@end

@implementation OSSupportTableViewController

- (OSSupportTableViewController *)init
{
    self = [super init];
    if (self) {
        QRootElement *root = [[QRootElement alloc] init];
        root.title = NSLocalizedString(@"Support", nil);
        root.grouped = YES;
        
        QLabelElement *feedackButton = [[QLabelElement alloc] initWithTitle:NSLocalizedString(@"Feedback and Support", nil) Value:nil];
        feedackButton.image = [UIImage imageNamed:@"glyphicons_244_conversation"];
        feedackButton.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        feedackButton.keepSelected = NO;
        feedackButton.onSelected = ^ {
            [self trackEventWithAction:@"show UserVoice"];
            [self showUserVoice];
        };

        QLabelElement *githubButton = [[QLabelElement alloc] initWithTitle:NSLocalizedString(@"Fork Me", nil) Value:nil];
        githubButton.image = [UIImage imageNamed:@"glyphicons_381_github"];
        githubButton.onSelected = ^ {
            [self trackEventWithAction:@"show Github"];
            [self showGithub];
        };

        QLabelElement *twitterButton = [[QLabelElement alloc] initWithTitle:NSLocalizedString(@"Follow Us", nil) Value:nil];
        twitterButton.image = [UIImage imageNamed:@"glyphicons_392_twitter"];
        twitterButton.onSelected = ^ {
            [self trackEventWithAction:@"show Twitter"];
            [self showTwitter];
        };

        QLabelElement *aboutButton = [[QLabelElement alloc] initWithTitle:NSLocalizedString(@"About", nil) Value:self.version];
        aboutButton.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        aboutButton.onSelected = ^ {
            [self trackEventWithAction:@"show About"];
            [self showAbout];
        };
        
        QSection *section1 = [[QSection alloc] initWithTitle:nil];
        [section1 addElement:feedackButton];
        
        QSection *section2 = [[QSection alloc] initWithTitle:nil];
        [section2 addElement:githubButton];
        [section2 addElement:twitterButton];
        
        QSection *section3 = [[QSection alloc] initWithTitle:nil];
        [section3 addElement:aboutButton];
        
        [root addSection:section1];
        [root addSection:section2];
        [root addSection:section3];
        
        self.root = root;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.contentSizeForViewInPopover = CGSizeMake(320, 320);
    
    // iPad: done button for popup
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] bk_initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStyleDone handler:^(id sender) {
            [self.delegate supportViewController:self shouldFinishDisplaying:YES];
        }];
        self.navigationItem.leftBarButtonItems = @[doneItem];
    }

    self.navigationItem.leftItemsSupplementBackButton = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self trackScreen:@"Support"];
}

#pragma mark - Private Methods

- (void)showUserVoice
{
#if defined IOPENSONGS_USERVOICE_CONFIG
    [UVStyleSheet setStyleSheet:[[OSUserVoiceStyleSheet alloc] init]];
    
    NSString *viewToLoad = @"welcome";
    UVRootViewController *userVoiceViewController = [[UVRootViewController alloc] initWithViewToLoad:viewToLoad];
    
    [UVBabayaga track:VIEW_CHANNEL];
    [UVSession currentSession].isModal = YES;
    UINavigationController *navigationController = [[UVNavigationController alloc] init];
    [UVUtils applyStylesheetToNavigationController:navigationController];
    navigationController.viewControllers = @[userVoiceViewController];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:navigationController animated:YES];
#else
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://iopensongs.uservoice.com"]];
#endif
}

- (void)showGithub
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.github.com/deepflame/iOpenSongs"]];    
}

- (void)showTwitter
{
    // thanks to ChrisMaddern for providing this code
    // https://github.com/chrismaddern/Follow-Me-On-Twitter-iOS-Button
    NSArray *urls = [NSArray arrayWithObjects:
                     @"twitter://user?screen_name={handle}", // Twitter
                     @"tweetbot:///user_profile/{handle}", // TweetBot
                     @"echofon:///user_timeline?{handle}", // Echofon
                     @"twit:///user?screen_name={handle}", // Twittelator Pro
                     @"x-seesmic://twitter_profile?twitter_screen_name={handle}", // Seesmic
                     @"x-birdfeed://user?screen_name={handle}", // Birdfeed
                     @"tweetings:///user?screen_name={handle}", // Tweetings
                     @"simplytweet:?link=http://twitter.com/{handle}", // SimplyTweet
                     @"icebird://user?screen_name={handle}", // IceBird
                     @"fluttr://user/{handle}", // Fluttr
                     @"http://twitter.com/{handle}",
                     nil];
    
    UIApplication *application = [UIApplication sharedApplication];
    
    for (NSString *candidate in urls) {
        NSURL *url = [NSURL URLWithString:[candidate stringByReplacingOccurrencesOfString:@"{handle}" withString:@"iOpenSongs"]];
        if ([application canOpenURL:url]) {
            [application openURL:url];
            break;
        }
    }
}

- (void)showAbout
{
    OSAboutViewController *aboutVC = [[OSAboutViewController alloc] init];
    [self.navigationController pushViewController:aboutVC animated:YES];
}

- (NSString *)version
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    return [NSString stringWithFormat:@"%@ (%@)", version, build];
}

@end
