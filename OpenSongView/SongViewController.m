//
//  SongViewController.m
//  OpenSongView
//
//  Created by Andreas Böhrnsen on 12/31/11.
//  Copyright (c) 2011 Open iT Norge AS. All rights reserved.
//

#import "SongViewController.h"
#import "OpenSongParseOperation.h"

#pragma mark SongViewController () 

// private interface
@interface SongViewController () 
{
    IBOutlet UIWebView *songLyrics;
}

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) NSOperationQueue *operationQueue;     // the queue that manages our NSOperation for parsing song data

- (NSString*)escapeJavaScript:(NSString*)unescaped;

- (void)displaySong;
- (void)loadHtmlTemplate;
- (void)handleError:(NSError *)error;
@end


@implementation SongViewController

@synthesize masterPopoverController = _masterPopoverController;
@synthesize song = _song;
@synthesize operationQueue = _operationQueue;

#pragma mark - Managing the song

- (void)setSong:(id)newSong
{
    if (_song != newSong) {
        _song = newSong;
        
        // Update the view.
        [self displaySong];
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)displaySong 
{
    if (self.song) {
        NSString* jsString = [NSString stringWithFormat:@"$('#lyrics').openSongLyrics(\"%@\");", [self escapeJavaScript:self.song.lyrics]];
        [songLyrics stringByEvaluatingJavaScriptFromString:jsString];
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
    [songLyrics loadHTMLString:htmlDoc baseURL:baseURL];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    [self loadHtmlTemplate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(songParseCallback:)
                                                 name:kSongSuccessNotif
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(songParseErrback:)
                                                 name:kSongErrorNotif
                                               object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
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

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Songs", @"Songs");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
