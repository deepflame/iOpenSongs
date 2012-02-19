//
//  SongViewController.m
//  OpenSongView
//
//  Created by Andreas Böhrnsen on 12/31/11.
//  Copyright (c) 2011 Open iT Norge AS. All rights reserved.
//

#import "SongViewController.h"
#import "Song.h"
#import "OpenSongParseOperation.h"

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

@property (strong, nonatomic) NSOperationQueue *operationQueue;     // the queue that manages our NSOperation for parsing song data

- (NSString*)escapeJavaScript:(NSString*)unescaped;

- (void)displaySong;
- (void)loadHtmlTemplate;
- (void)handleError:(NSError *)error;
@end


@implementation SongViewController

@synthesize masterPopoverController = _masterPopoverController;
@synthesize extrasPopoverController = _extrasPopoverController;
@synthesize song = _song;
@synthesize operationQueue = _operationQueue;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;   // implementation of SplitViewBarButtonItemPresenter protocol


- (void)handleSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    self.navigationItem.leftBarButtonItem = splitViewBarButtonItem;
    _splitViewBarButtonItem = splitViewBarButtonItem;
}

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (splitViewBarButtonItem != _splitViewBarButtonItem) {
        [self handleSplitViewBarButtonItem:splitViewBarButtonItem];
    }
}

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
        NSString* jsString = [NSString stringWithFormat:@"$('#lyrics').openSongLyrics(\"%@\");", [self escapeJavaScript:self.song.lyrics]];
        [songWebView stringByEvaluatingJavaScriptFromString:jsString];
        self.navigationItem.title = self.song.title; 
    }
}

- (NSString*)escapeJavaScript:(NSString*)unescaped
{
    NSString* jsEscaped = unescaped;
    jsEscaped = [jsEscaped stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    jsEscaped = [jsEscaped stringByReplacingOccurrencesOfString:@"</" withString:@"<\\/"];
    jsEscaped = [jsEscaped stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\\n"];
    jsEscaped = [jsEscaped stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    jsEscaped = [jsEscaped stringByReplacingOccurrencesOfString:@"\r" withString:@"\\n"];
    jsEscaped = [jsEscaped stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    jsEscaped = [jsEscaped stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    return jsEscaped;
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
    if (state == TRUE) {
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
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(songParseCallback:)
                                                 name:kSongSuccessNotif
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(songParseErrback:)
                                                 name:kSongErrorNotif
                                               object:nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
       [self handleSplitViewBarButtonItem:self.splitViewBarButtonItem];
    }
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

#pragma mark -
#pragma mark OpenSong File Parsing

- (void)parseSongFromUrl:(NSURL *)songFileUrl
{    
    NSData *songData = [[NSData alloc] initWithContentsOfURL:songFileUrl];
    [self parseSongData:songData];
}

- (void)parseSongData:(NSData *)songData
{    
    // Spawn an NSOperation to parse the earthquake data so that the UI is not blocked while the
    // application parses the XML data.
    //
    // IMPORTANT! - Don't access or affect UIKit objects on secondary threads.
    //
    OpenSongParseOperation *parseOperation = [[OpenSongParseOperation alloc] initWithData:songData];
    //operationQueue = [NSOperationQueue new];
    //[self.operationQueue addOperation:parseOperation];
    
    //TODO: this should run on a different thread
    [parseOperation start];
}

// Our NSNotification callback from the running NSOperation to add the earthquakes
//
- (void)songParseCallback:(NSNotification *)notif {
    assert([NSThread isMainThread]);
    
    self.song = [[notif userInfo] valueForKey:kSongSuccessKey];
}

// Our NSNotification callback from the running NSOperation when a parsing error has occurred
//
- (void)songParseErrback:(NSNotification *)notif {
    assert([NSThread isMainThread]);
    
    [self handleError:[[notif userInfo] valueForKey:kSongErrorKey]];
}

#pragma mark -

// Handle errors in the download by showing an alert to the user. This is a very
// simple way of handling the error, partly because this application does not have any offline
// functionality for the user. Most real applications should handle the error in a less obtrusive
// way and provide offline functionality to the user.
//
- (void)handleError:(NSError *)error {
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView =
    [[UIAlertView alloc] initWithTitle:
     NSLocalizedString(@"Error Title",
                       @"Title for alert displayed when download or parse error occurs.")
                               message:errorMessage
                              delegate:nil
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil];
    [alertView show];
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

- (void)songMasterViewControllerDelegate:(SongMasterViewController *)sender choseSong:(NSURL *)song
{
    [self parseSongFromUrl:song];
    [self.navigationController popViewControllerAnimated:YES];
}

# pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.nightMode = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_KEY_NIGHT_MODE] boolValue];
    
    [songWebView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout = 'none';"];
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
    } else if ([segue.identifier isEqualToString:@"Show Song List"]) {
        [segue.destinationViewController setDelegate:self];
    }
}

@end
