//
//  ExtrasTableViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 2/5/12.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "OSExtrasTableViewController.h"
#import "OSHtmlViewController.h"

#import "Defines.h"
#import "UserVoice.h"
#import "OSUserVoiceStyleSheet.h"

@interface OSExtrasTableViewController ()

@property (weak, nonatomic) IBOutlet UITableViewCell *versionCell;
@end


@implementation OSExtrasTableViewController
@synthesize versionCell = _versionCell;

@synthesize delegate = _delegate;

- (NSString*) version
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    return [NSString stringWithFormat:@"%@ (%@)", version, build];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    self.versionCell.detailTextLabel.text = [self version];
}

- (void)viewDidUnload
{
    [self setVersionCell:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if ([[[tableView cellForRowAtIndexPath:indexPath] reuseIdentifier] isEqualToString:@"Feedback and Support Cell"]) {
#if defined IOPENSONGS_USERVOICE_CONFIG
        [UVStyleSheet setStyleSheet:[[OSUserVoiceStyleSheet alloc] init]];
        [UserVoice presentUserVoiceInterfaceForParentViewController:self andConfig:IOPENSONGS_USERVOICE_CONFIG];
#else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://iopensongs.uservoice.com"]];
#endif
    } else if ([[[tableView cellForRowAtIndexPath:indexPath] reuseIdentifier] isEqualToString:@"Fork Me Github Cell"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.github.com/deepflame/iOpenSongs"]];
        
    } else if ([[[tableView cellForRowAtIndexPath:indexPath] reuseIdentifier] isEqualToString:@"Follow Us Twitter Cell"]) {
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
                                                 
#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{    
    if ([segue.identifier isEqualToString:@"Show About"]) {
        OSHtmlViewController *htmlVC = (OSHtmlViewController *) segue.destinationViewController;
        
        htmlVC.title = @"About";
        htmlVC.resourceURL = [[NSBundle mainBundle] URLForResource:@"about" withExtension:@"html"];
    }
}

@end
