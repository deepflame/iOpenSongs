//
//  SongViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 12/31/11.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "SongViewController.h"
#import "NSString+JavaScript.h"
#import "Song.h"

#import "SongMasterViewController.h"
#import "ExtrasTableViewController.h"

#pragma mark SongViewController () 

// private interface
@interface SongViewController () <ExtrasTableViewControllerDelegate, SongMasterViewControllerDelegate, UIWebViewDelegate>
{
    IBOutlet UIWebView *songWebView;
    IBOutlet UIBarButtonItem *extrasBarButtonItem;
}

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) UIPopoverController *extrasPopoverController;

@property (nonatomic) BOOL nightMode;

- (void)displaySong;
- (void)loadHtmlTemplate;
@end


@implementation SongViewController

@synthesize masterPopoverController = _masterPopoverController;
@synthesize extrasPopoverController = _extrasPopoverController;
@synthesize song = _song;


#pragma mark - Managing the song

- (void)setSong:(Song *)song
{
    if (_song != song) {
        _song = song;
        
        // Update the view.
        [self displaySong];
    }
    
    [self.masterPopoverController dismissPopoverAnimated:YES];
}

- (void)displaySong 
{
    if (self.song) {
        NSString* jsString = [NSString stringWithFormat:@"$('#lyrics').openSongLyrics(\"%@\");", [self.song.lyrics escapeJavaScript]];
        [songWebView stringByEvaluatingJavaScriptFromString:jsString];
        self.navigationItem.title = self.song.title; 
    }
}

- (void)loadHtmlTemplate 
{
    NSString *rootPath = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:rootPath];
    
    NSURL *templateUrl = [[NSBundle mainBundle] URLForResource:@"SongTemplate" withExtension:@"html"];
    NSString *htmlDoc = [NSString stringWithContentsOfURL:templateUrl 
                                                 encoding:NSUTF8StringEncoding
                                                    error:NULL];
    [songWebView loadHTMLString:htmlDoc baseURL:baseURL];
}

- (void)setNightMode:(BOOL)state
{
    if (state == YES) {
        [songWebView stringByEvaluatingJavaScriptFromString:@"$('body').addClass('nightmode');"];        
    } else {
        [songWebView stringByEvaluatingJavaScriptFromString:@"$('body').removeClass('nightmode');"];        
    }
}

- (BOOL)nightMode
{
    return [[songWebView stringByEvaluatingJavaScriptFromString:@"$('body').hasClass('nightmode');"] isEqualToString:@"true"];
}

#pragma mark - UIView (view lifecycle)

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    songWebView.delegate = self;

    [self loadHtmlTemplate];
}

- (void)viewDidUnload
{
    extrasBarButtonItem = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - ExtrasTableViewControllerDelegate

#define USER_DEFAULTS_KEY_NIGHT_MODE @"SongViewController.nightMode"

- (void)extrasTableViewControllerDelegate:(ExtrasTableViewController *)sender changedNightMode:(BOOL)state
{
    self.nightMode = state;
    
    // set user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:state] forKey:USER_DEFAULTS_KEY_NIGHT_MODE];
    [defaults synchronize];
}

- (void)extrasTableViewControllerDelegate:(ExtrasTableViewController *)sender dismissMyPopoverAnimated:(BOOL)animated
{
    [self.extrasPopoverController dismissPopoverAnimated:animated];
}

#pragma mark - SongMasterViewControllerDelegate

- (void)songMasterViewControllerDelegate:(SongMasterViewController *)sender choseSong:(Song *)song
{
    self.song = song;
    [self.navigationController popViewControllerAnimated:YES];
}

# pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.nightMode = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_KEY_NIGHT_MODE] boolValue];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request 
 navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    return YES;
}

# pragma mark - IBActions

- (IBAction)showExtrasPopup:(UIBarButtonItem *)sender 
{
    if (self.extrasPopoverController.popoverVisible) {
        [self.extrasPopoverController dismissPopoverAnimated:YES];
    } else {
        [self performSegueWithIdentifier:@"Show Extras Popup" sender:self];
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Extras Popup"]) {
        ExtrasTableViewController *etvCon;
        
        if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
            UIStoryboardPopoverSegue *popoverSegue = (UIStoryboardPopoverSegue *)segue;
            [self.extrasPopoverController dismissPopoverAnimated:NO];
            self.extrasPopoverController = popoverSegue.popoverController; // might want to be popover's delegate and self.popoverController = nil on dismiss?

            UINavigationController *navCon = segue.destinationViewController;
            etvCon = (ExtrasTableViewController *) navCon.topViewController;
        } else {
            etvCon = (ExtrasTableViewController *) segue.destinationViewController;
        }
        
        etvCon.nightModeEnabled = self.nightMode;
        etvCon.delegate = self;        
    }
}

@end
